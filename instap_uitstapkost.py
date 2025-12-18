from auth import (
    get_group_by_id,
    list_group_members,
)
from market_data import get_latest_price
from models import Portefeuille, SessionLocal,Transacties, Wisselkoersen
from config import supabase


# -----------------------------
# Helpers
# -----------------------------
def safe_float(value, default=0.0):
    try:
        if value is None:
            return default
        return float(value)
    except (TypeError, ValueError):
        return default


def load_positions(group_id):
    session = SessionLocal()
    try:
        return session.query(Portefeuille) \
            .filter(Portefeuille.groep_id == group_id) \
            .all()
    finally:
        session.close()

def get_fx_rate(session, munt):
    if not munt or munt.upper() == "EUR":
        return 1.0

    row = session.query(Wisselkoersen).filter(
        Wisselkoersen.munt == munt.upper()
    ).first()

    return float(row.wk) if row else 1.0



# -----------------------------
# NAV = Portefeuille (incl CASH)
# -----------------------------
def get_group_nav(group_id):
    session = SessionLocal()
    try:
        positions = session.query(Portefeuille).filter(
            Portefeuille.groep_id == group_id
        ).all()

        total = 0.0

        for pos in positions:
            qty = safe_float(pos.quantity)
            if qty == 0:
                continue

            ticker = pos.ticker.upper()

            # CASH is altijd EUR
            if ticker == "CASH":
                total += qty
                continue

            # 1️⃣ prijs in beursmunt (bv USD)
            try:
                price_native = get_latest_price(ticker)
            except Exception:
                price_native = safe_float(pos.avg_price)

            # 2️⃣ bepaal munt via laatste transactie
            tx = session.query(Transacties).filter(
                Transacties.portefeuille_id == pos.port_id
            ).order_by(Transacties.datum_tr.desc()).first()

            munt = tx.munt if tx else "EUR"

            # 3️⃣ wisselkoers
            fx = get_fx_rate(session, munt)

            # 4️⃣ omzetten naar EUR
            price_eur = price_native / fx

            total += qty * price_eur

        return round(total, 2)

    finally:
        session.close()


# -----------------------------
# Liquiditeitsbuffer
# -----------------------------
def get_liquidity_balance(group_id):
    try:
        rows = supabase.table("Liquiditeit") \
            .select("bedrag") \
            .eq("groep_id", group_id) \
            .execute().data

        return sum(safe_float(r["bedrag"]) for r in rows) if rows else 0.0
    except Exception:
        return 0.0


# -----------------------------
# Leden & instellingen
# -----------------------------
def get_member_count(group_id):
    ok, members = list_group_members(group_id)
    if not ok:
        return 0
    return len(members or [])


def get_group_settings(group_id):
    ok, group = get_group_by_id(group_id)
    if not ok or not group:
        return None
    return group


# -----------------------------
# Instap
# -----------------------------
def calculate_entry_cost(group_id):
    nav_total = get_group_nav(group_id)
    leden = get_member_count(group_id)
    settings = get_group_settings(group_id)

    if leden == 0 or not settings:
        return False, "Geen leden of instellingen"

    nav_per_lid = nav_total / leden
    instap_nav_pct = safe_float(settings.get("instap_nav_pct"))

    nav_fee = nav_per_lid * (instap_nav_pct / 100)
    entry_cost = nav_per_lid + nav_fee

    return True, {
        "nav_total": nav_total,
        "nav_per_member": round(nav_per_lid, 2),
        "nav_fee": round(nav_fee, 2),
        "entry_cost": round(entry_cost, 2),
    }


# -----------------------------
# Uitstap
# -----------------------------
def calculate_exit_cost(group_id):
    nav_total = get_group_nav(group_id)
    leden = get_member_count(group_id)
    settings = get_group_settings(group_id)

    if leden == 0 or not settings:
        return False, "Geen leden of instellingen"

    nav_per_lid = nav_total / leden

    uitstap_nav_pct = safe_float(settings.get("uitstap_nav_pct"))
    uitstap_liq_pct = safe_float(settings.get("uitstap_liq_pct"))
    liq_per_lid = bool(settings.get("liq_per_lid"))

    total_liq = get_liquidity_balance(group_id)

    nav_fee = nav_per_lid * (uitstap_nav_pct / 100)

    if liq_per_lid:
        liq_fee = total_liq / leden
    else:
        liq_fee = (total_liq * (uitstap_liq_pct / 100)) / leden if leden else 0.0

    exit_payout = nav_per_lid - nav_fee - liq_fee

    return True, {
        "nav_total": nav_total,
        "nav_per_member": round(nav_per_lid, 2),
        "nav_fee": round(nav_fee, 2),
        "liq_fee": round(liq_fee, 2),
        "exit_payout": round(exit_payout, 2),
    }
