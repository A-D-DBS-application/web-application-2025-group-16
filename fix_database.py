import os
from supabase import create_client, Client

# --- CONFIGURATIE ---
SUPABASE_URL = "https://bpbvlfptoacijyqyugew.supabase.co"
# Vul hier je SERVICE ROLE KEY in (niet de anon key!)
SUPABASE_KEY = "jouw-service-role-key" 

print("--- 1. Verbinding maken... ---")
try:
    supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)
    print("✅ Verbinding gelukt.")
except Exception as e:
    print(f"❌ Kon niet verbinden: {e}")
    exit()

print("\n--- 2. Data toevoegen... ---")
try:
    # Check of AAPL er al in zit
    response = supabase.table('Portefeuille').select("*").eq('ticker', 'AAPL').execute()
    
    if len(response.data) == 0:
        print("   AAPL toevoegen...")
        nieuw_aandeel = {
            "ticker": "AAPL",
            "name": "Apple Inc.",
            "quantity": 10,
            "avg_price": 150.00,
            "current_price": 0,
            "sector": "Technologie"
            # Broker id en Groep id laten we leeg (werkt alleen als ze Nullable zijn)
        }
        supabase.table('Portefeuille').insert(nieuw_aandeel).execute()
        print("✅ AAPL toegevoegd!")
    else:
        print("ℹ️ AAPL bestaat al in de tabel.")

except Exception as e:
    print(f"❌ Fout: {e}")