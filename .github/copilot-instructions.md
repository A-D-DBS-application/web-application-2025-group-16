# AI Coding Instructions for InvestClub Web Application

## Project Overview
InvestClub is a Flask-based web application for managing investment groups and portfolios. It uses Supabase for authentication/database, integrates with Google Generative AI for analysis, and fetches real-time market data via yfinance and RapidAPI.

**Key Tech Stack:** Flask, SQLAlchemy, Supabase, Tailwind CSS, yfinance, Google Gemini 2.0

## Architecture Overview

### Core Components
- **`app.py`**: Flask app with 4 blueprints (auth, groups, main, transacties)
- **`routes/`**: Separate blueprint modules handling different feature domains:
  - `auth_routes.py`: Login/register/logout flows
  - `group_routes.py`: Group creation, joining, member management
  - `main_routes.py`: Dashboard, cashbox, transactions, portfolio views
  - `transacties.py`: Transaction logging (imports from auth.py functions)
- **`auth.py`**: Core business logic—user/group CRUD, cashbox management, portfolio tracking
- **`config.py`**: Supabase client setup, environment variables (hardcoded fallbacks for dev)
- **`ai_manager.py`**: Wraps Google Generative AI (Gemini 2.0) with HTML cleaning logic
- **`market_data.py`**: yfinance & RapidAPI integration for ticker/exchange rate data
- **`templates/`**: Jinja2 HTML (Tailwind + Lucide icons for styling)

### Data Flow
1. User logs in → `auth.py` validates via Supabase → session["user_id"] set
2. User creates/joins group → stored in Supabase with invite codes
3. User adds portfolio/cash → `auth.py` functions sync to Supabase tables
4. AI analysis requests → routed through `ai_manager.py` → Gemini response cleaned (removes markdown/preamble)
5. Market data → `market_data.py` fetches real-time rates, syncs to DB

## Critical Developer Workflows

### Running the App
```bash
python app.py  # Runs Flask debug server on localhost:5000
```

### Database/Environment Setup
- Supabase credentials in `.env` (SUPABASE_URL, SUPABASE_ANON_KEY, SUPABASE_SERVICE_KEY, GOOGLE_API_KEY)
- If `.env` missing, `config.py` uses hardcoded dev fallbacks for Supabase anon credentials
- `fix_database.py` & `ticker_database_loader.py` available for data migration/initialization

### Testing
- `test_ai.py`, `test_key.py`, `supabase_test.py`: Unit tests for individual modules
- No test suite runner configured; run tests manually with `python test_<module>.py`

## Code Patterns & Conventions

### Function Return Pattern (Critical!)
Most auth.py functions return *tuples*: `(success: bool, result: Any | error_message: str)`
```python
ok, user = sign_in_user(email)  # Returns (True, user_dict) or (False, "Error message")
if ok:
    # Process user
```
**Always check the `ok` flag before using the result.**

### Blueprint Structure
- Each blueprint has a route prefix (e.g., `/auth/*`, `/group/*`)
- Use `render_template()` for HTML, `jsonify()` for API responses
- Flash messages for user feedback: `flash("Success", "success")` or `flash("Error", "error")`

### Environment Variables (Fallback Strategy)
```python
# config.py strategy: env var → hardcoded fallback → error
SUPABASE_URL = os.environ.get("SUPABASE_URL") or DEV_FALLBACK_URL
```
Service keys NEVER have fallbacks (security).

### AI Integration Pattern
```python
# ai_manager.py wraps Google API safely
from ai_manager import generate_ai_content_safe
html_response = generate_ai_content_safe(prompt)  # Returns cleaned HTML or error message
# Always returns valid HTML (even on failure)
```

### Template Structure
- Base template: `_nav.html` (navigation partial)
- Styling: Tailwind + Lucide icons (load from CDN in head)
- Flash messages: positioned fixed top-center, styled by category (success/error/info)
- Forms use Jinja2 loops for dynamic fields (e.g., `{% for item in items %}`)

## Important Integration Points

### Supabase Tables & Auth
- **leden** (users): ledenid (PK), email, voornaam, achternaam, gsm
- **groups**: id (PK), name, invite_code, created_by
- **memberships**: user_id, group_id, role (admin/member)
- **portfolio**: user_id, group_id, ticker, quantity, buy_price
- **cash_positions**: user_id, group_id, amount
- Anon client for user operations, admin client for batch updates (koersen_updater.py)

### Market Data Integration
- `yfinance`: ticker historical data, current prices
- `RapidAPI`: exchange rates (EUR/USD/GBP/etc.)
- Data synced to DB via `market_data.py` functions
- Ticker index search via `fuzzy_search.py` (rapidfuzz)

### External Dependencies
- **google.generativeai**: Gemini API (requires GOOGLE_API_KEY in .env)
- **requests**: HTTP calls to RapidAPI
- **pandas**: Data manipulation for CSV export
- **gunicorn**: Production server (Flask built-in debug for dev)

## Debugging Tips

### Supabase Connection Issues
- Check `.env` or fallback values in `config.py`
- Verify service key never hardcoded (security risk)
- Test with `supabase_test.py`

### AI Response Problems
- `ai_manager.py` logs "✅ AI Geconfigureerd" or "⚠️ AI Configuratiefout"
- Ensure GOOGLE_API_KEY doesn't contain "PLAK_HIER" (template placeholder)
- HTML cleaning logic in `clean_ai_response()` removes markdown & preambles

### Session & User Context
- Always check `session.get("user_id")` and `session.get("group_id")`
- Use helper `_current_group_snapshot()` in main_routes.py for safe group context

## File Structure Reference
```
routes/           # Blueprints split by feature domain
templates/        # Jinja2 HTML with Tailwind styling
static/css/       # style.css (custom Tailwind overrides)
auth.py           # User/group/portfolio CRUD logic
ai_manager.py     # Google Generative AI wrapper
market_data.py    # yfinance & exchange rate sync
config.py         # Supabase & env setup
```

---

**Last Updated:** December 2025  
For questions about architecture decisions, refer to commit history or README.md.
