import os
from supabase import create_client, Client
import logging
import requests
try:
    import yfinance as yf  # type: ignore
    YFINANCE_AVAILABLE = True
except Exception as e:
    print(f"⚠️ yfinance niet geladen in auth.py ({e}); fallback actief.")
    yf = None  # type: ignore
    YFINANCE_AVAILABLE = False

# --- CONFIGURATIE ---
SUPABASE_URL = "https://bpbvlfptoacijyqyugew.supabase.co"
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJwYnZsZnB0b2FjaWp5cXl1Z2V3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjA2NDk2NzAsImV4cCI6MjA3NjIyNTY3MH0.6_z9bE3aB4QMt5ASE0bxM6Ds8Tf7189sBDUVLrUeU-M"

try:
    supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)
except Exception as e:
    print(f"Supabase init error: {e}")

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

def log_portfolio_transaction(portfolio_id, ticker, trade_type, amount, price, exchange_rate=1.0, currency="EUR", datum_tr=None):
    """Logt een transactie in de Transacties tabel.

    Vereiste kolommen (gepland): transactie_id (PK), datum_tr (timestamptz), aantal, ticker, type,
    portefeuille_id, koers, wisselkoers, munt.
    """
    try:
        if not portfolio_id and not ticker:
            return False, "Portfolio ID of ticker vereist"
        # Normaliseer of vul datum_tr in (fallback: vandaag 00:00:00Z)
        dt_value = None
        try:
            s = (datum_tr or "").strip()
            if not s:
                from datetime import date
                s = date.today().isoformat()  # YYYY-MM-DD
            if len(s) == 10 and s[4] == '-' and s[7] == '-':
                dt_value = s + "T00:00:00Z"
            else:
                dt_value = s
        except Exception:
            dt_value = None

        # Zorg dat currency steeds is ingevuld; indien leeg, haal op via Yahoo
        try:
            cur = (currency or "").strip().upper()
            if not cur:
                r = requests.get(f"https://query1.finance.yahoo.com/v7/finance/quote?symbols={ticker}", timeout=6)
                j = r.json()
                q = (j.get("quoteResponse", {}) or {}).get("result", [])
                if q:
                    cur = (q[0].get("currency") or "EUR").upper()
            currency = cur or "EUR"
        except Exception:
            currency = (currency or "EUR").upper()

        payload = {
            "aantal": amount,
            "ticker": ticker,
            "type": trade_type.upper(),
            "portefeuille_id": portfolio_id,
            "koers": price,
            "wisselkoers": exchange_rate,
            "munt": currency
        }
        # Datum altijd meesturen om NOT NULL te vermijden
        if dt_value:
            payload["datum_tr"] = dt_value
        response = supabase.table(TRANSACTION_TABLE).insert(payload).execute()
        if response.data:
            # Zorg dat Portefeuille.munt gezet wordt voor deze positie
            try:
                cur = (currency or "EUR").upper()
                if portfolio_id:
                    supabase.table(PORTFOLIO_TABLE).update({"munt": cur}).eq("port_id", portfolio_id).execute()
                else:
                    supabase.table(PORTFOLIO_TABLE).update({"munt": cur}).eq("ticker", (ticker or "").upper()).execute()
                # Voeg munt toe aan Wisselkoersen indien niet aanwezig (WK pas bij refresh)
                try:
                    w = supabase.table("Wisselkoersen").select("munt").eq("munt", cur).limit(1).execute()
                    if not (w.data and len(w.data) > 0):
                        supabase.table("Wisselkoersen").insert({"munt": cur}).execute()
                except Exception as _we:
                    logging.warning(f"Kon munt '{cur}' niet upserten in Wisselkoersen: {_we}")
            except Exception as _e:
                logging.warning(f"Kon Portefeuille.munt niet bijwerken: {_e}")
            return True, response.data[0]
        return False, "Insert mislukt"
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
        response = supabase.table('Leden').select("*").eq('email', email).execute()
        if response.data and len(response.data) > 0:
            return True, response.data[0]
        else:
            return False, "Geen gebruiker gevonden met dit e-mailadres."
    except Exception as e:
        return False, str(e)

def sign_up_user(email, voornaam, achternaam, gsm):
    try:
        check = supabase.table('Leden').select("*").eq('email', email).execute()
        if check.data and len(check.data) > 0:
            return False, "Dit e-mailadres is al in gebruik."

        new_user = {
            "email": email,
            "voornaam": voornaam,
            "achternaam": achternaam,
            "GSM": gsm
        }
        response = supabase.table('Leden').insert(new_user).execute()
        return True, "Gebruiker succesvol aangemaakt."
    except Exception as e:
        return False, str(e)

def list_leden():
    try:
        response = supabase.table('Leden').select("*").execute()
        return True, response.data
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
        payload = {
            GROUP_NAME_COLUMN: name,
            GROUP_DESCRIPTION_COLUMN: description,
            GROUP_CODE_COLUMN: invite_code,
            GROUP_OWNER_COLUMN: owner_id,
        }
        response = supabase.table(GROUP_TABLE).insert(payload).execute()
        if not response.data: return False, "Kon de groep niet opslaan."
        return True, _normalize_group_row(response.data[0])
    except Exception as e:
        return False, str(e)

def get_group_by_code(invite_code):
    try:
        response = supabase.table(GROUP_TABLE).select("*").eq(GROUP_CODE_COLUMN, invite_code).limit(1).execute()
        if not response.data: return True, None
        return True, _normalize_group_row(response.data[0])
    except Exception as e:
        return False, str(e)

def get_group_by_id(group_id):
    try:
        response = supabase.table(GROUP_TABLE).select("*").eq(GROUP_ID_COLUMN, group_id).limit(1).execute()
        if not response.data: return True, None
        return True, _normalize_group_row(response.data[0])
    except Exception as e:
        return False, str(e)

def group_code_exists(invite_code):
    try:
        response = supabase.table(GROUP_TABLE).select(GROUP_CODE_COLUMN).eq(GROUP_CODE_COLUMN, invite_code).limit(1).execute()
        return True, bool(response.data)
    except Exception as e:
        return False, str(e)

def get_membership_for_user(ledenid):
    try:
        response = supabase.table(GROUP_MEMBER_TABLE).select("*").eq("ledenid", ledenid).limit(1).execute()
        if not response.data: return True, None
        return True, _normalize_membership_row(response.data[0])
    except Exception as e:
        return False, str(e)

def get_membership_for_user_in_group(ledenid, group_id):
    try:
        response = supabase.table(GROUP_MEMBER_TABLE).select("*").eq("ledenid", ledenid).eq(GROUP_ID_COLUMN, group_id).limit(1).execute()
        if not response.data: return True, None
        return True, _normalize_membership_row(response.data[0])
    except Exception as e:
        return False, str(e)

def add_member_to_group(group_id, ledenid, role="member"):
    try:
        payload = {
            GROUP_ID_COLUMN: group_id,
            "ledenid": ledenid,
            GROUP_ROLE_COLUMN: role,
        }
        response = supabase.table(GROUP_MEMBER_TABLE).insert(payload).execute()
        if not response.data: return False, "Kon het lid niet toevoegen."
        return True, _normalize_membership_row(response.data[0])
    except Exception as e:
        return False, str(e)

def create_group_request(group_id, ledenid, type):
    try:
        payload = {
            "groep_id": group_id,
            "ledenid": ledenid,
            "type": type,
            "status": "pending"
        }
        res = supabase.table("groepsaanvragen").insert(payload).execute()
        return True, "Aanvraag verstuurd"
    except Exception as e:
        return False, str(e)

def list_group_requests_for_group(group_id):
    try:
        res = supabase.table("groepsaanvragen").select("*").eq("groep_id", group_id).eq("status", "pending").execute()
        return True, res.data
    except Exception as e:
        return False, str(e)

def approve_group_request(req_id, host_id):
    try:
        # aanvraag ophalen
        res = supabase.table("groepsaanvragen").select("*").eq("id", req_id).limit(1).execute()
        if not res.data:
            return False, "Aanvraag niet gevonden"

        r = res.data[0]

        # type logica
        if r["type"] == "join":
            add_member_to_group(r["groep_id"], r["ledenid"], "member")

        elif r["type"] == "leave":
            remove_member_from_group(r["groep_id"], r["ledenid"])

        # aanvraag markeren als afgehandeld
        supabase.table("groepsaanvragen").update({
            "status": "approved",
            "processed_by": host_id
        }).eq("id", req_id).execute()

        return True, "Goedgekeurd"

    except Exception as e:
        return False, str(e)


def initialize_cash_position(group_id, amount=0.0):
    try:
        existing = supabase.table(PORTFOLIO_TABLE).select("port_id", "current_price").eq("groep_id", group_id).eq("ticker", "CASH").limit(1).execute()
        if existing.data:
            current_id = existing.data[0].get("port_id")
            needs_update = existing.data[0].get("current_price") is None
            if needs_update and current_id is not None:
                supabase.table(PORTFOLIO_TABLE).update({"current_price": amount}).eq("port_id", current_id).execute()
            return True, existing.data[0]
        payload = _build_cash_payload(group_id, amount)
        response = supabase.table(PORTFOLIO_TABLE).insert(payload).execute()
        if not response.data: return False, "Cashpositie kon niet worden aangemaakt."
        return True, response.data[0]
    except Exception as e:
        return False, str(e)

def list_group_members(group_id):
    try:
        response = supabase.table(GROUP_MEMBER_TABLE).select("*").eq(GROUP_ID_COLUMN, group_id).order("created_at").execute()
        normalized = [_normalize_membership_row(row) for row in (response.data or [])]
        return True, normalized
    except Exception as e:
        return False, str(e)

def add_cash_transaction(group_id: int, amount: float, direction: str, description: str | None, created_by: int | None = None):
    try:
        if direction not in ("in", "out"): return False, "Ongeldig type"
        payload = {
            "groep_id": group_id,
            "amount": float(amount),
            "type": direction,
            "description": description or None,
        }
        if created_by is not None: payload["created_by"] = created_by
        response = supabase.table(CASH_TX_TABLE).insert(payload).execute()
        if not response.data: return False, "Kon transactie niet opslaan"
        return True, response.data[0]
    except Exception as e:
        return False, str(e)

def list_cash_transactions_for_group(group_id: int, limit: int | None = 200):
    try:
        query = supabase.table(CASH_TX_TABLE).select("date, amount, type, description").eq("groep_id", group_id).order("kas_id", desc=True)
        if limit: query = query.limit(limit)
        response = query.execute()
        return True, response.data or []
    except Exception as e:
        return False, str(e)

def get_cash_balance_for_group(group_id: int):
    try:
        response = supabase.table(CASH_TX_TABLE).select("amount, type").eq("groep_id", group_id).execute()
        total = 0.0
        for row in (response.data or []):
            amt = float(row.get("amount") or 0)
            if (row.get("type") or "").lower() == "in": total += amt
            else: total -= amt
        return True, total
    except Exception as e:
        return False, str(e)

def count_group_members(group_id):
    try:
        response = supabase.table(GROUP_MEMBER_TABLE).select("ledenid", count="exact").eq(GROUP_ID_COLUMN, group_id).execute()
        if hasattr(response, "count") and response.count is not None: return True, response.count
        return True, len(response.data or [])
    except Exception as e:
        return False, str(e)

def list_memberships_for_user(ledenid):
    try:
        response = supabase.table(GROUP_MEMBER_TABLE).select("*").eq("ledenid", ledenid).order("created_at").execute()
        normalized = [_normalize_membership_row(row) for row in (response.data or [])]
        return True, normalized
    except Exception as e:
        return False, str(e)

def list_groups_by_ids(group_ids):
    try:
        if not group_ids: return True, []
        response = supabase.table(GROUP_TABLE).select("*").in_(GROUP_ID_COLUMN, group_ids).execute()
        normalized = [_normalize_group_row(row) for row in (response.data or [])]
        return True, normalized
    except Exception as e:
        return False, str(e)

def remove_member_from_group(group_id: int, member_id: int):
    try:
        response = supabase.table("groep_leden").delete().eq("groep_id", group_id).eq("ledenid", member_id).execute()
        return True, response.data
    except Exception as e:
        return False, str(e)

def delete_group(group_id: int):
    try:
        supabase.table("groep_leden").delete().eq("groep_id", group_id).execute()
        supabase.table("Portefeuille").delete().eq("groep_id", group_id).execute()
        response = supabase.table("Groep").delete().eq("groep_id", group_id).execute()
        return True, response.data
    except Exception as e:
        return False, str(e)

def add_portfolio_position(group_id, ticker, quantity, price, user_id):
    try:
        quantity_int = int(float(quantity))
        existing = supabase.table(PORTFOLIO_TABLE).select("*").eq("groep_id", group_id).eq("ticker", ticker).limit(1).execute()
        
        if existing.data and len(existing.data) > 0:
            current_row = existing.data[0]
            # Geen gemiddelde aankoopprijs meer: we verhogen aantallen en houden avg_price op laatste prijs.
            old_qty = float(current_row.get("quantity") or 0)
            new_qty = int(old_qty) + quantity_int
            new_avg = price  # houd simpel
            
            row_id = current_row.get("port_id") or current_row.get("id")
            if row_id:
                supabase.table(PORTFOLIO_TABLE).update({
                    "quantity": new_qty, 
                    "avg_price": new_avg,
                    "current_price": price 
                }).eq("port_id", row_id).execute()
            logging.info(f"Updated {ticker}: Old Qty {old_qty} -> New Qty {new_qty}")
        else:
            payload = {
                "groep_id": group_id,
                "ticker": ticker,
                "name": ticker, 
                "quantity": quantity_int,
                "avg_price": price,  # blijft vereist door schema maar gelijk aan current_price
                "current_price": price,
                "sector": "Onbekend", 
                "transactiekost": 0
            }
            supabase.table(PORTFOLIO_TABLE).insert(payload).execute()
            logging.info(f"Inserted new position: {ticker}")
        return True, "Succes"
    except Exception as e:
        logging.error(f"Fout bij opslaan {ticker}: {e}")
        return False, str(e)

def koersen_updater(group_id):
    """Haalt live koersen op via Yahoo Finance en update de database."""
    try:
        # Haal alle posities van de groep op
        response = supabase.table(PORTFOLIO_TABLE).select("*").eq("groep_id", group_id).execute()
        positions = response.data
        
        if not positions:
            return True, "Geen posities om te updaten."
            
        updated_count = 0
        for pos in positions:
            ticker = pos.get('ticker')
            if not ticker or ticker == 'CASH':
                continue

            current_price = None
            if YFINANCE_AVAILABLE and yf is not None:
                try:
                    stock = yf.Ticker(ticker)
                    if hasattr(stock, 'fast_info'):
                        current_price = getattr(stock.fast_info, 'last_price', None)
                    if current_price is None:
                        hist = stock.history(period="1d")
                        if not hist.empty:
                            current_price = float(hist['Close'].iloc[-1])
                except Exception as e:
                    print(f"⚠️ yfinance fout voor {ticker}: {e}; probeer HTTP.")

            if current_price is None:
                # HTTP fallback
                try:
                    url = f"https://query1.finance.yahoo.com/v7/finance/quote?symbols={ticker}"
                    r = requests.get(url, timeout=5)
                    jd = r.json()
                    results = jd.get("quoteResponse", {}).get("result", [])
                    if results:
                        item = results[0]
                        current_price = item.get("regularMarketPrice") or item.get("postMarketPrice") or item.get("bid") or item.get("ask")
                except Exception as e:
                    print(f"⚠️ HTTP fallback fout voor {ticker}: {e}")

            # Bepaal munt en wisselkoers op basis van laatste transactie voor deze ticker
            currency = None
            try:
                tx = supabase.table(TRANSACTION_TABLE).select("munt,ticker").eq("ticker", ticker).order("datum_tr", desc=True).limit(1).execute()
                if tx and tx.data:
                    currency = (tx.data[0].get("munt") or "").upper() or None
            except Exception:
                currency = None

            fx_rate = None
            if currency and currency != "EUR":
                try:
                    pair = f"EUR{currency}=X"
                    url = f"https://query1.finance.yahoo.com/v7/finance/quote?symbols={pair}"
                    r = requests.get(url, timeout=5)
                    jd = r.json()
                    results = jd.get("quoteResponse", {}).get("result", [])
                    if results:
                        item = results[0]
                        fx_rate = item.get("regularMarketPrice") or item.get("postMarketPrice") or item.get("bid") or item.get("ask")
                        if fx_rate is not None:
                            fx_rate = float(fx_rate)
                except Exception as e:
                    print(f"⚠️ FX fetch fout voor {ticker} ({currency}): {e}")
            elif currency == "EUR":
                fx_rate = 1.0

            # Update alleen de huidige prijs (kolom wisselkoers bestaat niet meer)
            if current_price is not None:
                row_id = pos.get('port_id') or pos.get('id')
                if row_id:
                    payload = {}
                    payload["current_price"] = current_price
                    supabase.table(PORTFOLIO_TABLE).update(payload).eq("port_id", row_id).execute()
                    updated_count += 1
                    msg_parts = []
                    msg_parts.append(f"prijs {current_price:.2f}")
                    print(f"✅ {ticker} geupdate: {', '.join(msg_parts)}")
                
        return True, f"{updated_count} koersen succesvol bijgewerkt."
        
    except Exception as e:
        return False, f"Fout bij updaten koersen: {str(e)}"
    
    # In auth.py

def update_member_role(group_id, member_id, new_role):
    """Update de rol van een groepslid (bijv. naar 'host' of 'member')."""
    try:
        # Check eerst of het lid bestaat in de groep
        response = supabase.table(GROUP_MEMBER_TABLE).update({
            GROUP_ROLE_COLUMN: new_role
        }).eq(GROUP_ID_COLUMN, group_id).eq("ledenid", member_id).execute()
        
        if response.data:
            return True, f"Rol succesvol gewijzigd naar {new_role}"
        return False, "Kon rol niet wijzigen (lid niet gevonden of error)."
    except Exception as e:
        return False, str(e)

# Zorg er ook voor dat je in de bestaande functie 'get_membership_for_user_in_group' 
# zeker weet dat de 'rol' wordt opgehaald (dat gebeurt al door select("*")).

# --- IN auth.py ---

# Voeg deze functie toe om aanvragen af te wijzen
def reject_group_request(req_id, host_id):
    try:
        # We zetten de status op 'rejected' (of je kan .delete() gebruiken als je het weg wilt)
        supabase.table("groepsaanvragen").update({
            "status": "rejected",
            "processed_by": host_id
        }).eq("id", req_id).execute()
        return True, "Aanvraag afgewezen."
    except Exception as e:
        return False, str(e)

# Voeg deze functie toe om rollen aan te passen (Host maken)
def update_member_role(group_id, member_id, new_role):
    try:
        response = supabase.table("groep_leden").update({
            "rol": new_role
        }).eq("groep_id", group_id).eq("ledenid", member_id).execute()
        return True, f"Rol gewijzigd naar {new_role}."
    except Exception as e:
        return False, str(e)