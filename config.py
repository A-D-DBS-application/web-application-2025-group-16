#Dit bestand regelt alle verbindingen. Iedereen haalt hier zijn supabase client vandaan.
import os
from dotenv import load_dotenv
from supabase import create_client as create_supabase_client

# Laad .env bestand
load_dotenv()

# --- INSTELLINGEN ---
SECRET_KEY = os.environ.get("FLASK_SECRET_KEY", "super-secret-key-voor-dev-mode")
GOOGLE_API_KEY = os.environ.get("GOOGLE_API_KEY")
SUPABASE_URL = "https://bpbvlfptoacijyqyugew.supabase.co"

# --- SUPABASE CONNECTIE ---
# 1. Probeer de keys uit environment, anders hardcoded fallback (indien nodig)
SUPABASE_ANON_KEY = os.environ.get("SUPABASE_ANON_KEY", "JOUW_ANON_KEY_HIER_INDIEN_NIET_IN_ENV")
SUPABASE_SERVICE_KEY = os.environ.get("SUPABASE_SERVICE_KEY")

# 2. De standaard client (voor lees/schrijf acties namens gebruiker)
try:
    supabase = create_supabase_client(SUPABASE_URL, SUPABASE_ANON_KEY)
except Exception as e:
    print(f"⚠️ Critical: Kon Supabase niet verbinden: {e}")
    supabase = None

# 3. De admin client (voor acties die RLS omzeilen, zoals wisselkoersen updaten)
supabase_admin = None
if SUPABASE_SERVICE_KEY:
    try:
        supabase_admin = create_supabase_client(SUPABASE_URL, SUPABASE_SERVICE_KEY)
    except Exception:
        pass