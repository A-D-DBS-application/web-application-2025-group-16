from auth import (
    get_cash_balance_for_group,
    get_group_by_id,
    list_group_members,
)
from market_data import get_latest_price
from models import Portefeuille, SessionLocal


def _safe_float(value, default=0.0):
    try:
        return float(value)
    except (TypeError, ValueError):
        return default


def _load_positions(group_id):
    session = SessionLocal()
    try:
        return session.query(Portefeuille).filter(Portefeuille.groep_id == group_id).all()
    finally:
        session.close()


def get_group_nav(group_id):
    try:
        positions = _load_positions(group_id)
        if not positions:
            return 0.0

        price_cache = {}
        total = 0.0
        for pos in positions:
            qty = _safe_float(pos.quantity)
            if qty == 0:
                continue

            ticker = (pos.ticker or "").upper()
            if ticker == "CASH":
                total += qty
                continue

            if ticker not in price_cache:
                price = None
                try:
                    price = get_latest_price(ticker)
                except Exception:
                    price = None
                if price is None or price <= 0:
                    price = _safe_float(pos.avg_price)
                price_cache[ticker] = _safe_float(price)

            total += qty * price_cache[ticker]

        return total
    except Exception:
        return None


def get_total_liquidity(group_id):
    ok, amount = get_cash_balance_for_group(group_id)
    if not ok:
        return None
    return _safe_float(amount)


def _member_count(group_id):
    ok, members = list_group_members(group_id)
    if not ok:
        return False, members
    return True, len(members or [])


def _load_group_settings(group_id):
    ok, group = get_group_by_id(group_id)
    if not ok:
        return False, group
    if not group:
        return False, "Groep niet gevonden"
    return True, group


def calculate_entry_cost(group_id):
    try:
        nav_total = get_group_nav(group_id)
        if nav_total is None:
            return False, "NAV kon niet berekend worden"

        ok_count, leden = _member_count(group_id)
        if not ok_count:
            return False, leden
        if leden == 0:
            return False, "Geen leden gevonden"

        ok_settings, settings = _load_group_settings(group_id)
        if not ok_settings:
            return False, settings

        nav_per_member = nav_total / leden
        instap_nav_pct = _safe_float(settings.get("instap_nav_pct"))

        nav_fee = nav_per_member * (instap_nav_pct / 100)
        liq_fee = 0.0  # instappers betalen geen liquiditeitskost
        entry_cost = nav_per_member + nav_fee + liq_fee

        return True, {
            "nav_per_member": nav_per_member,
            "nav_fee": nav_fee,
            "liq_fee": liq_fee,
            "entry_cost": entry_cost,
        }
    except Exception as exc:
        return False, str(exc)


def calculate_exit_cost(group_id):
    try:
        nav_total = get_group_nav(group_id)
        if nav_total is None:
            return False, "Kan NAV niet berekenen"

        ok_count, leden = _member_count(group_id)
        if not ok_count:
            return False, leden
        if leden == 0:
            return False, "Geen leden"

        ok_settings, settings = _load_group_settings(group_id)
        if not ok_settings:
            return False, settings

        nav_per_member = nav_total / leden if leden else 0.0
        uitstap_nav_pct = _safe_float(settings.get("uitstap_nav_pct"))
        uitstap_liq_pct = _safe_float(settings.get("uitstap_liq_pct"))
        liq_per_lid = bool(settings.get("liq_per_lid"))

        total_liq = get_total_liquidity(group_id)
        if total_liq is None:
            total_liq = 0.0

        nav_fee = nav_per_member * (uitstap_nav_pct / 100)
        if liq_per_lid and leden:
            liq_fee = total_liq / leden
        else:
            liq_fee = (total_liq * (uitstap_liq_pct / 100)) / leden if leden else 0.0

        exit_payout = nav_per_member - nav_fee - liq_fee

        return True, {
            "nav_per_member": nav_per_member,
            "nav_fee": nav_fee,
            "liq_fee": liq_fee,
            "exit_payout": exit_payout,
        }
    except Exception as exc:
        return False, str(exc)
