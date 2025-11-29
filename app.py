from flask import Flask, render_template, request, redirect, session, url_for, jsonify, flash, get_flashed_messages
import os, logging, traceback, secrets
import yfinance as yf
from werkzeug.exceptions import HTTPException
import pandas as pd
import io 
import google.generativeai as genai
import json
import time # Nodig voor de pauze-functie

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
)
import re

app = Flask(__name__)
app.secret_key = os.environ.get("FLASK_SECRET_KEY", "super-secret-key-voor-dev-mode")
logging.basicConfig(level=logging.INFO)

# --- SUPABASE CONFIGURATIE ---
SUPABASE_URL = "https://bpbvlfptoacijyqyugew.supabase.co"
SUPABASE_ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJwYnZsZnB0b2FjaWp5cXl1Z2V3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjA2NDk2NzAsImV4cCI6MjA3NjIyNTY3MH0.6_z9bE3aB4QMt5ASE0bxM6Ds8Tf7189sBDUVLrUeU-M" 

# --- AI CONFIGURATIE (GEMINI) ---
GOOGLE_API_KEY = "AIzaSyBk0oahchDJDCldvLqMQ-H_ZnKt_svOaKc" # Zorg dat hier je werkende sleutel staat!

CURRENT_MODEL_NAME = "gemini-1.5-flash"

# HULPFUNCTIE: Slimme AI aanroep met retry
def generate_ai_content_safe(prompt, retries=3):
    """Probeert AI aan te roepen. Bij drukte wacht hij even en probeert opnieuw."""
    if not GOOGLE_API_KEY or "PLAK_HIER" in GOOGLE_API_KEY:
        return "⚠️ Geen geldige API Key ingesteld."

    try:
        model = genai.GenerativeModel(CURRENT_MODEL_NAME)
        
        # Probeer het een paar keer als het druk is
        for poging in range(retries):
            try:
                response = model.generate_content(prompt)
                return response.text
            except Exception as e:
                # Als het een Quota error is (429)
                error_str = str(e).lower()
                if "429" in error_str or "quota" in error_str or "resource exhausted" in error_str:
                    wait_time = (poging + 1) * 5 # Wacht 5, 10, 15 seconden...
                    logging.warning(f"AI Quota bereikt. Wachten voor {wait_time} seconden en opnieuw proberen...")
                    time.sleep(wait_time)
                    continue # Probeer opnieuw
                else:
                    # Andere fout? Gooi hem dan direct op
                    raise e
        
        return "⚠️ AI is momenteel te druk. Probeer het over een minuutje nog eens."
        
    except Exception as final_err:
        logging.error(f"AI Definitieve Fout: {final_err}")
        return f"Fout bij analyse: {str(final_err)}"


# AUTOMATISCHE MODEL DETECTIE
print("\n--- 🤖 AI INITIALISATIE... ---")
if GOOGLE_API_KEY and "PLAK_HIER" not in GOOGLE_API_KEY:
    try:
        clean_key = GOOGLE_API_KEY.strip()
        genai.configure(api_key=clean_key)
        
        print(f"Gebruikte Key (eerste 5 tekens): {clean_key[:5]}...")

        # Probeer modellen te vinden
        my_models = []
        try:
            for m in genai.list_models():
                if 'generateContent' in m.supported_generation_methods:
                    name = m.name.replace('models/', '')
                    my_models.append(name)
        except:
            my_models = ['gemini-pro'] # Fallback

        # Kies slim de beste
        if 'gemini-1.5-flash' in my_models:
            CURRENT_MODEL_NAME = 'gemini-1.5-flash'
        elif 'gemini-pro' in my_models:
            CURRENT_MODEL_NAME = 'gemini-pro'
        elif len(my_models) > 0:
            CURRENT_MODEL_NAME = my_models[0]
            
        print(f"✅ GESELECTEERD MODEL: {CURRENT_MODEL_NAME}")
        
    except Exception as e:
        print(f"❌ FOUT BIJ AI STARTUP: {e}")
else:
    print("⚠️ Geen (geldige) API Key ingevuld in app.py.")
print("-----------------------------\n")


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
    """Geeft een compacte snapshot van de huidige groep of None."""
    membership = _current_group_membership()
    if not membership:
        _clear_group_session()
        return None

    ok_group, group = get_group_by_id(membership["group_id"])
    if not ok_group:
        logging.error("Kon groep niet ophalen: %s", group)
        _clear_group_session()
        return None
    if not group:
        _clear_group_session()
        return None

    ok_cash, cash_res = initialize_cash_position(group["id"], amount=0)
    if not ok_cash:
        logging.warning("Cashpositie initialiseren voor groep %s mislukt: %s", group["id"], cash_res)

    ok_count, count_value = count_group_members(group["id"])
    if not ok_count:
        logging.warning("Kon leden niet tellen: %s", count_value)
        count_value = 0

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
    if not user_id:
        return []

    ok_memberships, memberships = list_memberships_for_user(user_id)
    if not ok_memberships:
        logging.error("Kon lidmaatschappen niet laden: %s", memberships)
        return []

    group_ids = [entry.get("group_id") for entry in memberships if entry and entry.get("group_id")]
    if not group_ids:
        return []

    ok_groups, groups = list_groups_by_ids(group_ids)
    if not ok_groups:
        logging.error("Kon groepen niet ophalen: %s", groups)
        return []

    group_lookup = {grp["id"]: grp for grp in (groups or []) if grp}
    current_group_id = session.get("group_id")
    decorated = []
    for membership in memberships:
        gid = membership.get("group_id")
        group = group_lookup.get(gid)
        if not group:
            continue
        ok_count, count_value = count_group_members(gid)
        if not ok_count:
            logging.warning("Kon leden niet tellen voor groep %s: %s", gid, count_value)
            count_value = None
        decorated.append({
            "id": gid,
            "name": group.get("name"),
            "code": group.get("invite_code"),
            "member_total": count_value,
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
        if not ok_exists:
            return False, f"Kon code niet controleren: {exists_or_error}"
        if exists_or_error:
            return False, "Deze code is al in gebruik. Kies een andere code."
        return True, desired

    for _ in range(10):
        generated = _generate_invite_code()
        ok_exists, exists_or_error = group_code_exists(generated)
        if not ok_exists:
            return False, f"Kon code niet controleren: {exists_or_error}"
        if not exists_or_error:
            return True, generated
    return False, "Kon geen unieke code genereren. Probeer later opnieuw."


def _current_group_membership():
    user_id = session.get("user_id")
    if not user_id:
        return None
    desired_group_id = session.get("group_id")
    if desired_group_id:
        ok_specific, membership = get_membership_for_user_in_group(user_id, desired_group_id)
        if ok_specific and membership:
            return membership
        if not ok_specific:
            logging.error("Kon lidmaatschap niet ophalen voor groep %s: %s", desired_group_id, membership)

    ok_membership, membership = get_membership_for_user(user_id)
    if not ok_membership:
        logging.error("Kon lidmaatschap niet laden: %s", membership)
        return None
    if membership:
        session["group_id"] = membership.get("group_id")
    return membership


def _clear_group_session():
    session.pop("group_id", None)
    session.pop("group_code", None)


def _leave_current_group():
    # Alleen de sessie wissen zodat de gebruiker meerdere groepen kan behouden
    _clear_group_session()


def _resolve_member_profiles(member_rows):
    if not member_rows:
        return []
    member_ids = [row.get("member_id") for row in member_rows if row and row.get("member_id")]
    if not member_ids:
        return []
    ok, leden_data = list_leden()
    if not ok:
        return [{"ledenid": mid, "volledige_naam": f"Lid {mid}", "email": "Onbekend", "role": "member"} for mid in sorted(member_ids)]

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
    if not membership:
        return None, [], "Je hoort momenteel niet bij een groep."

    ok_group, group = get_group_by_id(membership["group_id"])
    if not ok_group:
        return None, [], group
    if not group:
        return None, [], None

    ok_members, member_rows = list_group_members(group["id"])
    if not ok_members:
        return group, [], member_rows
    return group, member_rows, None


@app.route("/groups/create", methods=["GET", "POST"])
def create_group():
    if "user_id" not in session:
        return redirect(url_for("login"))

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
                ok_group, group_response = create_group_record(
                    owner_id=session["user_id"],
                    name=name_value,
                    description=description_value,
                    invite_code=code_value,
                )
                if not ok_group:
                    error = group_response
                else:
                    _leave_current_group()
                    ok_member, member_response = add_member_to_group(
                        group_response["id"],
                        session["user_id"],
                        role="host",
                    )
                    if not ok_member:
                        error = member_response
                    else:
                        ok_cash, cash_response = initialize_cash_position(group_response["id"], amount=0)
                        if not ok_cash:
                            logging.warning("Cashpositie kon niet worden aangemaakt voor groep %s: %s", group_response["id"], cash_response)
                        session["group_id"] = group_response["id"]
                        session["group_code"] = group_response.get("invite_code")
                        return redirect(url_for("group_dashboard"))

    return render_template(
        "group_create.html",
        error=error,
        name_value=name_value,
        description_value=description_value,
        code_value=code_value,
    )


@app.route("/groups/join", methods=["GET", "POST"])
def join_group():
    if "user_id" not in session:
        return redirect(url_for("login"))

    error = None
    code_value = ""

    if request.method == "POST":
        code_value = (request.form.get("code") or "").strip().upper()
        if not code_value:
            error = "Vul een uitnodigingscode in."
        else:
            ok_group, group_response = get_group_by_code(code_value)
            if not ok_group:
                error = group_response
            elif not group_response:
                error = "Onbekende code. Controleer je invoer."
            else:
                _leave_current_group()
                ok_member, member_response = add_member_to_group(
                    group_response["id"],
                    session["user_id"],
                    role="member",
                )
                if not ok_member:
                    error = member_response
                else:
                    session["group_id"] = group_response["id"]
                    session["group_code"] = group_response.get("invite_code")
                    ok_cash, cash_response = initialize_cash_position(group_response["id"], amount=0)
                    if not ok_cash:
                        logging.warning("Cashpositie kon niet worden aangemaakt voor groep %s bij join: %s", group_response["id"], cash_response)
                    return redirect(url_for("group_dashboard"))

    return render_template("group_join.html", error=error, code_value=code_value)


@app.route("/groups/current")
def group_dashboard():
    if "user_id" not in session:
        return redirect(url_for("login"))

    group_data, member_rows, load_error = _load_group_context()
    if not group_data:
        if load_error:
            return render_template("group.html", group=None, members=[], is_owner=False, error=load_error)
        return redirect(url_for("home"))

    member_profiles = _resolve_member_profiles(member_rows)
    group_context = {
        "id": group_data["id"],
        "name": group_data["name"],
        "code": group_data.get("invite_code"),
        "description": group_data.get("description") or "Geen beschrijving opgegeven.",
        "created_at": group_data.get("created_at"),
        "member_total": len(member_rows),
        "owner_id": group_data.get("owner_id"),
    }
    is_owner = session.get("user_id") == group_data.get("owner_id")

    return render_template(
        "group.html",
        group=group_context,
        members=member_profiles,
        is_owner=is_owner,
        error=load_error,
    )


@app.route("/groups/select/<int:group_id>", methods=["POST"])
def select_group(group_id):
    if "user_id" not in session:
        return redirect(url_for("login"))

    user_id = session["user_id"]
    ok_membership, membership = get_membership_for_user_in_group(user_id, group_id)
    if not ok_membership:
        logging.error("Kon lidmaatschap niet ophalen: %s", membership)
        return redirect(url_for("home"))
    if not membership:
        logging.warning("Lid %s probeerde groep %s te openen zonder lidmaatschap", user_id, group_id)
        return redirect(url_for("home"))

    session["group_id"] = group_id
    ok_group, group = get_group_by_id(group_id)
    if ok_group and group:
        session["group_code"] = group.get("invite_code")
    else:
        logging.warning("Kon groepgegevens niet ophalen voor selectie %s: %s", group_id, group)

    return redirect(url_for("group_dashboard"))


@app.route("/portfolio")
def portfolio():
    if "user_id" not in session:
        return redirect(url_for("login"))
    active_group = _current_group_snapshot()
    user_groups = _list_user_groups()

    return render_template(
        "dashboard.html",
        supabase_url=SUPABASE_URL,
        supabase_key=SUPABASE_ANON_KEY,
        active_group=active_group,
        user_groups=user_groups,
    )


@app.route("/cash", methods=["GET", "POST"])
def cashbox():
    if "user_id" not in session:
        return redirect(url_for("login"))

    membership = _current_group_membership()
    if not membership:
        return redirect(url_for("home"))

    group_id = membership["group_id"]
    error = None

    if request.method == "POST":
        try:
            amount_raw = request.form.get("amount", "0").strip()
            direction = (request.form.get("direction") or "").strip().lower()
            description = (request.form.get("description") or "").strip()
            amount = float(amount_raw)
            if amount <= 0:
                error = "Bedrag moet groter dan 0 zijn"
            elif direction not in ("in", "out"):
                error = "Type moet 'in' of 'out' zijn"
            else:
                ok, res = add_cash_transaction(group_id, amount, direction, description, created_by=session.get("user_id"))
                if not ok:
                    error = f"Transactie opslaan mislukt: {res}"
                else:
                    return redirect(url_for("cashbox"))
        except Exception as exc:
            error = f"Ongeldige invoer: {exc}"

    ok_hist, history = list_cash_transactions_for_group(group_id)
    if not ok_hist:
        history = []
        error = error or f"Kon transacties niet laden: {history}"

    ok_bal, balance = get_cash_balance_for_group(group_id)
    if not ok_bal:
        balance = 0.0
        error = error or f"Kon saldo niet berekenen: {balance}"

    return render_template("cashbox.html", balance=balance, history=history, error=error)


@app.route("/api/quote/<symbol>")
def yahoo_quote(symbol: str):
    if "user_id" not in session:
        return jsonify({"error": "Niet ingelogd"}), 401
    symbol = (symbol or "").strip().upper()
    if not symbol:
        return jsonify({"error": "Geen ticker opgegeven"}), 400

    try:
        ticker = yf.Ticker(symbol)
        info = {}
        try:
            info = ticker.get_info() or {}
        except Exception as exc:
            logging.warning("yfinance info voor %s mislukt: %s", symbol, exc)
            info = {}

        fast = getattr(ticker, "fast_info", None) or {}
        price = (
            info.get("regularMarketPrice")
            or info.get("currentPrice")
            or fast.get("last_price")
            or fast.get("last_close")
            or fast.get("previous_close")
        )

        if price is None:
            history = ticker.history(period="1d")
            if not history.empty:
                price = float(history["Close"].iloc[-1])

        if price is None and not info:
            return jsonify({"error": "Ticker niet gevonden"}), 404

        sanitized = {
            "symbol": info.get("symbol") or symbol,
            "longName": info.get("longName"),
            "shortName": info.get("shortName"),
            "sector": info.get("sector") or info.get("industry") or fast.get("sector"),
            "currency": info.get("currency") or fast.get("currency"),
            "regularMarketPrice": price,
            "postMarketPrice": info.get("postMarketPrice"),
            "marketState": info.get("marketState"),
        }
        return jsonify(sanitized)
    except Exception as exc:
        logging.error("yfinance call mislukt voor %s: %s", symbol, exc)
        return jsonify({"error": "Kon koers niet ophalen"}), 502

@app.route("/leden")
def leden():
    if "user_id" not in session:
        return redirect(url_for("login"))
    ok, res = list_leden()
    if not ok:
        return render_template("leden.html", leden=[], error=f"Fetch error: {res}")
    return render_template("leden.html", leden=res)

@app.route("/logout")
def logout():
    session.clear()
    return redirect(url_for("login"))

@app.route("/login", methods=["GET", "POST"])
def login():
    if request.method == "POST":
        email = (request.form.get("email") or "").strip().lower()
        if not email:
            return render_template("login.html", error="Voer een e-mailadres in.", email_value=email)
        pattern = r"^[^@\s]+@[^@\s]+\.[^@\s]+$"
        if not re.match(pattern, email):
            return render_template("login.html", error="Ongeldig e-mailadres formaat.", email_value=email)
        ok, res = sign_in_user(email)
        if not ok:
            return render_template("login.html", error=res, email_value=email)
        session["user_id"] = res.get("ledenid")
        session["email"] = res.get("email")
        return redirect(url_for("home"))
    preset_email = request.args.get("email", "")
    return render_template("login.html", email_value=preset_email)

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
        if ok:
            return redirect(url_for("login", email=email, mode="login"))
        return render_template("register.html", error=res, email_value=email, voornaam_value=voornaam, achternaam_value=achternaam, gsm_value=gsm_raw)
    return render_template("register.html", email_value=request.args.get("email", ""))

@app.errorhandler(Exception)
def handle_any_exception(e):
    if isinstance(e, HTTPException):
        return e
    logging.error("Unhandled exception: %s", e)
    traceback.print_exc()
    return render_template("error.html", error=str(e)), 500

@app.route("/groups/leave", methods=["POST"])
def leave_group():
    if "user_id" not in session:
        return redirect(url_for("login"))
    
    group_id = session.get("group_id")
    if not group_id:
        return redirect(url_for("home"))
    
    user_id = session["user_id"]
    ok_remove, response = remove_member_from_group(group_id, user_id)
    
    if not ok_remove:
        logging.error("Kon lid niet verwijderen: %s", response)
        return redirect(url_for("group_dashboard"))
    
    _leave_current_group()
    return redirect(url_for("home"))


@app.route("/groups/delete", methods=["POST"])
def delete_group_route():
    if "user_id" not in session:
        return redirect(url_for("login"))
    
    group_id = session.get("group_id")
    if not group_id:
        return redirect(url_for("home"))
    
    user_id = session["user_id"]
    
    # Controleer of gebruiker eigenaar is
    ok_group, group = get_group_by_id(group_id)
    if not ok_group or not group:
        return redirect(url_for("home"))
    
    if group.get("owner_id") != user_id:
        logging.warning("Gebruiker %s probeerde groep %s te verwijderen zonder eigenaar te zijn", user_id, group_id)
        return redirect(url_for("group_dashboard"))
    
    ok_delete, response = delete_group(group_id)
    
    if not ok_delete:
        logging.error("Kon groep niet verwijderen: %s", response)
        return redirect(url_for("group_dashboard"))
    
    _leave_current_group()
    return redirect(url_for("home"))


@app.route("/groups/remove-member/<int:member_id>", methods=["POST"])
def remove_group_member(member_id: int):
    if "user_id" not in session:
        return redirect(url_for("login"))
    
    group_id = session.get("group_id")
    if not group_id:
        return jsonify({"error": "Geen groep geselecteerd"}), 400
    
    user_id = session["user_id"]
    
    # Controleer of gebruiker eigenaar is
    ok_group, group = get_group_by_id(group_id)
    if not ok_group or not group:
        return jsonify({"error": "Groep niet gevonden"}), 404
    
    if group.get("owner_id") != user_id:
        return jsonify({"error": "Alleen de host kan leden verwijderen"}), 403
    
    ok_remove, response = remove_member_from_group(group_id, member_id)
    
    if not ok_remove:
        logging.error("Kon lid %s niet verwijderen: %s", member_id, response)
        return jsonify({"error": response}), 500
    
    return redirect("/groups/current")

# --- NIEUWE ROUTE VOOR CSV IMPORT ---
@app.route("/group/<int:group_id>/import_csv", methods=["POST"])
def import_csv(group_id):
    if "user_id" not in session:
        flash("Je moet ingelogd zijn.", "error")
        return redirect(url_for("login"))

    # Check of de gebruiker toegang heeft tot de groep
    user_id = session["user_id"]
    ok_membership, _ = get_membership_for_user_in_group(user_id, group_id)
    if not ok_membership:
        flash("Geen toegang tot deze groep.", "error")
        return redirect(url_for("portfolio"))

    if 'file' not in request.files:
        flash("Geen bestand gevonden in het verzoek.", "error")
        return redirect(url_for("portfolio"))

    file = request.files['file']
    
    if file.filename == '':
        flash("Geen bestand geselecteerd.", "error")
        return redirect(url_for("portfolio"))

    if file:
        try:
            # 1. Lees het bestand in het geheugen
            stream = io.StringIO(file.stream.read().decode("UTF8"), newline=None)
            
            # 2. Probeer CSV te lezen (ondersteunt ; en , als scheidingsteken)
            try:
                # Probeer eerst met pandas auto-detectie
                df = pd.read_csv(stream, sep=None, engine='python')
            except Exception as read_err:
                print(f"Pandas auto-read failed: {read_err}")
                # Fallback: forceer puntkomma (veel gebruikt in Europa)
                stream.seek(0)
                df = pd.read_csv(stream, sep=';')

            if df.empty:
                flash("Het geüploade bestand is leeg.", "error")
                return redirect(url_for("portfolio"))

            # 3. Kolomnamen normaliseren (alles kleine letters, geen spaties)
            df.columns = [str(c).lower().strip() for c in df.columns]
            
            # 4. Zoek de juiste kolommen (maakt niet uit hoe je broker ze noemt)
            col_map = {
                'ticker': ['ticker', 'symbol', 'symbool', 'product', 'isin'],
                'amount': ['aantal', 'quantity', 'stuks', 'number'],
                'price': ['price', 'prijs', 'koers', 'aankoopprijs', 'avg price', 'gem. aankoopprijs', 'cost']
            }

            found_cols = {}
            for key, options in col_map.items():
                for opt in options:
                    if opt in df.columns:
                        found_cols[key] = opt
                        break
            
            # Check of we alles gevonden hebben
            if len(found_cols) == 3:
                count = 0
                errors = 0
                for index, row in df.iterrows():
                    try:
                        ticker_val = row[found_cols['ticker']]
                        amount_val = row[found_cols['amount']]
                        price_val = row[found_cols['price']]

                        # Overslaan als leeg
                        if pd.isna(ticker_val) or pd.isna(amount_val):
                            continue

                        ticker = str(ticker_val).upper().strip()

                        # Getallen opschonen (komma naar punt, valuta tekens weg)
                        def clean_number(val):
                            if isinstance(val, (int, float)):
                                return float(val)
                            val = str(val).replace('€', '').replace('$', '').strip()
                            # Europees formaat 1.000,00 -> 1000.00
                            if ',' in val and '.' in val:
                                if val.find(',') < val.find('.'):
                                    val = val.replace(',', '') # 1,000.00 -> 1000.00
                                else:
                                    val = val.replace('.', '').replace(',', '.') # 1.000,00 -> 1000.00
                            elif ',' in val:
                                val = val.replace(',', '.')
                            return float(val)

                        amount = clean_number(amount_val)
                        price = clean_number(price_val)

                        if ticker and amount > 0:
                            # Opslaan in DB via auth.py functie
                            ok, msg = add_portfolio_position(group_id, ticker, amount, price, user_id)
                            if ok:
                                count += 1
                            else:
                                print(f"DB Error row {index}: {msg}")
                                errors += 1
                    except Exception as row_error:
                        print(f"Skipping row {index}: {row_error}")
                        errors += 1

                if count > 0:
                    flash(f"Succes! {count} posities geïmporteerd.", "success")
                else:
                    flash("Geen geldige posities gevonden in het bestand.", "error")
            else:
                missing = [k for k in ['ticker', 'amount', 'price'] if k not in found_cols]
                flash(f"Kon de juiste kolommen niet vinden. Ontbrekend: {', '.join(missing)}. Controleer je CSV.", "error")
                print(f"Gevonden kolommen in CSV: {df.columns}")

        except Exception as e:
            print(f"Fout bij CSV import: {e}")
            logging.error(traceback.format_exc())
            flash(f"Er ging iets mis bij het importeren: {str(e)}", "error")

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
    try:
        t = yf.Ticker(ticker)
        name = t.info.get("longName", ticker)
    except: pass

    prompt = f"""
    Analyseer het financiële instrument: {ticker} ({name}).
    Je antwoord moet in het Nederlands zijn en HTML geformatteerd (gebruik <h3>, <p>, <ul>, <li>).
    
    Geef antwoord op deze punten:
    1. **Sector/Categorie**: Is dit een individueel aandeel of een ETF? Welke sector? (Zet dit duidelijk bovenaan).
    2. **Bedrijfsanalyse**: Wat doet dit bedrijf/ETF? Wat zijn de sterke punten?
    3. **Risico's**: Wat zijn de 2 grootste risico's?
    4. **Conclusie**: Een korte conclusie (1 zin).
    
    Houd het beknopt en professioneel.
    """
    
    # Gebruik de veilige functie met retry
    result = generate_ai_content_safe(prompt)
    return jsonify({"analysis": result})

# --- AI ROUTE 2: ANALYSEER PORTEFEUILLE ---
@app.route("/api/ai/analyze-portfolio", methods=["POST"])
def ai_analyze_portfolio():
    if "user_id" not in session: return jsonify({"error": "Niet ingelogd"}), 401
    
    data = request.get_json()
    positions = data.get("positions", [])
    if not positions: return jsonify({"error": "Lege portefeuille"}), 400

    # Maak een samenvatting voor de AI
    summary_list = []
    for p in positions:
        ticker = p.get('ticker')
        if ticker == 'CASH': continue
        summary_list.append(f"- {ticker}: {p.get('quantity')} stuks (Waarde: €{p.get('value', 0)})")
    
    summary_text = "\n".join(summary_list)

    prompt = f"""
    Je bent een financiële expert. Analyseer deze beleggingsportefeuille:
    
    {summary_text}
    
    Geef antwoord in het Nederlands, geformatteerd met HTML (gebruik <h3>, <p>, <ul>, <li>, <strong>).
    
    Focus op:
    1. **Diversificatie**: Is er voldoende spreiding over sectoren en regio's?
    2. **Risico**: Is de portefeuille offensief of defensief?
    3. **Tips**: Geef 3 concrete, korte tips om deze portefeuille te verbeteren (bijv. "Overweeg meer tech" of "Te veel blootstelling aan VS").
    
    Houd het constructief en beknopt.
    """
    
    # Gebruik de veilige functie met retry
    result = generate_ai_content_safe(prompt)
    return jsonify({"analysis": result})


if __name__ == "__main__":
    app.run(debug=True)