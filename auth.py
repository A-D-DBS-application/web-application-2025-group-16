import os
from supabase import create_client, Client

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
        "Groep id": group_id,
        "Broker id": None,
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


def remove_membership_for_user(ledenid):
    try:
        supabase.table(GROUP_MEMBER_TABLE).delete().eq("ledenid", ledenid).execute()
        return True, None
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