import logging
from datetime import date, datetime
from sqlalchemy.orm import Session
from models import (
    SessionLocal,
    Leden,
    Groep,
    GroepLeden,
    Portefeuille,
    Transacties,
    Kas,
    GroepAanvragen,
    Activa,
)
from market_data import get_latest_price, get_ticker_data

# --- CONFIGURATIE ---
# (Supabase client vervangen door SQLAlchemy SessionLocal)

GROUP_TABLE = "Groep"
GROUP_MEMBER_TABLE = "groep_leden"
GROUP_ID_COLUMN = "groep_id"
GROUP_NAME_COLUMN = "groep_naam"
GROUP_DESCRIPTION_COLUMN = "omschrijving"
GROUP_CODE_COLUMN = "invite_code"
GROUP_OWNER_COLUMN = "owner_lid_id"
GROUP_ROLE_COLUMN = "rol"

PORTFOLIO_TABLE = "Portefeuille"
CASH_TX_TABLE = "Kas"
TRANSACTION_TABLE = "Transacties"

# Alle externe Yahoo/prijslogica is verplaatst naar market_data.py


def _normalize_ticker(ticker: str | None) -> str:
    return (ticker or "").strip().upper()


def _asset_defaults_from_market(ticker: str) -> tuple[str, str | None]:
    try:
        info = get_ticker_data(ticker)
        if info:
            name = info.get("longName") or info.get("shortName") or ticker
            sector = info.get("sector") or None
            return name, sector
    except Exception as exc:  # pragma: no cover - logging only
        logging.warning(f"Kon metadata niet ophalen voor {ticker}: {exc}")
    return ticker, None


def _ensure_asset(session: Session, ticker: str, name: str | None = None, sector: str | None = None) -> Activa:
    normalized = _normalize_ticker(ticker)
    asset = session.query(Activa).filter(Activa.ticker == normalized).first()
    if asset:
        updated = False
        if name and asset.name in (None, "", "ONBEKEND - Vul Naam In"):
            asset.name = name
            updated = True
        if sector and (asset.sector in (None, "", "ONBEKEND - Vul Sector In")):
            asset.sector = sector
            updated = True
        if updated:
            session.flush()
        return asset

    default_name, default_sector = name, sector
    if not default_name or not default_sector:
        fetched_name, fetched_sector = _asset_defaults_from_market(normalized)
        default_name = default_name or fetched_name
        default_sector = default_sector or fetched_sector

    asset = Activa(ticker=normalized, name=default_name or normalized, sector=default_sector)
    session.add(asset)
    session.flush()
    return asset


def log_portfolio_transaction(portfolio_id, ticker, trade_type, amount, price, exchange_rate=1.0, currency="EUR", datum_tr=None):
    """Logt een transactie in de Transacties tabel."""
    try:
        normalized_ticker = _normalize_ticker(ticker)
        if not portfolio_id and not normalized_ticker:
            return False, "Portfolio ID of ticker vereist"

        raw_date = (datum_tr or "").strip()
        dt_value = date.today()
        if raw_date:
            try:
                if len(raw_date) == 10 and raw_date[4] == '-' and raw_date[7] == '-':
                    dt_value = datetime.strptime(raw_date, "%Y-%m-%d").date()
                else:
                    dt_value = datetime.fromisoformat(raw_date.replace('Z', '')).date()
            except Exception:
                dt_value = date.today()

        session = SessionLocal()
        try:
            _ensure_asset(session, normalized_ticker)

            rate_value = float(exchange_rate or 1.0)
            if rate_value <= 0:
                rate_value = 1.0

            new_tx = Transacties(
                aantal=float(amount or 0),
                ticker=normalized_ticker,
                type=(trade_type or "").upper(),
                portefeuille_id=portfolio_id,
                koers=float(price or 0),
                wisselkoers=rate_value,
                munt=(currency or "EUR").upper(),
                datum_tr=dt_value,
            )
            session.add(new_tx)
            session.commit()
            session.refresh(new_tx)
            result = {
                "transactie_id": new_tx.transactie_id,
                "aantal": new_tx.aantal,
                "ticker": new_tx.ticker,
                "type": new_tx.type,
            }
            return True, result
        finally:
            session.close()
    except Exception as e:
        logging.error(f"Transactie log fout: {e}")
        return False, str(e)


def sign_in_user(email):
    try:
        session = SessionLocal()
        user = session.query(Leden).filter(Leden.email == email).first()
        session.close()
        if user:
            return True, {
                "ledenid": user.ledenid,
                "email": user.email,
                "voornaam": user.voornaam,
                "achternaam": user.achternaam,
                "GSM": user.GSM,
                "created_at": user.created_at.isoformat() if user.created_at else None,
            }
        else:
            return False, "Geen gebruiker gevonden met dit e-mailadres."
    except Exception as e:
        return False, str(e)

def sign_up_user(email, voornaam, achternaam, gsm):
    try:
        session = SessionLocal()
        check = session.query(Leden).filter(Leden.email == email).first()
        if check:
            session.close()
            return False, "Dit e-mailadres is al in gebruik."

        new_user = Leden(
            email=email,
            voornaam=voornaam,
            achternaam=achternaam,
            GSM=gsm
        )
        session.add(new_user)
        session.commit()
        session.close()
        return True, "Gebruiker succesvol aangemaakt."
    except Exception as e:
        session.close()
        return False, str(e)

def list_leden():
    try:
        session = SessionLocal()
        users = session.query(Leden).all()
        session.close()
        result = [
            {
                "ledenid": u.ledenid,
                "email": u.email,
                "voornaam": u.voornaam,
                "achternaam": u.achternaam,
                "GSM": u.GSM,
            }
            for u in users
        ]
        return True, result
    except Exception as e:
        return False, str(e)

def _normalize_group_row(row):
    if not row: return None
    def _to_float(value):
        try:
            return float(value)
        except (TypeError, ValueError):
            return 0.0

    raw_liq = row.get("liq_per_lid")
    if isinstance(raw_liq, str):
        liq_per_lid = raw_liq.strip().lower() in ("true", "1", "t", "yes")
    else:
        liq_per_lid = bool(raw_liq)

    return {
        "id": row.get(GROUP_ID_COLUMN),
        "name": row.get(GROUP_NAME_COLUMN),
        "description": row.get(GROUP_DESCRIPTION_COLUMN),
        "invite_code": row.get(GROUP_CODE_COLUMN),
        "owner_id": row.get(GROUP_OWNER_COLUMN),
        "created_at": row.get("created_at"),
        "portfolio_id": row.get("portefeuille_id"),
        "instap_nav_pct": _to_float(row.get("instap_nav_pct")),
        "instap_liq_pct": _to_float(row.get("instap_liq_pct")),
        "uitstap_nav_pct": _to_float(row.get("uitstap_nav_pct")),
        "uitstap_liq_pct": _to_float(row.get("uitstap_liq_pct")),
        "liq_per_lid": liq_per_lid,
    }

def _normalize_membership_row(row):
    if not row: return None
    return {
        "group_id": row.get(GROUP_ID_COLUMN),
        "member_id": row.get("ledenid"),
        "role": row.get(GROUP_ROLE_COLUMN) or "member",
        "joined_at": row.get("created_at"),
    }

def create_group_record(owner_id, name, description, invite_code):
    try:
        session = SessionLocal()
        new_group = Groep(
            groep_naam=name,
            omschrijving=description,
            invite_code=invite_code,
            owner_lid_id=owner_id,
        )
        session.add(new_group)
        session.commit()
        group_id = new_group.groep_id
        session.close()
        return True, _normalize_group_row({
            "groep_id": new_group.groep_id,
            "groep_naam": new_group.groep_naam,
            "omschrijving": new_group.omschrijving,
            "invite_code": new_group.invite_code,
            "owner_lid_id": new_group.owner_lid_id,
            "created_at": new_group.created_at,
            "portefeuille_id": new_group.portefeuille_id,
            "instap_nav_pct": new_group.instap_nav_pct,
            "instap_liq_pct": new_group.instap_liq_pct,
            "uitstap_nav_pct": new_group.uitstap_nav_pct,
            "uitstap_liq_pct": new_group.uitstap_liq_pct,
            "liq_per_lid": new_group.liq_per_lid,
        })
    except Exception as e:
        return False, str(e)

def get_group_by_code(invite_code):
    try:
        session = SessionLocal()
        group = session.query(Groep).filter(Groep.invite_code == invite_code).first()
        session.close()
        if not group:
            return True, None
        return True, _normalize_group_row({
            "groep_id": group.groep_id,
            "groep_naam": group.groep_naam,
            "omschrijving": group.omschrijving,
            "invite_code": group.invite_code,
            "owner_lid_id": group.owner_lid_id,
            "created_at": group.created_at,
            "portefeuille_id": group.portefeuille_id,
            "instap_nav_pct": group.instap_nav_pct,
            "instap_liq_pct": group.instap_liq_pct,
            "uitstap_nav_pct": group.uitstap_nav_pct,
            "uitstap_liq_pct": group.uitstap_liq_pct,
            "liq_per_lid": group.liq_per_lid,
        })
    except Exception as e:
        return False, str(e)

def get_group_by_id(group_id):
    try:
        session = SessionLocal()
        group = session.query(Groep).filter(Groep.groep_id == group_id).first()
        session.close()
        if not group:
            return True, None
        return True, _normalize_group_row({
            "groep_id": group.groep_id,
            "groep_naam": group.groep_naam,
            "omschrijving": group.omschrijving,
            "invite_code": group.invite_code,
            "owner_lid_id": group.owner_lid_id,
            "created_at": group.created_at,
            "portefeuille_id": group.portefeuille_id,
            "instap_nav_pct": group.instap_nav_pct,
            "instap_liq_pct": group.instap_liq_pct,
            "uitstap_nav_pct": group.uitstap_nav_pct,
            "uitstap_liq_pct": group.uitstap_liq_pct,
            "liq_per_lid": group.liq_per_lid,
        })
    except Exception as e:
        return False, str(e)

def group_code_exists(invite_code):
    try:
        session = SessionLocal()
        exists = session.query(Groep).filter(Groep.invite_code == invite_code).first() is not None
        session.close()
        return True, exists
    except Exception as e:
        return False, str(e)

def get_membership_for_user(ledenid):
    try:
        session = SessionLocal()
        membership = session.query(GroepLeden).filter(GroepLeden.ledenid == ledenid).first()
        session.close()
        if not membership:
            return True, None
        return True, _normalize_membership_row({
            "groep_id": membership.groep_id,
            "ledenid": membership.ledenid,
            "rol": membership.rol,
            "created_at": membership.created_at,
        })
    except Exception as e:
        return False, str(e)

def get_membership_for_user_in_group(ledenid, group_id):
    try:
        session = SessionLocal()
        membership = session.query(GroepLeden).filter(
            GroepLeden.ledenid == ledenid,
            GroepLeden.groep_id == group_id
        ).first()
        session.close()
        if not membership:
            return True, None
        return True, _normalize_membership_row({
            "groep_id": membership.groep_id,
            "ledenid": membership.ledenid,
            "rol": membership.rol,
            "created_at": membership.created_at,
        })
    except Exception as e:
        return False, str(e)

def add_member_to_group(group_id, ledenid, role="member"):
    try:
        session = SessionLocal()
        new_membership = GroepLeden(
            groep_id=group_id,
            ledenid=ledenid,
            rol=role,
        )
        session.add(new_membership)
        session.commit()
        session.close()
        return True, _normalize_membership_row({
            "groep_id": new_membership.groep_id,
            "ledenid": new_membership.ledenid,
            "rol": new_membership.rol,
            "created_at": new_membership.created_at,
        })
    except Exception as e:
        return False, str(e)

def create_group_request(group_id, ledenid, type):
    try:
        session = SessionLocal()
        new_req = GroepAanvragen(
            groep_id=group_id,
            ledenid=ledenid,
            type=type,
            status="pending",
        )
        session.add(new_req)
        session.commit()
        session.close()
        return True, "Aanvraag verstuurd"
    except Exception as e:
        return False, str(e)

def list_group_requests_for_group(group_id):
    try:
        session = SessionLocal()
        requests = session.query(GroepAanvragen).filter(
            GroepAanvragen.groep_id == group_id,
            GroepAanvragen.status == "pending"
        ).all()
        session.close()
        result = [
            {
                "id": r.id,
                "groep_id": r.groep_id,
                "ledenid": r.ledenid,
                "type": r.type,
                "status": r.status,
            }
            for r in requests
        ]
        return True, result
    except Exception as e:
        return False, str(e)

def approve_group_request(req_id, host_id):
    try:
        session = SessionLocal()
        req = session.query(GroepAanvragen).filter(GroepAanvragen.id == req_id).first()
        if not req:
            session.close()
            return False, "Aanvraag niet gevonden"

        # type logica
        if req.type == "join":
            add_member_to_group(req.groep_id, req.ledenid, "member")
        elif req.type == "leave":
            remove_member_from_group(req.groep_id, req.ledenid)

        # aanvraag markeren als afgehandeld
        req.status = "approved"
        req.processed_by = host_id
        session.commit()
        session.close()
        return True, "Goedgekeurd"

    except Exception as e:
        return False, str(e)

def reject_group_request(req_id, host_id):
    try:
        session = SessionLocal()
        req = session.query(GroepAanvragen).filter(GroepAanvragen.id == req_id).first()
        if req:
            req.status = "rejected"
            req.processed_by = host_id
            session.commit()
        session.close()
        return True, "Aanvraag afgewezen."
    except Exception as e:
        return False, str(e)


def initialize_cash_position(group_id, amount=0.0):
    try:
        session = SessionLocal()
        _ensure_asset(session, "CASH", "Contante Positie", "Liquiditeit")
        existing = session.query(Portefeuille).filter(
            Portefeuille.groep_id == group_id,
            Portefeuille.ticker == "CASH"
        ).first()
        
        if existing:
            if existing.quantity is None:
                existing.quantity = float(amount or 0.0)
                session.commit()
            session.close()
            return True, {
                "port_id": existing.port_id,
                "groep_id": existing.groep_id,
                "ticker": existing.ticker,
                "cash_amount": float(existing.quantity or 0.0),
            }
        
        new_cash = Portefeuille(
            groep_id=group_id,
            ticker="CASH",
            quantity=float(amount or 0.0),
            avg_price=0.0,
            transactiekost=0.0,
        )
        session.add(new_cash)
        session.commit()
        session.close()
        return True, {
            "port_id": new_cash.port_id,
            "groep_id": new_cash.groep_id,
            "ticker": new_cash.ticker,
            "cash_amount": float(new_cash.quantity or 0.0),
        }
    except Exception as e:
        return False, str(e)

def list_group_members(group_id):
    try:
        session = SessionLocal()
        memberships = session.query(GroepLeden).filter(GroepLeden.groep_id == group_id).order_by(GroepLeden.created_at).all()
        session.close()
        normalized = [
            _normalize_membership_row({
                "groep_id": m.groep_id,
                "ledenid": m.ledenid,
                "rol": m.rol,
                "created_at": m.created_at,
            })
            for m in memberships
        ]
        return True, normalized
    except Exception as e:
        return False, str(e)

def add_cash_transaction(group_id: int, amount: float, direction: str, description: str | None, created_by: int | None = None):
    try:
        if direction not in ("in", "out"):
            return False, "Ongeldig type"
        
        session = SessionLocal()
        new_tx = Kas(
            groep_id=group_id,
            amount=float(amount),
            type=direction,
            description=description or None,
            created_by=created_by,
        )
        session.add(new_tx)
        session.commit()
        session.close()
        return True, {
            "kas_id": new_tx.kas_id,
            "groep_id": new_tx.groep_id,
            "amount": new_tx.amount,
            "type": new_tx.type,
        }
    except Exception as e:
        return False, str(e)

def list_cash_transactions_for_group(group_id: int, limit: int | None = 200):
    try:
        session = SessionLocal()
        query = session.query(Kas).filter(Kas.groep_id == group_id).order_by(Kas.kas_id.desc())
        if limit:
            query = query.limit(limit)
        transactions = query.all()
        session.close()
        result = [
            {
                "kas_id": t.kas_id,
                "groep_id": t.groep_id,
                "date": t.date.isoformat() if t.date else None,
                "amount": t.amount,
                "type": t.type,
                "description": t.description,
            }
            for t in transactions
        ]
        return True, result
    except Exception as e:
        return False, str(e)

def get_cash_balance_for_group(group_id: int):
    try:
        session = SessionLocal()
        transactions = session.query(Kas).filter(Kas.groep_id == group_id).all()
        session.close()
        total = 0.0
        for t in transactions:
            amt = float(t.amount or 0)
            if (t.type or "").lower() == "in":
                total += amt
            else:
                total -= amt
        return True, total
    except Exception as e:
        return False, str(e)

def count_group_members(group_id):
    try:
        session = SessionLocal()
        count = session.query(GroepLeden).filter(GroepLeden.groep_id == group_id).count()
        session.close()
        return True, count
    except Exception as e:
        return False, str(e)

def list_memberships_for_user(ledenid):
    try:
        session = SessionLocal()
        memberships = session.query(GroepLeden).filter(GroepLeden.ledenid == ledenid).order_by(GroepLeden.created_at).all()
        session.close()
        normalized = [
            _normalize_membership_row({
                "groep_id": m.groep_id,
                "ledenid": m.ledenid,
                "rol": m.rol,
                "created_at": m.created_at,
            })
            for m in memberships
        ]
        return True, normalized
    except Exception as e:
        return False, str(e)

def list_groups_by_ids(group_ids):
    try:
        if not group_ids:
            return True, []
        session = SessionLocal()
        groups = session.query(Groep).filter(Groep.groep_id.in_(group_ids)).all()
        session.close()
        normalized = [
            _normalize_group_row({
                "groep_id": g.groep_id,
                "groep_naam": g.groep_naam,
                "omschrijving": g.omschrijving,
                "invite_code": g.invite_code,
                "owner_lid_id": g.owner_lid_id,
                "created_at": g.created_at,
            })
            for g in groups
        ]
        return True, normalized
    except Exception as e:
        return False, str(e)

def remove_member_from_group(group_id: int, member_id: int):
    try:
        session = SessionLocal()
        session.query(GroepLeden).filter(
            GroepLeden.groep_id == group_id,
            GroepLeden.ledenid == member_id
        ).delete()
        session.commit()
        session.close()
        return True, "Lid verwijderd"
    except Exception as e:
        return False, str(e)

def delete_group(group_id: int):
    try:
        session = SessionLocal()
        session.query(GroepLeden).filter(GroepLeden.groep_id == group_id).delete()
        session.query(Portefeuille).filter(Portefeuille.groep_id == group_id).delete()
        session.query(Groep).filter(Groep.groep_id == group_id).delete()
        session.commit()
        session.close()
        return True, "Groep verwijderd"
    except Exception as e:
        return False, str(e)


def update_group_name(group_id: int, new_name: str):
    """Update the group's name (only modifies the Groep table). Returns (True, normalized_group) or (False, message)."""
    try:
        if not new_name or not str(new_name).strip():
            return False, "Naam verplicht"
        session = SessionLocal()
        grp = session.query(Groep).filter(Groep.groep_id == group_id).first()
        if not grp:
            session.close()
            return False, "Groep niet gevonden"
        grp.groep_naam = str(new_name).strip()
        session.commit()
        normalized = _normalize_group_row({
            "groep_id": grp.groep_id,
            "groep_naam": grp.groep_naam,
            "omschrijving": grp.omschrijving,
            "invite_code": grp.invite_code,
            "owner_lid_id": grp.owner_lid_id,
            "created_at": grp.created_at,
        })
        session.close()
        return True, normalized
    except Exception as e:
        return False, str(e)


def _serialize_portefeuille_row(position: Portefeuille, asset: Activa | None = None) -> dict:
    asset_obj = asset or position.asset
    return {
        "port_id": position.port_id,
        "ticker": position.ticker,
        "quantity": float(position.quantity or 0),
        "avg_price": float(position.avg_price or 0),
        "groep_id": position.groep_id,
        "transactiekost": float(position.transactiekost or 0),
        "asset": {
            "ticker": asset_obj.ticker if asset_obj else position.ticker,
            "name": getattr(asset_obj, "name", None),
            "sector": getattr(asset_obj, "sector", None),
        },
    }


def add_portfolio_position(group_id, ticker, quantity, price, user_id, *, asset_name=None, asset_sector=None, transaction_cost=None):
    try:
        quantity_val = float(quantity or 0)
        if quantity_val == 0:
            return False, "Aantal moet groter dan 0 zijn"
        price_val = float(price or 0)
        normalized = _normalize_ticker(ticker)
        session = SessionLocal()
        asset_meta = _ensure_asset(session, normalized, asset_name, asset_sector)
        existing = session.query(Portefeuille).filter(
            Portefeuille.groep_id == group_id,
            Portefeuille.ticker == normalized
        ).first()
        
        if existing:
            old_qty = float(existing.quantity or 0)
            new_qty = old_qty + quantity_val
            existing.quantity = new_qty
            if price_val:
                existing.avg_price = price_val
            if transaction_cost is not None:
                existing.transactiekost = float(existing.transactiekost or 0) + float(transaction_cost or 0)
            session.commit()
            session.refresh(existing)
            result = _serialize_portefeuille_row(existing, asset_meta)
            logging.info(f"Updated {normalized}: Old Qty {old_qty} -> New Qty {new_qty}")
        else:
            new_pos = Portefeuille(
                groep_id=group_id,
                ticker=normalized,
                quantity=quantity_val,
                avg_price=price_val,
                transactiekost=float(transaction_cost or 0) if transaction_cost is not None else 0,
            )
            session.add(new_pos)
            session.commit()
            session.refresh(new_pos)
            result = _serialize_portefeuille_row(new_pos, asset_meta)
            logging.info(f"Inserted new position: {normalized}")
        
        session.close()
        return True, result
    except Exception as e:
        logging.error(f"Fout bij opslaan {ticker}: {e}")
        return False, str(e)

def koersen_updater(group_id):
    """Haalt live koersen op via Yahoo Finance en update de Portefeuille."""
    try:
        session = SessionLocal()
        positions = session.query(Portefeuille).filter(Portefeuille.groep_id == group_id).all()

        if not positions:
            session.close()
            return True, "Geen posities om te updaten."

        updated_count = 0
        failed = []
        for pos in positions:
            ticker = _normalize_ticker(pos.ticker)
            if not ticker or ticker == 'CASH':
                continue

            # Haal laatste koers via market_data
            current_price = get_latest_price(ticker)

            if current_price is not None:
                updated_count += 1
            else:
                failed.append(ticker)

        session.close()
        if failed:
            return True, f"Laatste koersen opgehaald voor {updated_count} tickers; {len(failed)} tickers mislukt."
        return True, f"Laatste koersen opgehaald voor {updated_count} tickers."

    except Exception as e:
        return False, f"Fout bij updaten koersen: {str(e)}"


def update_member_role(group_id, member_id, new_role):
    """Update de rol van een groepslid."""
    try:
        session = SessionLocal()
        membership = session.query(GroepLeden).filter(
            GroepLeden.groep_id == group_id,
            GroepLeden.ledenid == member_id
        ).first()
        
        if membership:
            membership.rol = new_role
            session.commit()
            session.close()
            return True, f"Rol succesvol gewijzigd naar {new_role}"
        
        session.close()
        return False, "Kon rol niet wijzigen (lid niet gevonden)."
    except Exception as e:
        return False, str(e)