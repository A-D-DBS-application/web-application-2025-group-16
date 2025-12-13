# nodig voor je Dashboard, Cashbox en Transacties
from flask import Blueprint, render_template, request, redirect, url_for, session, flash, jsonify
import pandas as pd
import io
from fuzzy_search import search_tickers, refresh_ticker_index  

# Imports
from config import supabase, supabase_admin, SUPABASE_URL, SUPABASE_ANON_KEY
from auth import (
    get_group_by_id, list_memberships_for_user, list_groups_by_ids, count_group_members,
    get_membership_for_user, get_membership_for_user_in_group, list_leden,
    add_cash_transaction, list_cash_transactions_for_group, get_cash_balance_for_group,
    add_portfolio_position, koersen_updater, log_portfolio_transaction, initialize_cash_position
)
# Zoek naar je imports bovenaan en zorg dat dit er staat:
from market_data import get_ticker_data, get_currency_rate, sync_exchange_rates_to_db 
import ai_manager  # Jouw nieuwe ai_manager.py

main_bp = Blueprint('main', __name__)

# --- HELPERS ---
def _current_group_snapshot():
    uid = session.get("user_id")
    gid = session.get("group_id")
    if not uid: return None
    
    # Check membership
    mem = None
    if gid:
        ok, mem = get_membership_for_user_in_group(uid, gid)
    
    if not mem:
        ok, mem = get_membership_for_user(uid)
        if mem: session["group_id"] = mem["group_id"]
    
    if not mem: return None

    ok, group = get_group_by_id(mem["group_id"])
    if not group: return None
    
    ok, count = count_group_members(group["id"])
    return {
        "id": group["id"], "name": group["name"], 
        "code": group.get("invite_code"), "member_total": count or 0,
        "role": mem.get("role")
    }

def _list_user_groups():
    uid = session.get("user_id")
    if not uid: return []
    ok, memberships = list_memberships_for_user(uid)
    if not memberships: return []
    ids = [m["group_id"] for m in memberships]
    ok, groups = list_groups_by_ids(ids)
    
    res = []
    g_map = {g["id"]: g for g in (groups or [])}
    cur = session.get("group_id")
    for m in memberships:
        g = g_map.get(m["group_id"])
        if g:
            res.append({
                "id": g["id"], "name": g["name"], "role": m.get("role"),
                "is_current": g["id"] == cur
            })
    return res

# --- PAGES ---

@main_bp.route("/home")
def home():
    if "user_id" not in session: return redirect(url_for("auth.login"))
    return render_template("home.html", group_snapshot=_current_group_snapshot(), user_groups=_list_user_groups())

@main_bp.route("/portfolio")
def portfolio():
    if "user_id" not in session: return redirect(url_for("auth.login"))
    snap = _current_group_snapshot()
    is_host = (snap and snap.get("role") == "host")
    return render_template("dashboard.html", supabase_url=SUPABASE_URL, supabase_key=SUPABASE_ANON_KEY, active_group=snap, user_groups=_list_user_groups(), is_host=is_host)

@main_bp.route("/cash", methods=["GET", "POST"])
def cashbox():
    if "user_id" not in session: return redirect(url_for("auth.login"))
    snap = _current_group_snapshot()
    if not snap: return redirect(url_for("main.home"))
    
    is_host = (snap.get("role") == "host")
    error = None

    if request.method == "POST":
        if not is_host: error = "Alleen hosts."
        else:
            try:
                amt = float(request.form.get("amount", "0").strip())
                direction = request.form.get("direction")
                desc = request.form.get("description")
                add_cash_transaction(snap["id"], amt, direction, desc, session["user_id"])
                return redirect(url_for("main.cashbox"))
            except: error = "Fout in invoer."

    ok, hist = list_cash_transactions_for_group(snap["id"])
    ok, bal = get_cash_balance_for_group(snap["id"])
    return render_template("cashbox.html", balance=bal or 0, history=hist or [], error=error, is_host=is_host)

# Verplaatst naar routes/transacties.py

# Verplaatst naar routes/transacties.py

@main_bp.route("/api/dashboard-snapshot")
def api_dashboard_snapshot():
    """Eenvoudige snapshot endpoint zodat dashboard geen 404 geeft.
    Geeft basisinformatie terug voor de actieve groep uit de sessie.
    """
    if "user_id" not in session:
        return jsonify({"error": "Niet ingelogd"}), 401

    snap = _current_group_snapshot()
    if not snap:
        return jsonify({"error": "Geen actieve groep"}), 404
    try:
        ok, bal = get_cash_balance_for_group(snap["id"])
        return jsonify({
            "group": snap,
            "cash_balance": bal or 0.0,
        })
    except Exception as e:
        return jsonify({"error": str(e)}), 500


@main_bp.route("/api/cash/transfer", methods=["POST"])
def api_cash_transfer():
    if "user_id" not in session:
        return jsonify({"error": "Niet ingelogd"}), 401

    snap = _current_group_snapshot()
    if not snap:
        return jsonify({"error": "Geen actieve groep"}), 404
    if snap.get("role") != "host":
        return jsonify({"error": "Alleen hosts"}), 403

    payload = request.get_json() or {}
    try:
        amount = float(payload.get("amount") or 0)
    except Exception:
        amount = 0.0
    direction = str(payload.get("direction") or "in").lower()
    target = str(payload.get("target") or "portfolio").lower()
    if amount <= 0:
        return jsonify({"error": "Bedrag moet groter dan 0 zijn"}), 400
    if direction not in ("in", "out"):
        return jsonify({"error": "Ongeldige richting"}), 400
    if target not in ("portfolio", "kas"):
        return jsonify({"error": "Ongeldig doel"}), 400

    gid = snap["id"]
    try:
        if target == "kas":
            ok_bal, current_bal = get_cash_balance_for_group(gid)
            if not ok_bal:
                return jsonify({"error": current_bal or "Kas saldo ophalen mislukt"}), 500
            delta = amount if direction == "in" else -amount
            next_kas = float(current_bal or 0) + delta
            if next_kas < -1e-6:
                return jsonify({"error": "Kas kan niet negatief worden"}), 400

            ok_cash, cash_row = add_cash_transaction(
                gid,
                amount,
                direction,
                payload.get("description"),
                session.get("user_id")
            )
            if not ok_cash:
                return jsonify({"error": cash_row or "Kastransactie opslaan mislukt"}), 500

            return jsonify({
                "target": target,
                "kas_balance": next_kas,
                "cash_entry": cash_row
            })

        res = supabase.table("Portefeuille").select("port_id,current_price").eq("groep_id", gid).eq("ticker", "CASH").limit(1).execute()
        cash_row = (res.data or [None])[0]
        if not cash_row:
            ok, created = initialize_cash_position(gid, 0)
            if not ok or not created:
                return jsonify({"error": "Cashpositie kon niet worden aangemaakt"}), 500
            cash_row = created if isinstance(created, dict) else (created[0] if isinstance(created, list) and created else None)
            if not cash_row:
                return jsonify({"error": "Cashpositie kon niet worden aangemaakt"}), 500

        current = float(cash_row.get("current_price") or 0)
        delta = amount if direction == "in" else -amount
        next_balance = current + delta
        if next_balance < -1e-6:
            return jsonify({"error": "Cash kan niet negatief worden"}), 400

        port_id = cash_row.get("port_id") or cash_row.get("id")
        supabase.table("Portefeuille").update({"current_price": next_balance}).eq("port_id", port_id).execute()

        trade_type = "TRANSFER"
        price_value = amount if direction == "in" else -amount
        datum_tr = payload.get("date") or payload.get("datum_tr")
        ok, tx_row = log_portfolio_transaction(port_id, "CASH", trade_type, 1, price_value, 1.0, "EUR", datum_tr)
        if not ok:
            return jsonify({"error": tx_row or "Transactie log mislukt"}), 500

        return jsonify({
            "balance": next_balance,
            "transaction": tx_row,
            "type": trade_type,
            "target": target
        })
    except Exception as exc:
        return jsonify({"error": str(exc)}), 500

@main_bp.route("/api/portfolio/<int:port_id>/add_cost", methods=["POST"])
def api_add_portfolio_cost(port_id: int):
    """Verhoog cumulatieve transactiekost voor een portfolio.
    Body: { amount: number }
    """
    if "user_id" not in session:
        return jsonify({"error": "Niet ingelogd"}), 401

    # Controle: gebruiker moet lid zijn van de groep van deze portfolio
    try:
        port = supabase.table("Portefeuille").select("port_id, groep_id, transactiekost").eq("port_id", port_id).limit(1).execute()
        rows = port.data or []
        if not rows:
            return jsonify({"error": "Portfolio niet gevonden"}), 404
        row = rows[0]
        gid = row.get("groep_id")
        ok, mem = get_membership_for_user_in_group(session.get("user_id"), gid)
        if not (ok and mem):
            return jsonify({"error": "Geen toegang"}), 403

        data = request.get_json() or {}
        amt = float(data.get("amount") or 0)
        if amt <= 0:
            return jsonify({"error": "Amount moet > 0"}), 400

        current = float(row.get("transactiekost") or 0)
        new_val = current + amt
        supabase.table("Portefeuille").update({"transactiekost": new_val}).eq("port_id", port_id).execute()
        return jsonify({"port_id": port_id, "transactiekost": new_val})
    except Exception as e:
        return jsonify({"error": str(e)}), 500

    
@main_bp.route("/leden")
def leden():
    if "user_id" not in session: return redirect(url_for("auth.login"))
    ok, res = list_leden()
    return render_template("leden.html", leden=res if ok else [])

# --- ACTIES (CSV, REFRESH, LOG) ---

@main_bp.route("/group/<int:group_id>/refresh_prices")
def refresh_prices(group_id):
    if "user_id" not in session: return redirect(url_for("auth.login"))
    ok, msg = koersen_updater(group_id)  # Update via server-side helper
    if ok:
        flash(msg or "Koersen ververst.", "success")
    else:
        flash(msg or "Verversen mislukt.", "error")
    return redirect(url_for("main.portfolio"))

# JSON variant voor AJAX: ververst enkel koersen, geeft count/boodschap terug
@main_bp.route("/api/groups/<int:group_id>/refresh_prices", methods=["POST"])
def api_refresh_prices(group_id):
    if "user_id" not in session:
        return jsonify({"error": "Niet ingelogd"}), 401
    ok, msg = koersen_updater(group_id)
    if not ok:
        return jsonify({"error": msg or "Verversen mislukt"}), 500
    # Probeer een getal uit het bericht te halen
    updated = None
    try:
        import re
        m = re.search(r"(\d+)", msg or "")
        if m:
            updated = int(m.group(1))
    except Exception:
        pass
    return jsonify({"ok": True, "message": msg, "updated": updated})

@main_bp.route("/api/transactions/log", methods=["POST"])
def api_log_transaction():
    if "user_id" not in session: return jsonify({"error": "Login"}), 401
    snap = _current_group_snapshot()
    if not snap or snap.get("role") != "host": return jsonify({"error": "Alleen host"}), 403
    
    data = request.get_json() or {}
    # Logica doorsturen naar auth.py helper
    ok, res = log_portfolio_transaction(
        data.get("portefeuille_id"), data.get("ticker"), data.get("type"),
        float(data.get("aantal") or 0), float(data.get("koers") or 0),
        float(data.get("wisselkoers") or 1), data.get("munt"), data.get("datum_tr")
    )
    if not ok: return jsonify({"error": res}), 400
    return jsonify({"transaction": res})

# --- AI ENDPOINTS ---
@main_bp.route("/api/ai/analyze-stock", methods=["POST"])
def analyze_stock():
    tick = request.get_json().get("ticker")
    prompt = f"Analyseer aandeel {tick}. Geef koop/verkoop advies in HTML."
    return jsonify({"analysis": ai_manager.generate_ai_content_safe(prompt)})

@main_bp.route("/api/ai/analyze-portfolio", methods=["POST"])
def analyze_portfolio():
    data = request.get_json()
    prompt = f"Analyseer deze portfolio: {data}. Geef advies in HTML."
    return jsonify({"analysis": ai_manager.generate_ai_content_safe(prompt)})

# --- IMPORT CSV ROUTE (ONTBRAK EERDER) ---
@main_bp.route("/group/<int:group_id>/import_csv", methods=["POST"])
def import_csv(group_id):
    if "user_id" not in session: return redirect(url_for("auth.login"))
    
    # Check of user host is
    snap = _current_group_snapshot()
    if not snap or snap.get("role") != "host":
        flash("Alleen hosts kunnen importeren.", "error")
        return redirect(url_for("main.portfolio"))

    file = request.files.get('file')
    if file and file.filename:
        try:
            # Lees CSV
            stream = io.StringIO(file.stream.read().decode("UTF8"), newline=None)
            try: df = pd.read_csv(stream, sep=None, engine='python')
            except: 
                stream.seek(0)
                df = pd.read_csv(stream, sep=';')
            
            # Kolommen normaliseren
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
                            # Voeg positie toe
                            add_portfolio_position(group_id, t, a, p, session["user_id"])
                            cnt += 1
                    except: pass
                flash(f"Succes! {cnt} posities geïmporteerd.", "success")
            else:
                flash("Kolommen niet gevonden. Zorg voor: Ticker, Aantal, Prijs.", "error")
        except Exception as e:
            flash(f"Fout bij import: {e}", "error")
            
    return redirect(url_for("main.portfolio"))

# --- API ROUTES (VOOR YAHOO FINANCE & WISSELKOERSEN) ---

@main_bp.route('/api/quote/<ticker>')
def api_get_quote(ticker):
    """Haalt koersdata op via market_data.py"""
    if "user_id" not in session: return jsonify({"error": "Niet ingelogd"}), 401
    
    data = get_ticker_data(ticker)
    if data:
        return jsonify(data)
    return jsonify({'error': 'Ticker niet gevonden of API fout'}), 404

@main_bp.route('/api/currency/<ticker>')
def api_get_currency(ticker):
    """Zoekt in eerdere transacties welke munt bij deze ticker hoort."""
    if "user_id" not in session: return jsonify({"error": "Niet ingelogd"}), 401
    
    try:
        # Zoek in database naar laatste transactie van deze ticker
        res = supabase.table('Transacties').select('munt').eq('ticker', ticker.upper()).limit(1).execute()
        rows = res.data or []
        if rows:
            return jsonify({'currency': rows[0].get('munt')})
        return jsonify({'currency': None})
    except Exception:
        return jsonify({'currency': None})

@main_bp.route('/api/wk/<cur>')
def api_get_wk(cur):
    """Haalt opgeslagen wisselkoers uit de database."""
    try:
        code = (cur or '').strip().upper()
        if code == 'EUR': return jsonify({'rate': 1.0})
        
        res = supabase.table('Wisselkoersen').select('wk').eq('munt', code).limit(1).execute()
        if res.data:
            return jsonify({'rate': res.data[0].get('wk')})
        return jsonify({'error': 'Niet gevonden'}), 404
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@main_bp.route('/api/refresh-wk', methods=['POST'])
def api_refresh_wk():
    """Update de wisselkoersen in de database (aangeroepen door de knop 'Ververs WK')."""
    if "user_id" not in session: return jsonify({"error": "Niet ingelogd"}), 401
    
    try:
        data = request.get_json() or {}
        currencies = data.get('currencies', [])
        
        # Gebruik de functie uit market_data.py
        count = sync_exchange_rates_to_db(supabase, currencies)
        
        return jsonify({'updated': count, 'message': 'Koersen bijgewerkt'})
    except Exception as e:
        return jsonify({'error': str(e)}), 500
    
@main_bp.route('/api/search-tickers')
def api_search_tickers():
    """Eigen fuzzy search met Yahoo fallback."""
    if "user_id" not in session:
        return jsonify({"error": "Niet ingelogd"}), 401
    
    query = request.args.get('q', '').strip()
    if not query or len(query) < 1:
        return jsonify([])
    
    # Eigen algoritme + Yahoo fallback
    results = search_tickers(query, supabase_client=supabase, limit=10, use_fallback=True)
    return jsonify(results)

@main_bp.route('/api/refresh-ticker-index', methods=['POST'])
def api_refresh_ticker_index():
    """Optioneel: refresh ticker index."""
    if "user_id" not in session:
        return jsonify({"error": "Niet ingelogd"}), 401
    
    try:
        count = refresh_ticker_index(supabase)
        return jsonify({'count': count, 'message': f'Index ververst met {count} tickers'})
    except Exception as e:
        return jsonify({'error': str(e)}), 500