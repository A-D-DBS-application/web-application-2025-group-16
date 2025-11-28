import os
from supabase import create_client, Client
import logging

# --- CONFIGURATIE ---
# Vul hier je Supabase URL en SERVICE KEY in
SUPABASE_URL = "https://bpbvlfptoacijyqyugew.supabase.co"
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJwYnZsZnB0b2FjaWp5cXl1Z2V3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjA2NDk2NzAsImV4cCI6MjA3NjIyNTY3MH0.6_z9bE3aB4QMt5ASE0bxM6Ds8Tf7189sBDUVLrUeU-M"

# Initialiseer Supabase
try:
    # Debug print om te checken of de key geladen is
    print(f"--- DEBUG: Auth script start. URL ingesteld? {'Ja' if SUPABASE_URL else 'Nee'}")
    
    supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)
    print("--- DEBUG: Supabase verbinding succesvol ---")
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
    """Zoekt een gebruiker in de tabel 'Leden' op basis van email"""
    try:
        response = supabase.table('Leden').select("*").eq('email', email).execute()
        # Als we data terugkrijgen, is de gebruiker gevonden
        if response.data and len(response.data) > 0:
            return True, response.data[0] # Return de eerste gebruiker
        else:
            return False, "Geen gebruiker gevonden met dit e-mailadres."
    except Exception as e:
        return False, str(e)

def sign_up_user(email, voornaam, achternaam, gsm):
    """Maakt een nieuwe gebruiker aan in de tabel 'Leden'"""
    try:
        # Eerst checken of email al bestaat
        check = supabase.table('Leden').select("*").eq('email', email).execute()
        if check.data and len(check.data) > 0:
            return False, "Dit e-mailadres is al in gebruik."

        # Nieuwe gebruiker invoegen
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
    """Haalt alle leden op"""
    try:
        response = supabase.table('Leden').select("*").execute()
        return True, response.data
    except Exception as e:
        return False, str(e)


def _normalize_group_row(row):
    if not row:
        return None
    return {
        "id": row.get(GROUP_ID_COLUMN),
        "name": row.get(GROUP_NAME_COLUMN),
        "description": row.get(GROUP_DESCRIPTION_COLUMN),
        "invite_code": row.get(GROUP_CODE_COLUMN),
        "owner_id": row.get(GROUP_OWNER_COLUMN),
        "created_at": row.get("created_at"),
    }


def _normalize_membership_row(row):
    if not row:
        return None
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
        if not response.data:
            return False, "Kon de groep niet opslaan."
        return True, _normalize_group_row(response.data[0])
    except Exception as e:
        return False, str(e)


def get_group_by_code(invite_code):
    try:
        response = (supabase
                    .table(GROUP_TABLE)
                    .select("*")
                    .eq(GROUP_CODE_COLUMN, invite_code)
                    .limit(1)
                    .execute())
        if not response.data:
            return True, None
        return True, _normalize_group_row(response.data[0])
    except Exception as e:
        return False, str(e)


def get_group_by_id(group_id):
    try:
        response = (supabase
                    .table(GROUP_TABLE)
                    .select("*")
                    .eq(GROUP_ID_COLUMN, group_id)
                    .limit(1)
                    .execute())
        if not response.data:
            return True, None
        return True, _normalize_group_row(response.data[0])
    except Exception as e:
        return False, str(e)


def group_code_exists(invite_code):
    try:
        response = (supabase
                    .table(GROUP_TABLE)
                    .select(GROUP_CODE_COLUMN)
                    .eq(GROUP_CODE_COLUMN, invite_code)
                    .limit(1)
                    .execute())
        return True, bool(response.data)
    except Exception as e:
        return False, str(e)


def get_membership_for_user(ledenid):
    try:
        response = (supabase
                    .table(GROUP_MEMBER_TABLE)
                    .select("*")
                    .eq("ledenid", ledenid)
                    .limit(1)
                    .execute())
        if not response.data:
            return True, None
        return True, _normalize_membership_row(response.data[0])
    except Exception as e:
        return False, str(e)


def get_membership_for_user_in_group(ledenid, group_id):
    try:
        response = (supabase
                    .table(GROUP_MEMBER_TABLE)
                    .select("*")
                    .eq("ledenid", ledenid)
                    .eq(GROUP_ID_COLUMN, group_id)
                    .limit(1)
                    .execute())
        if not response.data:
            return True, None
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
        if not response.data:
            return False, "Kon het lid niet toevoegen."
        return True, _normalize_membership_row(response.data[0])
    except Exception as e:
        return False, str(e)


def initialize_cash_position(group_id, amount=0.0):
    try:
        existing = (supabase
                    .table(PORTFOLIO_TABLE)
                    .select("port_id", "current_price")
                    .eq("groep_id", group_id)
                    .eq("ticker", "CASH")
                    .limit(1)
                    .execute())
        if existing.data:
            # Zorg dat er minstens een bedrag is ingesteld
            current_id = existing.data[0].get("port_id")
            needs_update = existing.data[0].get("current_price") is None
            if needs_update and current_id is not None:
                supabase.table(PORTFOLIO_TABLE).update({"current_price": amount}).eq("port_id", current_id).execute()
            return True, existing.data[0]
        payload = _build_cash_payload(group_id, amount)
        response = supabase.table(PORTFOLIO_TABLE).insert(payload).execute()
        if not response.data:
            return False, "Cashpositie kon niet worden aangemaakt."
        return True, response.data[0]
    except Exception as e:
        return False, str(e)


def list_group_members(group_id):
    try:
        response = (supabase
                    .table(GROUP_MEMBER_TABLE)
                    .select("*")
                    .eq(GROUP_ID_COLUMN, group_id)
                    .order("created_at")
                    .execute())
        normalized = [_normalize_membership_row(row) for row in (response.data or [])]
        return True, normalized
    except Exception as e:
        return False, str(e)


# --- KAS (CASHBOX) HULPFUNCTIES ---
def add_cash_transaction(group_id: int, amount: float, direction: str, description: str | None, created_by: int | None = None):
    try:
        if direction not in ("in", "out"):
            return False, "Ongeldig type; gebruik 'in' of 'out'"
        payload = {
            "groep_id": group_id,
            "amount": float(amount),
            "type": direction,
            "description": description or None,
        }
        if created_by is not None:
            payload["created_by"] = created_by
        response = supabase.table(CASH_TX_TABLE).insert(payload).execute()
        if not response.data:
            return False, "Kon transactie niet opslaan"
        return True, response.data[0]
    except Exception as e:
        return False, str(e)


def list_cash_transactions_for_group(group_id: int, limit: int | None = 200):
    try:
        query = (
            supabase
            .table(CASH_TX_TABLE)
            .select("date, amount, type, description")
            .eq("groep_id", group_id)
            .order("kas_id", desc=True)
        )
        if limit:
            query = query.limit(limit)
        response = query.execute()
        return True, response.data or []
    except Exception as e:
        return False, str(e)


def get_cash_balance_for_group(group_id: int):
    try:
        response = (
            supabase
            .table(CASH_TX_TABLE)
            .select("amount, type")
            .eq("groep_id", group_id)
            .execute()
        )
        total = 0.0
        for row in (response.data or []):
            amt = float(row.get("amount") or 0)
            if (row.get("type") or "").lower() == "in":
                total += amt
            else:
                total -= amt
        return True, total
    except Exception as e:
        return False, str(e)


def count_group_members(group_id):
    try:
        response = (supabase
                    .table(GROUP_MEMBER_TABLE)
                    .select("ledenid", count="exact")
                    .eq(GROUP_ID_COLUMN, group_id)
                    .execute())
        if hasattr(response, "count") and response.count is not None:
            return True, response.count
        return True, len(response.data or [])
    except Exception as e:
        return False, str(e)


def list_memberships_for_user(ledenid):
    try:
        response = (supabase
                    .table(GROUP_MEMBER_TABLE)
                    .select("*")
                    .eq("ledenid", ledenid)
                    .order("created_at")
                    .execute())
        normalized = [_normalize_membership_row(row) for row in (response.data or [])]
        return True, normalized
    except Exception as e:
        return False, str(e)


def list_groups_by_ids(group_ids):
    try:
        if not group_ids:
            return True, []
        response = (supabase
                    .table(GROUP_TABLE)
                    .select("*")
                    .in_(GROUP_ID_COLUMN, group_ids)
                    .execute())
        normalized = [_normalize_group_row(row) for row in (response.data or [])]
        return True, normalized
    except Exception as e:
        return False, str(e)


def remove_member_from_group(group_id: int, member_id: int):
    """Verwijdert een lid uit een groep."""
    try:
        response = (
            supabase
            .table("groep_leden")
            .delete()
            .eq("groep_id", group_id)
            .eq("ledenid", member_id)
            .execute()
        )
        return True, response.data
    except Exception as e:
        logging.error("Fout bij verwijderen lid: %s", str(e))
        return False, f"Kon lid niet verwijderen: {str(e)}"


def delete_group(group_id: int):
    """Verwijdert een groep, alle leden en alle posities inclusief cash."""
    try:
        # 1. Alle leden verwijderen
        supabase.table("groep_leden") \
            .delete() \
            .eq("groep_id", group_id) \
            .execute()

        # 2. Alle portefeuilleposities (incl. CASH) verwijderen
        supabase.table("Portefeuille") \
            .delete() \
            .eq("groep_id", group_id) \
            .execute()

        # 3. Groep zelf verwijderen
        response = (
            supabase
            .table("Groep")
            .delete()
            .eq("groep_id", group_id)
            .execute()
        )

        return True, response.data

    except Exception as e:
        logging.error("Fout bij verwijderen groep: %s", str(e))
        return False, f"Kon groep niet verwijderen: {str(e)}"

# --- NIEUWE FUNCTIE: Portefeuille Positie Toevoegen/Updaten ---
def add_portfolio_position(group_id, ticker, quantity, price, user_id):
    """
    Voegt een positie toe of update de bestaande positie met een nieuw gemiddelde.
    """
    try:
        # 1. Kijk of positie al bestaat
        existing = (supabase
                    .table(PORTFOLIO_TABLE)
                    .select("*")
                    .eq("groep_id", group_id)
                    .eq("ticker", ticker)
                    .limit(1)
                    .execute())
        
        if existing.data and len(existing.data) > 0:
            # UPDATE: Bestaande positie
            current_row = existing.data[0]
            old_qty = float(current_row.get("quantity") or 0)
            old_avg = float(current_row.get("avg_price") or 0)
            
            # Bereken nieuw gewogen gemiddelde
            new_qty = old_qty + quantity
            if new_qty > 0:
                new_avg = ((old_qty * old_avg) + (quantity * price)) / new_qty
            else:
                new_avg = price
            
            # Update database
            supabase.table(PORTFOLIO_TABLE).update({
                "quantity": new_qty,
                "avg_price": new_avg,
                "current_price": price # Update ook de 'huidige prijs' met de laatst bekende
            }).eq("id", current_row.get("id")).execute()
            
            logging.info(f"Updated {ticker}: Old Qty {old_qty} -> New Qty {new_qty}")
            
        else:
            # INSERT: Nieuwe positie
            payload = {
                "groep_id": group_id,
                "ticker": ticker,
                "name": ticker, # Naam kan later aangevuld worden via YFinance indien nodig
                "quantity": quantity,
                "avg_price": price,
                "current_price": price,
                "sector": "Onbekend", # CSV bevat meestal geen sector, zet placeholder
                "transactiekost": 0
            }
            supabase.table(PORTFOLIO_TABLE).insert(payload).execute()
            logging.info(f"Inserted new position: {ticker}")
            
        return True, "Succes"
    except Exception as e:
        logging.error(f"Fout bij opslaan positie {ticker}: {e}")
        return False, str(e)