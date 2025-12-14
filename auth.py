import logging
from datetime import date, datetime
from sqlalchemy.orm import Session
from models import SessionLocal, Leden, Groep, GroepLeden, Portefeuille, Transacties, Kas, GroepAanvragen
from market_data import get_latest_price, get_currency_rate

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


def log_portfolio_transaction(portfolio_id, ticker, trade_type, amount, price, exchange_rate=1.0, currency="EUR", datum_tr=None):
    """Logt een transactie in de Transacties tabel."""
    try:
        if not portfolio_id and not ticker:
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
            new_tx = Transacties(
                aantal=amount,
                ticker=ticker,
                type=trade_type.upper(),
                portefeuille_id=portfolio_id,
                koers=price,
                wisselkoers=exchange_rate,
                munt=currency,
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


def _build_cash_payload(group_id, amount):
    return {
        "ticker": "CASH",
        "name": "Cash",
        "sector": "Cash",
        "quantity": 0,
        "avg_price": 0,
        "current_price": amount,
        "transactiekost": 0,
        "groep_id": group_id,
    }

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
    return {
        "id": row.get(GROUP_ID_COLUMN),
        "name": row.get(GROUP_NAME_COLUMN),
        "description": row.get(GROUP_DESCRIPTION_COLUMN),
        "invite_code": row.get(GROUP_CODE_COLUMN),
        "owner_id": row.get(GROUP_OWNER_COLUMN),
        "created_at": row.get("created_at"),
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
        existing = session.query(Portefeuille).filter(
            Portefeuille.groep_id == group_id,
            Portefeuille.ticker == "CASH"
        ).first()
        
        if existing:
            if existing.current_price is None:
                existing.current_price = amount
                session.commit()
            session.close()
            return True, {
                "port_id": existing.port_id,
                "groep_id": existing.groep_id,
                "ticker": existing.ticker,
                "current_price": existing.current_price,
            }
        
        payload = _build_cash_payload(group_id, amount)
        new_cash = Portefeuille(
            groep_id=group_id,
            ticker=payload["ticker"],
            name=payload["name"],
            sector=payload["sector"],
            quantity=payload["quantity"],
            avg_price=payload["avg_price"],
            current_price=payload["current_price"],
            transactiekost=payload["transactiekost"],
        )
        session.add(new_cash)
        session.commit()
        session.close()
        return True, {
            "port_id": new_cash.port_id,
            "groep_id": new_cash.groep_id,
            "ticker": new_cash.ticker,
            "current_price": new_cash.current_price,
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

def add_portfolio_position(group_id, ticker, quantity, price, user_id):
    try:
        quantity_int = int(float(quantity))
        session = SessionLocal()
        existing = session.query(Portefeuille).filter(
            Portefeuille.groep_id == group_id,
            Portefeuille.ticker == ticker
        ).first()
        
        if existing:
            old_qty = float(existing.quantity or 0)
            new_qty = int(old_qty) + quantity_int
            existing.quantity = new_qty
            existing.avg_price = price
            existing.current_price = price
            session.commit()
            logging.info(f"Updated {ticker}: Old Qty {old_qty} -> New Qty {new_qty}")
        else:
            new_pos = Portefeuille(
                groep_id=group_id,
                ticker=ticker,
                name=ticker,
                quantity=quantity_int,
                avg_price=price,
                current_price=price,
                sector="Onbekend",
                transactiekost=0,
            )
            session.add(new_pos)
            session.commit()
            logging.info(f"Inserted new position: {ticker}")
        
        session.close()
        return True, "Succes"
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
        for pos in positions:
            ticker = (pos.ticker or '').upper()
            if not ticker or ticker == 'CASH':
                continue

            # Haal laatste koers via market_data
            current_price = get_latest_price(ticker)

            # Munt bepalen op basis van laatste transactie
            currency = None
            try:
                tx = session.query(Transacties).filter(Transacties.ticker == ticker).order_by(Transacties.transactie_id.desc()).first()
                if tx:
                    currency = (tx.munt or "").upper() or None
            except Exception:
                currency = None

            # FX rate (voor info, niet in DB geschreven)
            fx_rate = None
            if currency and currency != "EUR":
                try:
                    fx_rate = get_currency_rate(currency)
                except Exception as e:
                    logging.warning(f"FX fetch fout voor {ticker} ({currency}): {e}")
            elif currency == "EUR":
                fx_rate = 1.0

            # Update positie
            if current_price is not None:
                try:
                    pos.current_price = float(current_price)
                    session.commit()
                    updated_count += 1
                except Exception as e:
                    logging.error(f"DB update fout voor {ticker}: {e}")

        session.close()
        return True, f"{updated_count} koersen succesvol bijgewerkt."

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