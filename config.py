import os
from dotenv import load_dotenv
from supabase import create_client as create_supabase_client

# Laad .env bestand (indien aanwezig)
load_dotenv()

# --- INSTELLINGEN ---
SECRET_KEY = os.environ.get("FLASK_SECRET_KEY", "super-secret-key-voor-dev-mode")
GOOGLE_API_KEY = os.environ.get("GOOGLE_API_KEY")

# --- SUPABASE CONFIG UIT OMGEVING ---
# Vereist voor alle omgevingen om "werkt bij iedereen" te garanderen.
SUPABASE_URL = os.environ.get("SUPABASE_URL")
SUPABASE_ANON_KEY = os.environ.get("SUPABASE_ANON_KEY")
SUPABASE_SERVICE_KEY = os.environ.get("SUPABASE_SERVICE_KEY")

# --- HARDCODED DEV FALLBACKS (op verzoek) ---
# Let op: service key blijft ALTIJD uit env om veiligheid.
DEV_FALLBACK_URL = "https://bpbvlfptoacijyqyugew.supabase.co"
DEV_FALLBACK_ANON = (
    "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9."
    "eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJwYnZsZnB0b2FjaWp5cXl1Z2V3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjA2NDk2NzAsImV4cCI6MjA3NjIyNTY3MH0."
    "6_z9bE3aB4QMt5ASE0bxM6Ds8Tf7189sBDUVLrUeU-M")

# Forceer hardcoded defaults als env ontbreekt (voor eenvoudige opstart op elk toestel)
if not SUPABASE_URL:
    SUPABASE_URL = DEV_FALLBACK_URL
if not SUPABASE_ANON_KEY:
    SUPABASE_ANON_KEY = DEV_FALLBACK_ANON

# Validatie en duidelijke foutmeldingen
def _missing_env(var_name: str) -> str:
    return f"Environment variable '{var_name}' ontbreekt. Zet deze in je .env of systeemvariabelen."

supabase = None
supabase_admin = None



# 1. Standaard client (voor app-gebruikers)
if SUPABASE_URL and SUPABASE_ANON_KEY:
    try:
        supabase = create_supabase_client(SUPABASE_URL, SUPABASE_ANON_KEY)
    except Exception as e:
        print(f"⚠️ Kon Supabase (anon) niet verbinden: {e}")

# 2. Admin client (optioneel; voor backoffice taken zoals koersupdates)
if SUPABASE_URL and SUPABASE_SERVICE_KEY:
    try:
        supabase_admin = create_supabase_client(SUPABASE_URL, SUPABASE_SERVICE_KEY)
    except Exception as e:
        print(f"⚠️ Kon Supabase (service) niet verbinden: {e}")