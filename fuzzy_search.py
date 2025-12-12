# fuzzy_search.py
# Eigen fuzzy search algoritme voor ticker matching
# Met uitgebreide ticker database + Yahoo Finance fallback (kan dat dit nog verwijderd wordt in afwachting van respons op mail van Thomas De Rave)

import logging
from typing import List, Dict

# RapidFuzz is een open-source library voor fuzzy matching, hier wordt dus geen gebruik gemaak van een zogenaamde blacbkox en is dus toegelaten volgens de regels van deze case. Oogt ook professioneler
try:
    from rapidfuzz import fuzz
    RAPIDFUZZ_AVAILABLE = True
except ImportError:
    print("⚠️ rapidfuzz niet geïnstalleerd. Gebruik: pip install rapidfuzz")
    RAPIDFUZZ_AVAILABLE = False

logger = logging.getLogger(__name__)

class TickerSearchEngine:

    #Eigen fuzzy search engine voor ticker matching.
    
   # Architectuur:
    #1. Primair: Zoek in eigen ticker database (550+ tickers)
    #2. Fallback: Als er minder dan 3 resultaten zijn, zoek in Yahoo Finance (data retrieval) (wacht nog op confirmatie van Thomas dat dit mag)
    #3. Caching: Yahoo resultaten worden toegevoegd aan database
    
   # Core algoritme (100% eigen):
    #- Exact, prefix, substring, fuzzy matching
    #- Eigen scoring systeem (100, 90, 70, 0-80)
    #- Eigen ranking (sorteer op score)
    
    
    def __init__(self):
        self.ticker_index = []
        
    def build_index_from_database(self, supabase_client, load_extended=True):
        #Bouwt index uit database + optioneel S&P 500 + Euronext.
        try:
            ticker_set = set()
            
            # Database tickers
            try:
                portfolio_result = supabase_client.table('Portefeuille').select('ticker, name, sector').execute()
                for row in (portfolio_result.data or []):
                    ticker = str(row.get('ticker', '')).strip().upper()
                    if ticker and ticker != 'CASH':
                        ticker_set.add((ticker, row.get('name', ticker), row.get('sector', 'Onbekend')))
            except Exception as e:
                logger.warning(f"Portefeuille load failed: {e}")
            
            try:
                transactions_result = supabase_client.table('Transacties').select('ticker').execute()
                for row in (transactions_result.data or []):
                    ticker = str(row.get('ticker', '')).strip().upper()
                    if ticker and ticker != 'CASH':
                        ticker_set.add((ticker, ticker, 'Onbekend'))
            except Exception as e:
                logger.warning(f"Transacties load failed: {e}")
            
            self.ticker_index = [{'ticker': t[0], 'name': t[1], 'sector': t[2]} for t in ticker_set]
            
            if len(self.ticker_index) == 0:
                self.ticker_index = self._get_seed_tickers()
            
            # Laad uitgebreide database
            if load_extended:
                try:
                    from ticker_database_loader import load_extended_ticker_database
                    total = load_extended_ticker_database(self)
                    logger.info(f"✅ Index ready with {total} tickers")
                except Exception as e:
                    logger.warning(f"Extended database load failed: {e}")
            
        except Exception as e:
            logger.error(f"Index build error: {e}")
            self.ticker_index = self._get_seed_tickers()
    
    def _get_seed_tickers(self) -> List[Dict]:
        """Seed lijst als fallback."""
        return [
            {'ticker': 'AAPL', 'name': 'Apple Inc.', 'sector': 'Technology'},
            {'ticker': 'MSFT', 'name': 'Microsoft Corporation', 'sector': 'Technology'},
            {'ticker': 'GOOGL', 'name': 'Alphabet Inc.', 'sector': 'Technology'},
            {'ticker': 'TSLA', 'name': 'Tesla Inc.', 'sector': 'Automotive'},
            {'ticker': 'ABI.BR', 'name': 'Anheuser-Busch InBev', 'sector': 'Consumer Defensive'},
            {'ticker': 'KBC.BR', 'name': 'KBC Group', 'sector': 'Financial Services'},
            {'ticker': 'ASML.AS', 'name': 'ASML Holding', 'sector': 'Technology'},
        ]
    
    def search(self, query: str, limit: int = 10, use_fallback: bool = True) -> List[Dict]:
        
        #CORE SEARCH ALGORITME
        
        #Stap 1: Zoek in eigen database (eigen scoring)
        #Stap 2: Als <3 resultaten: Yahoo fallback (data retrieval)
        #Stap 3: Rank alle resultaten 
        
        if not query or len(query.strip()) == 0:
            return []
        
        query = query.strip().upper()
        results = []
        
        # STAP 1: Eigen database search
        for ticker_obj in self.ticker_index:
            score = self._calculate_match_score(query, ticker_obj)
            if score > 0:
                results.append({
                    'ticker': ticker_obj['ticker'],
                    'name': ticker_obj['name'],
                    'sector': ticker_obj['sector'],
                    'score': score
                })
        
        results.sort(key=lambda x: x['score'], reverse=True)
        
        # STAP 2: Yahoo Fallback (alleen data retrieval)
        if use_fallback and len(results) < 3 and len(query) >= 2:
            yahoo_results = self._search_yahoo_fallback(query, limit=5)
            
            for yahoo_result in yahoo_results:
                if not any(r['ticker'] == yahoo_result['ticker'] for r in results):
                    yahoo_result['score'] = 50  # Lagere score dan eigen matches
                    results.append(yahoo_result)
                    self.add_ticker_to_index(yahoo_result['ticker'], yahoo_result['name'], yahoo_result['sector'])
        
        results.sort(key=lambda x: x['score'], reverse=True)
        return results[:limit]
    
    def _search_yahoo_fallback(self, query: str, limit: int = 5) -> List[Dict]:
        #Yahoo Finance voor Data Retrieval.
        try:
            import requests
            
            url = "https://query2.finance.yahoo.com/v1/finance/search"
            response = requests.get(url, params={'q': query, 'quotesCount': limit, 'newsCount': 0}, 
                                  headers={'User-Agent': 'Mozilla/5.0'}, timeout=3)
            
            if response.status_code != 200:
                return []
            
            quotes = response.json().get('quotes', [])
            results = []
            
            for quote in quotes[:limit]:
                if quote.get('quoteType', '').upper() in ['OPTION', 'FUTURE', 'CURRENCY']:
                    continue
                    
                ticker = quote.get('symbol', '')
                name = quote.get('longname') or quote.get('shortname', '')
                
                if ticker and name:
                    results.append({
                        'ticker': ticker,
                        'name': name,
                        'sector': quote.get('sector', 'Onbekend')
                    })
            
            return results
        except Exception as e:
            logger.warning(f"Yahoo fallback failed: {e}")
            return []
    
    def _calculate_match_score(self, query: str, ticker_obj: Dict) -> float:
        
        ticker = ticker_obj['ticker'].upper()
        name = ticker_obj['name'].upper()
        
        if ticker == query:
            return 100
        if ticker.startswith(query):
            return 90
        if query in ticker:
            return 70
        
        if RAPIDFUZZ_AVAILABLE:
            name_score = fuzz.token_set_ratio(query, name)
            if name_score > 60:
                return name_score * 0.8
        else:
            if query in name:
                return 60 if name.find(query) == 0 else 40
        
        return 0
    
    def add_ticker_to_index(self, ticker: str, name: str = None, sector: str = None):
        """Voeg ticker toe aan index (voor caching)."""
        ticker = ticker.strip().upper()
        
        for existing in self.ticker_index:
            if existing['ticker'] == ticker:
                if name: existing['name'] = name
                if sector: existing['sector'] = sector
                return
        
        self.ticker_index.append({'ticker': ticker, 'name': name or ticker, 'sector': sector or 'Onbekend'})



_search_engine = None

def get_search_engine():
    global _search_engine
    if _search_engine is None:
        _search_engine = TickerSearchEngine()
    return _search_engine

def search_tickers(query: str, supabase_client=None, limit: int = 10, use_fallback: bool = True) -> List[Dict]:
    engine = get_search_engine()
    if len(engine.ticker_index) == 0 and supabase_client:
        engine.build_index_from_database(supabase_client)
    return engine.search(query, limit, use_fallback)

def refresh_ticker_index(supabase_client):
    engine = get_search_engine()
    engine.build_index_from_database(supabase_client)
    return len(engine.ticker_index)