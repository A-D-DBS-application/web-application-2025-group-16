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
            "sector": "Technologie",
            # Set default trading currency
            "munt": "USD"
            # Broker id en Groep id laten we leeg (werkt alleen als ze Nullable zijn)
        }
        supabase.table('Portefeuille').insert(nieuw_aandeel).execute()
        print("✅ AAPL toegevoegd!")
    else:
        print("ℹ️ AAPL bestaat al in de tabel.")

except Exception as e:
    print(f"❌ Fout: {e}")

print("\n--- 3. Test: Wisselkoersen invullen ---")
try:
    # Voeg een random testrecord toe voor wisselkoers
    from random import uniform, choice
    test_cur = choice(["USD", "GBP", "CHF", "JPY"])  # willekeurige munt
    test_wk = round(uniform(0.5, 2.0), 4)  # willekeurige koers tov EUR
    # Probeer upsert: update indien aanwezig, anders insert
    existing = supabase.table('Wisselkoersen').select('wk_id').eq('munt', test_cur).limit(1).execute()
    if existing.data and len(existing.data) > 0:
        wk_id = existing.data[0].get('wk_id')
        supabase.table('Wisselkoersen').update({ 'WK': test_wk, 'munt': test_cur }).eq('wk_id', wk_id).execute()
        print(f"✅ Wisselkoersen updated: {test_cur} -> {test_wk}")
    else:
        supabase.table('Wisselkoersen').insert({ 'WK': test_wk, 'munt': test_cur }).execute()
        print(f"✅ Wisselkoersen inserted: {test_cur} -> {test_wk}")
except Exception as e:
    print(f"❌ Fout bij Wisselkoersen test insert: {e}")