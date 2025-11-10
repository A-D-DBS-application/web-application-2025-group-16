from dotenv import load_dotenv
import os
from typing import Tuple, Any
from supabase import create_client, Client

load_dotenv()

SUPABASE_URL = os.environ.get("SUPABASE_URL")
SUPABASE_KEY = os.environ.get("SUPABASE_ANON_KEY")

supabase: Client | None = None
if SUPABASE_URL and SUPABASE_KEY:
    try:
        supabase = create_client(SUPABASE_URL, SUPABASE_KEY)
    except Exception as e:
        supabase = None
        print("Supabase init error:", e)
else:
    print("Missing SUPABASE_URL or SUPABASE_ANON_KEY in .env")

def _require_client():
    if supabase is None:
        raise RuntimeError("Supabase client not initialized. Check .env variables.")

def _normalize_email(email: str) -> str:
    return email.strip().lower()

def _sanitize_gsm(gsm: int | str) -> int:
    if isinstance(gsm, str):
        digits = "".join(ch for ch in gsm if ch.isdigit())
        return int(digits) if digits else 0
    return gsm

def _extract_data(res) -> list:
    # Handles both PostgrestResponse (.data) and dict {"data": [...}]
    try:
        if hasattr(res, "data"):
            return res.data or []
        if isinstance(res, dict):
            return res.get("data", []) or []
    except Exception:
        pass
    return []

def email_exists(email: str) -> bool:
    try:
        _require_client()
        r = supabase.table("Leden").select("ledenid").eq("email", _normalize_email(email)).limit(1).execute()
        data = _extract_data(r)
        return len(data) > 0
    except Exception:
        return False

def sign_up_user(email: str, voornaam: str, achternaam: str, gsm: int) -> Tuple[bool, Any]:
    email = _normalize_email(email)
    gsm = _sanitize_gsm(gsm)
    try:
        _require_client()
        if email_exists(email):
            return False, "Email already registered."
        supabase.table("Leden").insert({
            "voornaam": voornaam,
            "achternaam": achternaam,
            "GSM": gsm,
            "email": email
        }).execute()
        return True, "Registered."
    except Exception as e:
        return False, f"Registration error: {e}"

def sign_in_user(email: str) -> Tuple[bool, Any]:
    email = _normalize_email(email)
    if not email:
        return False, "Voer een e-mailadres in."
    try:
        _require_client()
        res = supabase.table("Leden").select("ledenid,email").eq("email", email).limit(1).execute()
        data = _extract_data(res)
        if not data:
            return False, "E-mailadres niet gevonden. Probeer opnieuw."
        return True, data[0]
    except Exception as e:
        return False, f"Inlogfout: {e}"

def list_leden() -> Tuple[bool, Any]:
    try:
        _require_client()
        res = supabase.table("Leden").select("*").order("created_at", desc=True).execute()
        return True, _extract_data(res)
    except Exception as e:
        return False, e