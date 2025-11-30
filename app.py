from flask import Flask, render_template, request, redirect, session, url_for, jsonify, flash, get_flashed_messages
import os, logging, traceback, secrets
from werkzeug.exceptions import HTTPException
import pandas as pd
import io 
import json
import time
import requests

# Probeer yfinance te laden; faalt onder Python 3.14 i.v.m. protobuf.
try:
    import yfinance as yf  # type: ignore
    YFINANCE_AVAILABLE = True
except Exception as e:
    print(f"⚠️ yfinance niet geladen ({e}); gebruik HTTP fallback.")
    yf = None  # type: ignore
    YFINANCE_AVAILABLE = False

# Gemini import veilig maken voor Python 3.14; indien niet beschikbaar, fallback.
try:
    import google.generativeai as genai  # type: ignore
    GENAI_AVAILABLE = True
except Exception as e:
    print(f"⚠️ google-generativeai niet geladen ({e}); AI uitgeschakeld.")
    GENAI_AVAILABLE = False
    class _GenAIFallback:  # minimalistische stub
        def configure(self, **kwargs): pass
        class GenerativeModel:
            def __init__(self, *a, **kw): pass
            def generate_content(self, prompt):
                class R: text = "AI niet beschikbaar op deze Python versie."
                return R()
    genai = _GenAIFallback()

from auth import (
    sign_up_user,
    sign_in_user,
    list_leden,
    create_group_record,
    get_group_by_code,
    get_group_by_id,
    group_code_exists,
    add_member_to_group,
    get_membership_for_user,
    get_membership_for_user_in_group,
    list_group_members,
    count_group_members,
    list_memberships_for_user,
    list_groups_by_ids,
    initialize_cash_position,
    remove_member_from_group, 
    delete_group, 
    add_cash_transaction,
    list_cash_transactions_for_group,
    get_cash_balance_for_group,
    add_portfolio_position,
    koersen_updater
    , log_portfolio_transaction, supabase
)
import re

app = Flask(__name__)
app.secret_key = os.environ.get("FLASK_SECRET_KEY", "super-secret-key-voor-dev-mode")
logging.basicConfig(level=logging.INFO)
app.config['TEMPLATES_AUTO_RELOAD'] = True
app.config['SEND_FILE_MAX_AGE_DEFAULT'] = 0

# --- SUPABASE CONFIGURATIE ---
SUPABASE_URL = "https://bpbvlfptoacijyqyugew.supabase.co"
SUPABASE_ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJwYnZsZnB0b2FjaWp5cXl1Z2V3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjA2NDk2NzAsImV4cCI6MjA3NjIyNTY3MH0.6_z9bE3aB4QMt5ASE0bxM6Ds8Tf7189sBDUVLrUeU-M" 

# --- AI CONFIGURATIE (GEMINI) ---
GOOGLE_API_KEY = "AIzaSyAZg1iH9D4oPxzR6mq3RbjUerfmNvZxYCg"
CURRENT_MODEL_NAME = "gemini-1.5-flash"

# We configureren alleen, we roepen NIETS aan bij het opstarten.
# Dit voorkomt dat je limiet opraakt door het herstarten van Flask.
if GOOGLE_API_KEY and "PLAK_HIER" not in GOOGLE_API_KEY:
    try:
        genai.configure(api_key=GOOGLE_API_KEY.strip())
        print("✅ AI Geconfigureerd (Klaar voor gebruik)")
    except Exception as e:
        print(f"⚠️ AI Configuratiefout: {e}")
    
@app.route("/debug/template-info")
def debug_template_info():
    try:
        path = os.path.join(os.path.dirname(__file__), 'templates', 'dashboard.html')
        stat = os.stat(path)
        return jsonify({
            "template_path": path,
            "modified": stat.st_mtime,
            "size": stat.st_size
        })
    except Exception as e:
        return jsonify({"error": str(e)}), 500

# HULPFUNCTIE: Slimme AI aanroep
def generate_ai_content_safe(prompt, retries=1):
    """Probeert AI aan te roepen. Bij drukte wacht hij kort."""
    if not GENAI_AVAILABLE:
        return "⚠️ AI niet beschikbaar op deze Python versie."
    if not GOOGLE_API_KEY or "PLAK_HIER" in GOOGLE_API_KEY:
        return "⚠️ Geen geldige API Key ingesteld."
def _http_quote(symbol: str):
    """Fallback via Yahoo Finance HTTP API (geen yfinance nodig)."""
    try:
        url = f"https://query1.finance.yahoo.com/v7/finance/quote?symbols={symbol}"
        r = requests.get(url, timeout=5)
        data = r.json()
        results = data.get("quoteResponse", {}).get("result", [])
        if not results:
            return None
        item = results[0]
        price = item.get("regularMarketPrice") or item.get("postMarketPrice") or item.get("bid") or item.get("ask")
        return {
            "symbol": item.get("symbol") or symbol,
            "longName": item.get("longName"),
            "shortName": item.get("shortName"),
            "sector": item.get("sector"),  # Vaak None in deze endpoint
            "regularMarketPrice": price,
        }
    except Exception as e:
        logging.debug(f"HTTP quote fout voor {symbol}: {e}")
        return None

def _safe_quote(symbol: str):
    symbol = (symbol or "").strip().upper()
    if not symbol:
        return None
    if YFINANCE_AVAILABLE and yf is not None:
        try:
            ticker = yf.Ticker(symbol)
            info = ticker.get_info() or {}
            fast = getattr(ticker, "fast_info", None) or {}
            price = info.get("regularMarketPrice") or info.get("currentPrice") or fast.get("last_price")
            if price is None:
                hist = ticker.history(period="1d")
                if not hist.empty:
                    price = float(hist["Close"].iloc[-1])
            return {
                "symbol": info.get("symbol") or symbol,
                "longName": info.get("longName"),
                "shortName": info.get("shortName"),
                "sector": info.get("sector"),
                "regularMarketPrice": price,
            }
        except Exception as e:
            logging.debug(f"yfinance quote fout voor {symbol}: {e}; fallback HTTP.")
    return _http_quote(symbol)

    try:
        model = genai.GenerativeModel(CURRENT_MODEL_NAME)
        
        # We proberen het max 2 keer (oorspronkelijk + 1 retry)
        # Minder retries = minder kans op vastlopen in een loop
        for poging in range(retries + 1):
            try:
                response = model.generate_content(prompt)
                return response.text
            except Exception as e:
                error_str = str(e).lower()
                if "429" in error_str or "quota" in error_str or "503" in error_str:
                    if poging < retries:
                        time.sleep(2) # Korte pauze
                        continue
                
                logging.error(f"AI Fout: {e}")
                return f"⚠️ AI even niet beschikbaar ({CURRENT_MODEL_NAME}). Probeer later."
        
        return "⚠️ AI is te druk. Probeer het over een minuutje nog eens."
        
    except Exception as final_err:
        return f"Systeemfout bij AI: {str(final_err)}"


@app.route("/health")
def health():
    return {"status": "ok"}

@app.route("/")
def index():
    return redirect(url_for("home" if session.get("user_id") else "login"))

@app.route("/home")
def home():
    if "user_id" not in session:
        return redirect(url_for("login"))
    group_snapshot = _current_group_snapshot()
    user_groups = _list_user_groups()
    return render_template("home.html", group_snapshot=group_snapshot, user_groups=user_groups)


def _current_group_snapshot():
    membership = _current_group_membership()
    if not membership:
        _clear_group_session()
        return None

    ok_group, group = get_group_by_id(membership["group_id"])
    if not ok_group or not group:
        _clear_group_session()
        return None

    ok_cash, cash_res = initialize_cash_position(group["id"], amount=0)
    ok_count, count_value = count_group_members(group["id"])
    if not ok_count: count_value = 0

    session["group_id"] = group["id"]
    session["group_code"] = group.get("invite_code")

    return {
        "id": group["id"],
        "name": group["name"],
        "code": group.get("invite_code"),
        "member_total": count_value,
    }


def _list_user_groups():
    user_id = session.get("user_id")
    if not user_id: return []

    ok_memberships, memberships = list_memberships_for_user(user_id)
    if not ok_memberships: return []

    group_ids = [entry.get("group_id") for entry in memberships if entry and entry.get("group_id")]
    if not group_ids: return []

    ok_groups, groups = list_groups_by_ids(group_ids)
    if not ok_groups: return []

    group_lookup = {grp["id"]: grp for grp in (groups or []) if grp}
    current_group_id = session.get("group_id")
    decorated = []
    for membership in memberships:
        gid = membership.get("group_id")
        group = group_lookup.get(gid)
        if not group: continue
        ok_count, count_value = count_group_members(gid)
        decorated.append({
            "id": gid,
            "name": group.get("name"),
            "code": group.get("invite_code"),
            "member_total": count_value or 0,
            "role": membership.get("role") or "member",
            "is_current": gid == current_group_id,
        })
    return decorated


def _generate_invite_code(length: int = 6) -> str:
    alphabet = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"
    return "".join(secrets.choice(alphabet) for _ in range(length))


def _prepare_invite_code(requested_code: str | None):
    desired = (requested_code or "").strip().upper()
    if desired:
        ok_exists, exists_or_error = group_code_exists(desired)
        if not ok_exists: return False, f"Kon code niet controleren: {exists_or_error}"
        if exists_or_error: return False, "Deze code is al in gebruik."
        return True, desired

    for _ in range(10):
        generated = _generate_invite_code()
        ok_exists, exists_or_error = group_code_exists(generated)
        if not exists_or_error: return True, generated
    return False, "Kon geen unieke code genereren."


def _current_group_membership():
    user_id = session.get("user_id")
    if not user_id: return None
    desired_group_id = session.get("group_id")
    if desired_group_id:
        ok_specific, membership = get_membership_for_user_in_group(user_id, desired_group_id)
        if ok_specific and membership: return membership

    ok_membership, membership = get_membership_for_user(user_id)
    if membership: session["group_id"] = membership.get("group_id")
    return membership


def _clear_group_session():
    session.pop("group_id", None)
    session.pop("group_code", None)


def _leave_current_group():
    _clear_group_session()


def _resolve_member_profiles(member_rows):
    if not member_rows: return []
    member_ids = [row.get("member_id") for row in member_rows if row and row.get("member_id")]
    if not member_ids: return []
    ok, leden_data = list_leden()
    if not ok: return []

    lookup = {entry.get("ledenid"): entry for entry in leden_data}
    profiles = []
    for row in member_rows:
        mid = row.get("member_id")
        entry = lookup.get(mid, {})
        full_name = f"{entry.get('voornaam', '')} {entry.get('achternaam', '')}".strip() or f"Lid {mid}"
        profiles.append({
            "ledenid": mid,
            "volledige_naam": full_name,
            "email": entry.get("email") or "Onbekend",
            "role": row.get("role") or "member",
        })
    return profiles


def _load_group_context():
    membership = _current_group_membership()
    if not membership: return None, [], "Je hoort momenteel niet bij een groep."

    ok_group, group = get_group_by_id(membership["group_id"])
    if not ok_group or not group: return None, [], None

    ok_members, member_rows = list_group_members(group["id"])
    return group, member_rows, None


@app.route("/groups/create", methods=["GET", "POST"])
def create_group():
    if "user_id" not in session: return redirect(url_for("login"))
    error = None
    name_value = ""
    description_value = ""
    code_value = _generate_invite_code()

    if request.method == "POST":
        name_value = (request.form.get("name") or "").strip()
        description_value = (request.form.get("description") or "").strip()
        requested_code = (request.form.get("code") or "").strip().upper()
        if not name_value:
            error = "Voer een groepsnaam in."
        else:
            ok_code, code_response = _prepare_invite_code(requested_code)
            if not ok_code:
                error = code_response
            else:
                code_value = code_response
                ok_group, group_response = create_group_record(session["user_id"], name=name_value, description=description_value, invite_code=code_value)
                if not ok_group:
                    error = group_response
                else:
                    _leave_current_group()
                    add_member_to_group(group_response["id"], session["user_id"], role="host")
                    initialize_cash_position(group_response["id"], amount=0)
                    session["group_id"] = group_response["id"]
                    session["group_code"] = group_response.get("invite_code")
                    return redirect(url_for("group_dashboard"))

    return render_template("group_create.html", error=error, name_value=name_value, description_value=description_value, code_value=code_value)


@app.route("/groups/join", methods=["GET", "POST"])
def join_group():
    if "user_id" not in session: return redirect(url_for("login"))
    error = None
    code_value = ""

    if request.method == "POST":
        code_value = (request.form.get("code") or "").strip().upper()
        if not code_value:
            error = "Vul een uitnodigingscode in."
        else:
            ok_group, group_response = get_group_by_code(code_value)
            if not ok_group: error = group_response
            elif not group_response: error = "Onbekende code."
            else:
                _leave_current_group()
                add_member_to_group(group_response["id"], session["user_id"], role="member")
                session["group_id"] = group_response["id"]
                session["group_code"] = group_response.get("invite_code")
                initialize_cash_position(group_response["id"], amount=0)
                return redirect(url_for("group_dashboard"))

    return render_template("group_join.html", error=error, code_value=code_value)


@app.route("/groups/current")
def group_dashboard():
    if "user_id" not in session: return redirect(url_for("login"))
    group_data, member_rows, load_error = _load_group_context()
    if not group_data:
        if load_error: return render_template("group.html", group=None, members=[], is_owner=False, error=load_error)
        return redirect(url_for("home"))

    member_profiles = _resolve_member_profiles(member_rows)
    group_context = {
        "id": group_data["id"],
        "name": group_data["name"],
        "code": group_data.get("invite_code"),
        "description": group_data.get("description") or "Geen beschrijving.",
        "created_at": group_data.get("created_at"),
        "member_total": len(member_rows),
        "owner_id": group_data.get("owner_id"),
    }
    is_owner = session.get("user_id") == group_data.get("owner_id")
    return render_template("group.html", group=group_context, members=member_profiles, is_owner=is_owner, error=load_error)


@app.route("/groups/select/<int:group_id>", methods=["POST"])
def select_group(group_id):
    if "user_id" not in session: return redirect(url_for("login"))
    user_id = session["user_id"]
    ok_membership, membership = get_membership_for_user_in_group(user_id, group_id)
    if ok_membership and membership:
        session["group_id"] = group_id
        ok_group, group = get_group_by_id(group_id)
        if ok_group and group: session["group_code"] = group.get("invite_code")
    return redirect(url_for("group_dashboard"))


@app.route("/portfolio")
def portfolio():
    if "user_id" not in session: return redirect(url_for("login"))
    active_group = _current_group_snapshot()
    user_groups = _list_user_groups()
    return render_template("dashboard.html", supabase_url=SUPABASE_URL, supabase_key=SUPABASE_ANON_KEY, active_group=active_group, user_groups=user_groups)


@app.route("/cash", methods=["GET", "POST"])
def cashbox():
    if "user_id" not in session: return redirect(url_for("login"))
    membership = _current_group_membership()
    if not membership: return redirect(url_for("home"))
    group_id = membership["group_id"]
    error = None

    if request.method == "POST":
        try:
            amount = float(request.form.get("amount", "0").strip())
            direction = (request.form.get("direction") or "").strip().lower()
            description = (request.form.get("description") or "").strip()
            if amount <= 0 or direction not in ("in", "out"):
                error = "Ongeldige invoer"
            else:
                add_cash_transaction(group_id, amount, direction, description, created_by=session.get("user_id"))
                return redirect(url_for("cashbox"))
        except: error = "Ongeldige invoer"

    ok_hist, history = list_cash_transactions_for_group(group_id)
    ok_bal, balance = get_cash_balance_for_group(group_id)
    return render_template("cashbox.html", balance=balance if ok_bal else 0.0, history=history if ok_hist else [], error=error)

@app.route("/transactions")
def transactions_page():
    if "user_id" not in session: return redirect(url_for("login"))
    membership = _current_group_membership()
    if not membership: return redirect(url_for("home"))
    group_id = membership["group_id"]
    # Haal transacties op door join op portefeuille_id voor naam/ticker (optioneel)
    try:
        tx_res = supabase.table("Transacties").select("transactie_id, datum_tr, aantal, ticker, type, portefeuille_id, koers, wisselkoers, munt")\
            .order("datum_tr", desc=True).execute()
        transactions = tx_res.data or []
    except Exception as e:
        transactions = []
    return render_template("transactions.html", transactions=transactions)

@app.route("/api/transactions/log", methods=["POST"])
def api_log_transaction():
    if "user_id" not in session: return jsonify({"error": "Niet ingelogd"}), 401
    data = request.get_json() or {}
    portfolio_id = data.get("portefeuille_id")
    ticker = (data.get("ticker") or "").upper().strip()
    trade_type = (data.get("type") or "").upper().strip()
    amount = float(data.get("aantal") or 0)
    price = float(data.get("koers") or 0)
    exchange_rate = float(data.get("wisselkoers") or 1)
    currency = (data.get("munt") or "EUR").upper()
    if not trade_type or trade_type not in ("BUY", "SELL", "DIVIDEND", "FEE"):
        return jsonify({"error": "Ongeldig type"}), 400
    if not ticker:
        return jsonify({"error": "Ticker vereist"}), 400
    if amount <= 0 or price <= 0:
        return jsonify({"error": "Aantal en prijs moeten > 0 zijn"}), 400
    # Resolve portfolio_id by current group + ticker if missing
    try:
        if not portfolio_id and ticker:
            membership = _current_group_membership()
            if membership and membership.get("group_id"):
                gid = membership["group_id"]
                lookup = supabase.table("Portefeuille").select("port_id").eq("groep_id", gid).eq("ticker", ticker).limit(1).execute()
                if lookup.data:
                    portfolio_id = lookup.data[0].get("port_id")
    except Exception as e:
        # continue without portfolio_id if lookup fails; DB may allow NULL
        app.logger.warning(f"Kon port_id niet vinden voor {ticker}: {e}")
    ok, res = log_portfolio_transaction(portfolio_id, ticker, trade_type, amount, price, exchange_rate, currency)
    if not ok:
        return jsonify({"error": res}), 400
    return jsonify({"transaction": res})


@app.route("/api/quote/<symbol>")
def yahoo_quote(symbol: str):
    if "user_id" not in session:
        return jsonify({"error": "Niet ingelogd"}), 401
    data = _safe_quote(symbol)
    if not data or data.get("regularMarketPrice") is None:
        return jsonify({"error": "Niet gevonden"}), 404
    return jsonify(data)

@app.route("/leden")
def leden():
    if "user_id" not in session: return redirect(url_for("login"))
    ok, res = list_leden()
    return render_template("leden.html", leden=res if ok else [], error=None if ok else str(res))

@app.route("/logout")
def logout():
    session.clear()
    return redirect(url_for("login"))

@app.route("/login", methods=["GET", "POST"])
def login():
    if request.method == "POST":
        email = (request.form.get("email") or "").strip().lower()
        ok, res = sign_in_user(email)
        if ok:
            session["user_id"] = res.get("ledenid")
            session["email"] = res.get("email")
            return redirect(url_for("home"))
        return render_template("login.html", error=res, email_value=email)
    return render_template("login.html")

@app.route("/register", methods=["GET", "POST"])
def register():
    if request.method == "POST":
        email = request.form.get("email", "").strip()
        voornaam = request.form.get("voornaam", "").strip()
        achternaam = request.form.get("achternaam", "").strip()
        gsm_raw = request.form.get("gsm", "").strip()
        digits = "".join(ch for ch in gsm_raw if ch.isdigit())
        gsm = int(digits) if digits else 0
        
        ok, res = sign_up_user(email, voornaam, achternaam, gsm)
        if ok: return redirect(url_for("login"))
        return render_template("register.html", error=res)
    return render_template("register.html")

@app.errorhandler(Exception)
def handle_any_exception(e):
    if isinstance(e, HTTPException): return e
    logging.error(f"Error: {e}")
    return render_template("error.html", error=str(e)), 500

@app.route("/groups/leave", methods=["POST"])
def leave_group():
    if "user_id" not in session: return redirect(url_for("login"))
    group_id = session.get("group_id")
    if group_id:
        remove_member_from_group(group_id, session["user_id"])
        _leave_current_group()
    return redirect(url_for("home"))

@app.route("/groups/delete", methods=["POST"])
def delete_group_route():
    if "user_id" not in session: return redirect(url_for("login"))
    group_id = session.get("group_id")
    if group_id:
        delete_group(group_id)
        _leave_current_group()
    return redirect(url_for("home"))

@app.route("/groups/remove-member/<int:member_id>", methods=["POST"])
def remove_group_member(member_id: int):
    if "user_id" not in session: return redirect(url_for("login"))
    group_id = session.get("group_id")
    if group_id: remove_member_from_group(group_id, member_id)
    return redirect("/groups/current")

@app.route("/group/<int:group_id>/import_csv", methods=["POST"])
def import_csv(group_id):
    if "user_id" not in session: return redirect(url_for("login"))
    file = request.files.get('file')
    if file and file.filename:
        try:
            stream = io.StringIO(file.stream.read().decode("UTF8"), newline=None)
            try: df = pd.read_csv(stream, sep=None, engine='python')
            except: 
                stream.seek(0)
                df = pd.read_csv(stream, sep=';')
            
            df.columns = [str(c).lower().strip() for c in df.columns]
            col_map = {
                'ticker': ['ticker', 'symbol', 'symbool', 'product', 'isin'],
                'amount': ['aantal', 'quantity', 'stuks', 'number'],
                'price': ['price', 'prijs', 'koers', 'aankoopprijs', 'avg price', 'cost']
            }
            found = {}
            for k, opts in col_map.items():
                for o in opts:
                    if o in df.columns: 
                        found[k] = o
                        break
            
            if len(found) == 3:
                cnt = 0
                for _, row in df.iterrows():
                    try:
                        t = str(row[found['ticker']]).upper().strip()
                        def clean(v):
                            if isinstance(v, (int, float)): return float(v)
                            v = str(v).replace('€','').replace('$','').strip()
                            if ',' in v and '.' in v:
                                if v.find(',') < v.find('.'): v = v.replace(',','')
                                else: v = v.replace('.','').replace(',','.')
                            elif ',' in v: v = v.replace(',','.')
                            return float(v)
                        a = clean(row[found['amount']])
                        p = clean(row[found['price']])
                        if t and a > 0:
                            add_portfolio_position(group_id, t, a, p, session["user_id"])
                            cnt += 1
                    except: pass
                flash(f"Succes! {cnt} posities geïmporteerd.", "success")
            else:
                flash("Kolommen niet gevonden.", "error")
        except Exception as e:
            flash(f"Fout: {e}", "error")
    return redirect(url_for("portfolio"))

# NIEUWE ROUTE: Koersen verversen
@app.route("/group/<int:group_id>/refresh_prices", methods=["GET", "POST"])
def refresh_prices(group_id):
    if "user_id" not in session:
        return redirect(url_for("login"))
    
    ok, msg = koersen_updater(group_id)
    if ok:
        flash(f"Koersen ververst: {msg}", "success")
    else:
        flash(f"Fout bij verversen: {msg}", "error")
        
    return redirect(url_for("portfolio"))

# --- AI ROUTE 1: ANALYSEER LOS AANDEEL ---
@app.route("/api/ai/analyze-stock", methods=["POST"])
def ai_analyze_stock():
    if "user_id" not in session: return jsonify({"error": "Niet ingelogd"}), 401
    
    data = request.get_json()
    ticker = data.get("ticker", "").upper()
    if not ticker: return jsonify({"error": "Geen ticker"}), 400

    # Haal info op voor context
    name = ticker
    if YFINANCE_AVAILABLE and yf is not None:
        try:
            t = yf.Ticker(ticker)
            name = t.info.get("longName", ticker)
        except Exception:
            pass
    else:
        http_q = _http_quote(ticker)
        if http_q and http_q.get("longName"):
            name = http_q.get("longName")

    prompt = f"""
    Analyseer het financiële instrument: {ticker} ({name}).
    Je antwoord moet in het Nederlands zijn en HTML geformatteerd (gebruik <h3>, <p>, <ul>, <li>).
    
    Geef antwoord op deze punten:
    1. **Sector/Categorie**: Is dit een individueel aandeel of een ETF? Welke sector?
    2. **Bedrijfsanalyse**: Wat doet dit bedrijf/ETF? Sterke punten?
    3. **Risico's**: Wat zijn de grootste risico's?
    4. **Conclusie**: Een korte conclusie.
    
    Houd het professioneel.
    """
    
    result = generate_ai_content_safe(prompt)
    return jsonify({"analysis": result})

# --- AI ROUTE 2: ANALYSEER PORTEFEUILLE ---
@app.route("/api/ai/analyze-portfolio", methods=["POST"])
def ai_analyze_portfolio():
    if "user_id" not in session: return jsonify({"error": "Niet ingelogd"}), 401
    
    data = request.get_json()
    positions = data.get("positions", [])
    if not positions: return jsonify({"error": "Lege portefeuille"}), 400

    summary_list = []
    for p in positions:
        ticker = p.get('ticker')
        if ticker == 'CASH': continue
        summary_list.append(f"- {ticker}: {p.get('quantity')} stuks (Waarde: €{p.get('value', 0)})")
    
    summary_text = "\n".join(summary_list)

    prompt = f"""
    Je bent een financiële expert. Analyseer deze beleggingsportefeuille:
    
    {summary_text}
    
    Geef antwoord in het Nederlands, geformatteerd met HTML.
    Focus op:
    1. **Diversificatie**: Spreiding over sectoren/regio's?
    2. **Risico**: Offensief of defensief?
    3. **Tips**: 3 concrete verbeterpunten.
    """
    
    result = generate_ai_content_safe(prompt)
    return jsonify({"analysis": result})


if __name__ == "__main__":
    app.run(debug=True)