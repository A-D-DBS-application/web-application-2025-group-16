# Laadt uitgebreide ticker database (S&P 500 + Euronext)

import logging

logger = logging.getLogger(__name__)

def load_extended_ticker_database(search_engine):
    """
    Laadt uitgebreide ticker database in de search engine.
    
    Bronnen:
    1. S&P 500 van GitHub (500+ tickers)
    2. Euronext Brussels (17 Belgische tickers)
    3. Euronext Amsterdam (8 Nederlandse tickers)
    
    Dit is DATA RETRIEVAL - matching gebeurt door eigen algoritme.
    """
    # S&P 500
    sp500_tickers = _download_sp500()
    if sp500_tickers:
        for ticker in sp500_tickers:
            search_engine.ticker_index.append(ticker)
        logger.info(f"Loaded {len(sp500_tickers)} S&P 500 tickers")
    
    # Belgische aandelen
    belgian_tickers = _get_belgian_tickers()
    for ticker in belgian_tickers:
        search_engine.ticker_index.append(ticker)
    logger.info(f"Loaded {len(belgian_tickers)} Belgian tickers")
    
    # Nederlandse aandelen
    dutch_tickers = _get_dutch_tickers()
    for ticker in dutch_tickers:
        search_engine.ticker_index.append(ticker)
    logger.info(f"Loaded {len(dutch_tickers)} Dutch tickers")
    
    return len(search_engine.ticker_index)

def _download_sp500():
    #Download S&P 500 lijst van GitHub.
    try:
        import pandas as pd
        import requests
        import io
        url = "https://raw.githubusercontent.com/datasets/s-and-p-500-companies/master/data/constituents.csv"
        try:
            resp = requests.get(url, timeout=5)
            resp.raise_for_status()
            df = pd.read_csv(io.StringIO(resp.text))
        except requests.RequestException as re:
            logger.warning(f"S&P 500 download failed (request): {re}")
            return []

        tickers = []
        for _, row in df.iterrows():
            ticker_sym = str(row.get('Symbol', '')).strip()
            if not ticker_sym:
                continue
            name = str(row.get('Security', '')).strip() or ''
            sector = str(row.get('GICS Sector', 'Onbekend')).strip() or 'Onbekend'
            tickers.append({
                'ticker': ticker_sym,
                'name': name,
                'sector': sector
            })
        return tickers
    except Exception as e:
        logger.warning(f"S&P 500 download failed: {e}")
        return []

def _get_belgian_tickers():
    """Belgische aandelen (Euronext Brussels)."""
    return [
        {'ticker': 'ABI.BR', 'name': 'Anheuser-Busch InBev', 'sector': 'Consumer Defensive'},
        {'ticker': 'KBC.BR', 'name': 'KBC Group', 'sector': 'Financial Services'},
        {'ticker': 'UCB.BR', 'name': 'UCB SA', 'sector': 'Healthcare'},
        {'ticker': 'ARGX.BR', 'name': 'argenx SE', 'sector': 'Healthcare'},
        {'ticker': 'COLR.BR', 'name': 'Colruyt Group', 'sector': 'Consumer Defensive'},
        {'ticker': 'LOTB.BR', 'name': 'Lotus Bakeries', 'sector': 'Consumer Defensive'},
        {'ticker': 'PROX.BR', 'name': 'Proximus', 'sector': 'Communication Services'},
        {'ticker': 'SOF.BR', 'name': 'Sofina', 'sector': 'Financial Services'},
        {'ticker': 'AGS.BR', 'name': 'Ageas', 'sector': 'Financial Services'},
        {'ticker': 'ACKB.BR', 'name': 'Ackermans & van Haaren', 'sector': 'Financial Services'},
        {'ticker': 'BEKB.BR', 'name': 'Bekaert', 'sector': 'Industrials'},
        {'ticker': 'GBLB.BR', 'name': 'Groupe Bruxelles Lambert', 'sector': 'Financial Services'},
        {'ticker': 'UMI.BR', 'name': 'Umicore', 'sector': 'Basic Materials'},
        {'ticker': 'SOLB.BR', 'name': 'Solvay', 'sector': 'Basic Materials'},
        {'ticker': 'WDP.BR', 'name': 'Warehouses De Pauw', 'sector': 'Real Estate'},
        {'ticker': 'COFB.BR', 'name': 'Cofinimmo', 'sector': 'Real Estate'},
        {'ticker': 'TINC.BR', 'name': 'Tinc', 'sector': 'Communication Services'},
    ]

def _get_dutch_tickers():
    """Nederlandse aandelen (Euronext Amsterdam)."""
    return [
        {'ticker': 'ASML.AS', 'name': 'ASML Holding', 'sector': 'Technology'},
        {'ticker': 'PHIA.AS', 'name': 'Koninklijke Philips', 'sector': 'Healthcare'},
        {'ticker': 'INGA.AS', 'name': 'ING Groep', 'sector': 'Financial Services'},
        {'ticker': 'HEIA.AS', 'name': 'Heineken', 'sector': 'Consumer Defensive'},
        {'ticker': 'AD.AS', 'name': 'Ahold Delhaize', 'sector': 'Consumer Defensive'},
        {'ticker': 'AKZA.AS', 'name': 'Akzo Nobel', 'sector': 'Basic Materials'},
        {'ticker': 'DSM.AS', 'name': 'Koninklijke DSM', 'sector': 'Basic Materials'},
        {'ticker': 'RAND.AS', 'name': 'Randstad', 'sector': 'Industrials'},
    ]