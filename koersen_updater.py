import time
import yfinance as yf
from config import supabase # Haal client uit config!

def update_stock_prices(groep_id=None):
    print("\n--- 🚀 Start koers update ---")
    
    query = supabase.table('Portefeuille').select("*")
    if groep_id:
        query = query.eq("groep_id", groep_id)
        
    try:
        response = query.execute()
        stocks = response.data or []
    except Exception as e:
        print(f"❌ DB Error: {e}")
        return False, str(e)

    if not stocks:
        print("⚠️ Geen aandelen.")
        return True, "Geen aandelen"

    count = 0
    for stock in stocks:
        ticker = stock.get('ticker')
        pid = stock.get('port_id') # Of 'Portefeuille id' check je DB kolomnaam!
        
        if not ticker: continue
        
        print(f"🔍 {ticker}...")
        try:
            # Haal data (je kan hier ook market_data.py gebruiken als je wilt)
            t = yf.Ticker(ticker)
            price = None
            try: price = t.fast_info.last_price
            except: 
                h = t.history(period="1d")
                if not h.empty: price = h['Close'].iloc[-1]
            
            if price:
                supabase.table('Portefeuille').update({"current_price": round(price, 2)}).eq('port_id', pid).execute()
                count += 1
        except Exception as e:
            print(f"❌ Error {ticker}: {e}")
            
    print(f"✅ {count} geüpdatet.")
    return True, f"{count} koersen geüpdatet"

if __name__ == "__main__":
    update_stock_prices()