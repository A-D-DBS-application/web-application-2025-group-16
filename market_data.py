import os
import requests
import logging


# Probeer yfinance te laden (faalt soms op nieuwere Python versies)
try:
    import yfinance as yf
    YFINANCE_AVAILABLE = True
except Exception as e:
    print(f"⚠️ market_data: yfinance niet geladen ({e}); gebruik HTTP fallback.")
    yf = None
    YFINANCE_AVAILABLE = False

logger = logging.getLogger(__name__)

def _fetch_yahoo_http(symbol: str):
    """
    Interne hulpfunctie: Haalt data rechtstreeks van de Yahoo API (JSON)
    als de yfinance library niet werkt of faalt.
    """
    try:
        url = f"https://query1.finance.yahoo.com/v7/finance/quote?symbols={symbol}"
        # Timeout is belangrijk om te voorkomen dat je app blijft hangen
        r = requests.get(url, timeout=5)
        data = r.json()
        result = data.get('quoteResponse', {}).get('result', [])
        if result:
            return result[0]
    except Exception as e:
        logger.error(f"HTTP fallback error voor {symbol}: {e}")
    return None

def get_ticker_data(ticker: str):
    """
    Haalt uitgebreide info op voor een aandeel (Prijs, Naam, Sector, Valuta).
    Geeft een Dictionary terug (of None als het faalt).
    """
    symbol = ticker.strip().upper()
    data = {
        'symbol': symbol,
        'longName': symbol,
        'sector': 'Onbekend',
        'currency': 'EUR',
        'regularMarketPrice': None
    }

    # 1. Probeer via yfinance library (als beschikbaar)
    if YFINANCE_AVAILABLE and yf:
        try:
            stock = yf.Ticker(symbol)
            
            # Probeer snelle prijs
            price = None
            if hasattr(stock, 'fast_info'):
                price = getattr(stock.fast_info, 'last_price', None)
            
            # Fallback naar info dictionary
            info = {}
            try:
                info = stock.info
            except:
                pass # Soms faalt .info als de API traag is

            if price is None:
                price = info.get('currentPrice') or info.get('regularMarketPrice')

            # Als we een prijs hebben, vul de data
            if price:
                data['regularMarketPrice'] = float(price)
                data['longName'] = info.get('longName') or info.get('shortName') or symbol
                data['sector'] = info.get('sector', 'Onbekend')
                data['currency'] = info.get('currency', 'EUR')
                return data
        except Exception as e:
            logger.warning(f"Yfinance library faalde voor {symbol}, probeer fallback. Error: {e}")

    # 2. HTTP Fallback (als yfinance faalt of niet geïnstalleerd is)
    raw_data = _fetch_yahoo_http(symbol)
    if raw_data:
        data['regularMarketPrice'] = raw_data.get('regularMarketPrice') or raw_data.get('postMarketPrice')
        data['longName'] = raw_data.get('longName') or raw_data.get('shortName') or symbol
        data['sector'] = raw_data.get('sector') or 'Onbekend'
        data['currency'] = raw_data.get('currency') or 'EUR'
        return data

    return None

def get_currency_rate(currency: str):
    """
    Haalt de actuele wisselkoers op (1 EUR = X vreemde valuta).
    Bijv: input 'USD' -> geeft 1.05 terug.
    """
    code = (currency or '').strip().upper()
    
    # Basisgevallen
    if not code or len(code) < 3:
        return None
    if code == 'EUR':
        return 1.0
        
    symbol = f"EUR{code}=X"
    rate = None

    # 1. Probeer yfinance library
    if YFINANCE_AVAILABLE and yf:
        try:
            stock = yf.Ticker(symbol)
            rate = getattr(stock.fast_info, 'last_price', None)
            if rate is None:
                info = stock.info
                rate = info.get('regularMarketPrice') or info.get('bid')
        except:
            pass
    
    # 2. HTTP Fallback
    if rate is None:
        raw = _fetch_yahoo_http(symbol)
        if raw:
            rate = raw.get('regularMarketPrice') or raw.get('bid') or raw.get('ask')

    try:
        return float(rate) if rate else None
    except:
        return None

def sync_exchange_rates_to_db(supabase_client, currencies: list):
    """
    Update de tabel 'Wisselkoersen' in Supabase voor de opgegeven lijst munten.
    Geeft het aantal geüpdatete rijen terug.
    """
    updated_count = 0
    
    # Filter onzin en dubbele eruit
    unique_currencies = set([str(c).upper() for c in currencies if c and str(c).upper() != 'EUR'])
    
    for code in unique_currencies:
        rate = get_currency_rate(code)
        
        if rate:
            try:
                # Upsert: Update als bestaat, anders insert (als je tabel constraints goed staan)
                # Anders gebruiken we update().eq() zoals in je oude code
                
                # Check eerst of hij bestaat (voor veiligheid)
                existing = supabase_client.table('Wisselkoersen').select('munt').eq('munt', code).execute()
                
                if existing.data:
                    supabase_client.table('Wisselkoersen').update({'wk': rate}).eq('munt', code).execute()
                else:
                    supabase_client.table('Wisselkoersen').insert({'munt': code, 'wk': rate}).execute()
                    
                updated_count += 1
            except Exception as e:
                logger.error(f"DB fout bij updaten wisselkoers {code}: {e}")
                
    return updated_count