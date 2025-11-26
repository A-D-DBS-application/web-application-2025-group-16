import os
import yfinance as yf
from supabase import create_client, Client
from time import sleep

# --- CONFIGURATIE ---
# VUL HIER JE GEGEVENS IN
# Voor dit script heb je de SERVICE ROLE KEY nodig (vind je in Supabase > Project Settings > API)
# Let op: Dit is NIET de 'anon' key, maar de geheime sleutel die mag schrijven.
SUPABASE_URL = "https://bpbvlfptoacijyqyugew.supabase.co"
SUPABASE_SERVICE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJwYnZsZnB0b2FjaWp5cXl1Z2V3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjA2NDk2NzAsImV4cCI6MjA3NjIyNTY3MH0.6_z9bE3aB4QMt5ASE0bxM6Ds8Tf7189sBDUVLrUeU-M" 

# Initialiseer Supabase
try:
    supabase: Client = create_client(SUPABASE_URL, SUPABASE_SERVICE_KEY)
    print("✅ Verbinding met Supabase ingesteld.")
except Exception as e:
    print(f"❌ Kon Supabase niet initialiseren. Check je URL en KEY. Fout: {e}")
    exit()

def update_stock_prices():
    print("\n--- 🚀 Start koers update ---")
    
    try:
        # We halen alles op uit de tabel 'Portefeuille' (Let op hoofdletter P)
        response = supabase.table('Portefeuille').select("*").execute()
        stocks = response.data
        print(f"ℹ️ {len(stocks)} rij(en) gevonden in database.")
    except Exception as e:
        print(f"❌ Fout bij ophalen data uit Supabase: {e}")
        return

    if not stocks:
        print("⚠️ Geen aandelen gevonden. Voeg eerst data toe in Supabase.")
        return

    for stock in stocks:
        # 1. Haal de info op uit jouw tabel kolommen
        ticker_symbol = stock.get('ticker')
        # BELANGRIJK: Jouw database gebruikt 'Portefeuille id' met spatie als ID
        stock_id = stock.get('Portefeuille id') 

        # Sla lege regels of defaults ('0') over om crashes te voorkomen
        if not ticker_symbol or ticker_symbol == '0' or ticker_symbol == '0.0':
            continue

        print(f"🔍 Ophalen koers voor: {ticker_symbol}...")

        try:
            # 2. Vraag prijs aan Yahoo Finance
            ticker_data = yf.Ticker(ticker_symbol)
            
            # Probeer de snelle methode, anders history
            try:
                current_price = ticker_data.fast_info['last_price']
            except:
                # Fallback naar historie als fast_info faalt
                history = ticker_data.history(period="1d")
                if not history.empty:
                    current_price = history['Close'].iloc[-1]
                else:
                    raise Exception("Geen prijs gevonden")

            if current_price is None or current_price == 0:
                print(f"   ⚠️ Geen geldige prijs ontvangen voor {ticker_symbol}")
                continue

            # 3. Update de database
            update_data = {
                "current_price": round(current_price, 2)
            }
            
            # Update de specifieke rij op basis van 'Portefeuille id'
            supabase.table('Portefeuille').update(update_data).eq('Portefeuille id', stock_id).execute()
            print(f"✅ {ticker_symbol} geüpdatet naar €{round(current_price, 2)}")

        except Exception as e:
            print(f"❌ Fout bij {ticker_symbol}: {e}")
        
        # Korte pauze om Yahoo niet te overbelasten
        sleep(0.5)

    print("--- 🏁 Update voltooid ---\n")

if __name__ == "__main__":
    update_stock_prices()