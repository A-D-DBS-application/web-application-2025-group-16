# fuzzy_search.py
# Eigen fuzzy search algoritme voor ticker matching
# Met uitgebreide ticker database + Yahoo Finance fallback

import logging
from typing import List, Dict

# RapidFuzz is een open-source library voor fuzzy matching
try:
    from rapidfuzz import fuzz
    RAPIDFUZZ_AVAILABLE = True
except ImportError:
    print("⚠️ rapidfuzz niet geïnstalleerd. Gebruik: pip install rapidfuzz")
    RAPIDFUZZ_AVAILABLE = False

logger = logging.getLogger(__name__)


class TickerSearchEngine:
    """
    Eigen fuzzy search engine voor ticker matching.
    
    Architectuur:
    1. Primair: Zoek in eigen ticker database (550+ tickers)
    2. Fallback: Als er minder dan 3 resultaten zijn, zoek in Yahoo Finance (data retrieval)
    3. Caching: Yahoo resultaten worden toegevoegd aan database
    
    Core algoritme (100% eigen):
    - Exact, prefix, substring, fuzzy matching
    - Eigen scoring systeem (100, 90, 70, 0-80)
    - Eigen ranking (sorteer op score)
    """
    
    def __init__(self):
        self.ticker_index = []
    
    def build_index_from_database(self, supabase_client, load_extended=True):
        """Bouwt index uit database + optioneel S&P 500 + Euronext."""
        try:
            # Gebruik dict voor deduplicatie met sector/naam prioriteit
            ticker_dict = {}
            
            def add_ticker_smart(ticker: str, name: str, sector: str):
                """Voegt ticker toe met prioriteit voor langste/beste sector en naam."""
                ticker = str(ticker).strip().upper()
                if not ticker or ticker == 'CASH':
                    return
                
                sector = (sector or 'Onbekend').strip()
                name = (name or ticker).strip()
                
                if ticker in ticker_dict:
                    existing = ticker_dict[ticker]
                    
                    # Sector prioriteit: niet-'Onbekend' en langste wint
                    existing_is_unknown = existing['sector'].lower() == 'onbekend'
                    new_is_unknown = sector.lower() == 'onbekend'
                    
                    if existing_is_unknown and not new_is_unknown:
                        existing['sector'] = sector
                    elif not existing_is_unknown and not new_is_unknown:
                        if len(sector) > len(existing['sector']):
                            existing['sector'] = sector
                    
                    # Naam prioriteit: langste naam wint (maar niet als het gewoon de ticker is)
                    if name != ticker and (existing['name'] == ticker or len(name) > len(existing['name'])):
                        existing['name'] = name
                else:
                    ticker_dict[ticker] = {'ticker': ticker, 'name': name, 'sector': sector}
            
            # Database tickers - Portefeuille eerst (heeft vaak betere data)
            try:
                portfolio_result = supabase_client.table('Portefeuille').select('ticker, name, sector').execute()
                for row in (portfolio_result.data or []):
                    add_ticker_smart(row.get('ticker', ''), row.get('name', ''), row.get('sector', ''))
            except Exception as e:
                logger.warning(f"Portefeuille load failed: {e}")
            
            try:
                transactions_result = supabase_client.table('Transacties').select('ticker').execute()
                for row in (transactions_result.data or []):
                    add_ticker_smart(row.get('ticker', ''), '', 'Onbekend')
            except Exception as e:
                logger.warning(f"Transacties load failed: {e}")
            
            self.ticker_index = list(ticker_dict.values())
            
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
    
    def _deduplicate_results(self, results: List[Dict]) -> List[Dict]:
        """
        Dedupliceer zoekresultaten op ticker.
        Behoudt per ticker: hoogste score, beste naam, beste sector.
        """
        seen = {}
        
        for result in results:
            ticker = result['ticker']
            
            if ticker in seen:
                existing = seen[ticker]
                
                # Behoud hoogste score
                if result['score'] > existing['score']:
                    existing['score'] = result['score']
                
                # Sector prioriteit: niet-'Onbekend' en langste wint
                existing_is_unknown = existing['sector'].lower() == 'onbekend'
                new_is_unknown = result['sector'].lower() == 'onbekend'
                
                if existing_is_unknown and not new_is_unknown:
                    existing['sector'] = result['sector']
                elif not existing_is_unknown and not new_is_unknown:
                    if len(result['sector']) > len(existing['sector']):
                        existing['sector'] = result['sector']
                
                # Naam prioriteit: langste naam wint (maar niet als het gewoon de ticker is)
                new_name = result['name']
                if new_name != ticker and (existing['name'] == ticker or len(new_name) > len(existing['name'])):
                    existing['name'] = new_name
            else:
                seen[ticker] = result.copy()
        
        return list(seen.values())
    
    def search(self, query: str, limit: int = 10, use_fallback: bool = True) -> List[Dict]:
        """
        CORE SEARCH ALGORITME
        
        Stap 1: Zoek in eigen database (eigen scoring)
        Stap 2: Als <3 resultaten: Yahoo fallback (data retrieval)
        Stap 3: Dedupliceer resultaten
        Stap 4: Rank alle resultaten
        """
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
        
        # STAP 2: Yahoo Fallback (alleen data retrieval)
        if use_fallback and len(results) < 3 and len(query) >= 2:
            yahoo_results = self._search_yahoo_fallback(query, limit=5)
            
            for yahoo_result in yahoo_results:
                yahoo_result['score'] = 50  # Lagere score dan eigen matches
                results.append(yahoo_result)
                self.add_ticker_to_index(yahoo_result['ticker'], yahoo_result['name'], yahoo_result['sector'])
        
        # STAP 3: Dedupliceer op ticker (behoud beste naam/sector/score)
        results = self._deduplicate_results(results)
        
        # STAP 4: Sorteer op score
        results.sort(key=lambda x: x['score'], reverse=True)
        
        return results[:limit]
    
    def _search_yahoo_fallback(self, query: str, limit: int = 5) -> List[Dict]:
        """Yahoo Finance voor Data Retrieval."""
        try:
            import requests
            
            url = "https://query2.finance.yahoo.com/v1/finance/search"
            response = requests.get(
                url,
                params={'q': query, 'quotesCount': limit, 'newsCount': 0},
                headers={'User-Agent': 'Mozilla/5.0'},
                timeout=3
            )
            
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
        """Berekent match score tussen query en ticker."""
        ticker = ticker_obj['ticker'].upper()
        name = ticker_obj['name'].upper()
        
        # Exact match
        if ticker == query:
            return 100
        
        # Prefix match
        if ticker.startswith(query):
            return 90
        
        # Substring match
        if query in ticker:
            return 70
        
        # Fuzzy match op naam
        if RAPIDFUZZ_AVAILABLE:
            name_score = fuzz.token_set_ratio(query, name)
            if name_score > 60:
                return name_score * 0.8
        else:
            if query in name:
                return 60 if name.find(query) == 0 else 40
        
        return 0
    
    def add_ticker_to_index(self, ticker: str, name: str = None, sector: str = None):
        """Voeg ticker toe aan index met sector/naam prioriteit."""
        ticker = ticker.strip().upper()
        sector = (sector or 'Onbekend').strip()
        name = (name or ticker).strip()
        
        for existing in self.ticker_index:
            if existing['ticker'] == ticker:
                # Sector: update alleen als huidige 'Onbekend' is, of nieuwe langer is
                existing_is_unknown = existing['sector'].lower() == 'onbekend'
                new_is_unknown = sector.lower() == 'onbekend'
                
                if existing_is_unknown and not new_is_unknown:
                    existing['sector'] = sector
                elif not existing_is_unknown and not new_is_unknown and len(sector) > len(existing['sector']):
                    existing['sector'] = sector
                
                # Naam: update als nieuwe beter is
                if name != ticker and (existing['name'] == ticker or len(name) > len(existing['name'])):
                    existing['name'] = name
                return
        
        self.ticker_index.append({'ticker': ticker, 'name': name, 'sector': sector})


# Singleton instance
_search_engine = None


def get_search_engine():
    """Retourneert singleton search engine instance."""
    global _search_engine
    if _search_engine is None:
        _search_engine = TickerSearchEngine()
    return _search_engine


def search_tickers(query: str, supabase_client=None, limit: int = 10, use_fallback: bool = True) -> List[Dict]:
    """Zoek tickers met fuzzy matching."""
    engine = get_search_engine()
    if len(engine.ticker_index) == 0 and supabase_client:
        engine.build_index_from_database(supabase_client)
    return engine.search(query, limit, use_fallback)


def refresh_ticker_index(supabase_client):
    """Herlaad de ticker index."""
    engine = get_search_engine()
    engine.build_index_from_database(supabase_client)
    return len(engine.ticker_index)