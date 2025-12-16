# nodig voor Dashboard, Cashbox en Transacties
from __future__ import annotations

import io

import pandas as pd
from flask import Blueprint, flash, g, jsonify, redirect, render_template, request, url_for

from config import SUPABASE_ANON_KEY, SUPABASE_URL, supabase
from auth import (
    add_cash_transaction,
    add_portfolio_position,
    get_cash_balance_for_group,
    get_membership_for_user_in_group,
    initialize_cash_position,
    koersen_updater,
    list_cash_transactions_for_group,
    list_leden,
    log_portfolio_transaction,
    list_pending_leave_requests_for_user,
)
from fuzzy_search import refresh_ticker_index, search_tickers
from market_data import get_ticker_data, sync_exchange_rates_to_db
from models import Portefeuille, SessionLocal, Transacties, Wisselkoersen
from view_helpers import login_required, with_group_context
import ai_manager

main_bp = Blueprint("main", __name__)


@main_bp.route("/home")
@login_required()
@with_group_context()
def home():
    user_groups = list(g.user_groups or [])
    pending_leave_groups = []

    user_id = getattr(g, "user_id", None)
    if user_id:
        ok_pending, pending = list_pending_leave_requests_for_user(user_id)
        if ok_pending and pending:
            pending_leave_groups = []
            pending_ids = set()
            for item in pending:
                gid = item.get("group_id")
                if gid is None:
                    continue
                try:
                    gid_int = int(gid)
                except (TypeError, ValueError):
                    gid_int = gid
                item["group_id"] = gid_int
                pending_ids.add(gid_int)
                pending_leave_groups.append(item)

            if pending_ids:
                pending_ids_str = {str(pid) for pid in pending_ids}
                user_groups = [
                    grp
                    for grp in user_groups
                    if grp.get("id") not in pending_ids and str(grp.get("id")) not in pending_ids_str
                ]

    return render_template(
        "home.html",
        group_snapshot=g.group_snapshot,
        user_groups=user_groups,
        pending_leave_groups=pending_leave_groups,
    )


@main_bp.route("/portfolio")
@login_required()
@with_group_context()
def portfolio():
    return render_template(
        "dashboard.html",
        supabase_url=SUPABASE_URL,
        supabase_key=SUPABASE_ANON_KEY,
        active_group=g.group_snapshot,
        user_groups=g.user_groups,
        is_host=g.is_host,
    )


@main_bp.route("/cash", methods=["GET", "POST"])
@login_required()
@with_group_context(require_active=True)
def cashbox():
    snap = g.group_snapshot
    is_host = g.is_host
    error = None

    if request.method == "POST":
        if not is_host:
            error = "Alleen hosts."
        else:
            try:
                amt = float(request.form.get("amount", "0").strip())
                direction = request.form.get("direction")
                desc = request.form.get("description")
                add_cash_transaction(snap["id"], amt, direction, desc, g.user_id)
                return redirect(url_for("main.cashbox"))
            except Exception:
                error = "Fout in invoer."

    ok, hist = list_cash_transactions_for_group(snap["id"])
    ok, bal = get_cash_balance_for_group(snap["id"])
    return render_template("cashbox.html", balance=bal or 0, history=hist or [], error=error, is_host=is_host)


@main_bp.route("/api/dashboard-snapshot")
@login_required(response="json")
@with_group_context(response="json", require_active=True)
def api_dashboard_snapshot():
    gid = g.group_snapshot["id"]
    session = None
    try:
        session = SessionLocal()
        cash_row = (
            session.query(Portefeuille)
            .filter(Portefeuille.groep_id == gid, Portefeuille.ticker == "CASH")
            .first()
        )
        portfolio_cash = float(cash_row.quantity or 0.0) if cash_row else 0.0

        ok_kas, kas_balance = get_cash_balance_for_group(gid)
        kas_value = kas_balance if ok_kas else None

        return jsonify({
            "group": g.group_snapshot,
            "cash_balance": portfolio_cash,
            "kas_balance": kas_value,
        })
    except Exception as exc:  # pragma: no cover
        return jsonify({"error": str(exc)}), 500
    finally:
        if session is not None:
            session.close()


@main_bp.route("/api/cash/transfer", methods=["POST"])
@login_required(response="json")
@with_group_context(response="json", require_active=True, require_host=True)
def api_cash_transfer():
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

    gid = g.group_snapshot["id"]

    if target == "kas":
        ok_bal, current_bal = get_cash_balance_for_group(gid)
        if not ok_bal:
            return jsonify({"error": current_bal or "Kas saldo ophalen mislukt"}), 500
        delta = amount if direction == "in" else -amount
        next_kas = float(current_bal or 0) + delta
        if next_kas < -1e-6:
            return jsonify({"error": "Kas kan niet negatief worden"}), 400

        ok_cash, cash_row = add_cash_transaction(gid, amount, direction, payload.get("description"), g.user_id)
        if not ok_cash:
            return jsonify({"error": cash_row or "Kastransactie opslaan mislukt"}), 500

        return jsonify({"target": target, "kas_balance": next_kas, "cash_entry": cash_row})

    session = None
    try:
        session = SessionLocal()
        cash_row = (
            session.query(Portefeuille)
            .filter(Portefeuille.groep_id == gid, Portefeuille.ticker == "CASH")
            .first()
        )
        if not cash_row:
            session.close()
            session = None
            ok_init, _ = initialize_cash_position(gid, 0)
            if not ok_init:
                return jsonify({"error": "Cashpositie kon niet worden aangemaakt"}), 500
            session = SessionLocal()
            cash_row = (
                session.query(Portefeuille)
                .filter(Portefeuille.groep_id == gid, Portefeuille.ticker == "CASH")
                .first()
            )
            if not cash_row:
                return jsonify({"error": "Cashpositie kon niet worden aangemaakt"}), 500

        current = float(cash_row.quantity or 0.0)
        delta = amount if direction == "in" else -amount
        next_balance = current + delta
        if next_balance < -1e-6:
            return jsonify({"error": "Cash kan niet negatief worden"}), 400

        cash_row.quantity = next_balance
        session.commit()
        port_id = cash_row.port_id
    except Exception as exc:
        if session is not None:
            session.rollback()
        return jsonify({"error": str(exc)}), 500
    finally:
        if session is not None:
            session.close()

    trade_type = "TRANSFER"
    price_value = amount if direction == "in" else -amount
    datum_tr = payload.get("date") or payload.get("datum_tr")
    ok_tx, tx_row = log_portfolio_transaction(port_id, "CASH", trade_type, 1, price_value, 1.0, "EUR", datum_tr)
    if not ok_tx:
        return jsonify({"error": tx_row or "Transactie log mislukt"}), 500

    return jsonify({"balance": next_balance, "transaction": tx_row, "type": trade_type, "target": target})


@main_bp.route("/api/cash/set_balance", methods=["POST"])
@login_required(response="json")
@with_group_context(response="json", require_active=True, require_host=True)
def api_set_cash_balance():
    try:
        payload = request.get_json() or {}
        try:
            amount = float(payload.get("amount") or payload.get("balance") or 0.0)
        except Exception:
            return jsonify({"error": "Ongeldig bedrag"}), 400

        gid = g.group_snapshot["id"]
        session = SessionLocal()
        try:
            cash_row = (
                session.query(Portefeuille)
                .filter(Portefeuille.groep_id == gid, Portefeuille.ticker == "CASH")
                .first()
            )
            if not cash_row:
                session.close()
                session = None
                ok_init, _ = initialize_cash_position(gid, amount)
                if not ok_init:
                    return jsonify({"error": "Cashpositie kon niet worden aangemaakt"}), 500
                session = SessionLocal()
                cash_row = (
                    session.query(Portefeuille)
                    .filter(Portefeuille.groep_id == gid, Portefeuille.ticker == "CASH")
                    .first()
                )
            if not cash_row:
                return jsonify({"error": "Cashpositie niet gevonden"}), 404

            cash_row.quantity = amount
            session.commit()
            balance = float(cash_row.quantity or 0.0)
            return jsonify({"balance": balance, "port_id": cash_row.port_id})
        except Exception:
            if session is not None:
                session.rollback()
            raise
        finally:
            if session is not None:
                session.close()
    except Exception as exc:
        return jsonify({"error": str(exc)}), 500


@main_bp.route("/api/portfolio/<int:port_id>/add_cost", methods=["POST"])
@login_required(response="json")
def api_add_portfolio_cost(port_id: int):
    try:
        session = SessionLocal()
        port = session.query(Portefeuille).filter(Portefeuille.port_id == port_id).first()
        if not port:
            session.close()
            return jsonify({"error": "Portfolio niet gevonden"}), 404

        gid = port.groep_id
        ok, mem = get_membership_for_user_in_group(g.user_id, gid)
        if not (ok and mem):
            session.close()
            return jsonify({"error": "Geen toegang"}), 403

        data = request.get_json() or {}
        amt = float(data.get("amount") or 0)
        if amt <= 0:
            session.close()
            return jsonify({"error": "Amount moet > 0"}), 400

        current = float(port.transactiekost or 0)
        new_val = current + amt
        port.transactiekost = new_val
        session.commit()
        session.close()
        return jsonify({"port_id": port_id, "transactiekost": new_val})
    except Exception as exc:
        return jsonify({"error": str(exc)}), 500


@main_bp.route("/leden")
@login_required()
@with_group_context()
def leden():
    ok, res = list_leden()
    return render_template("leden.html", leden=res if ok else [], is_host=g.is_host)


@main_bp.route("/group/<int:group_id>/refresh_prices")
@login_required()
def refresh_prices(group_id):
    ok, msg = koersen_updater(group_id)
    if ok:
        flash(msg or "Koersen ververst.", "success")
    else:
        flash(msg or "Verversen mislukt.", "error")
    return redirect(url_for("main.portfolio"))


@main_bp.route("/api/groups/<int:group_id>/refresh_prices", methods=["POST"])
@login_required(response="json")
def api_refresh_prices(group_id):
    ok, msg = koersen_updater(group_id)
    if not ok:
        return jsonify({"error": msg or "Verversen mislukt"}), 500
    updated = None
    try:
        import re

        match = re.search(r"(\d+)", msg or "")
        if match:
            updated = int(match.group(1))
    except Exception:
        updated = None
    return jsonify({"ok": True, "message": msg, "updated": updated})


@main_bp.route("/api/transactions/log", methods=["POST"])
@login_required(response="json")
@with_group_context(response="json", require_active=True, require_host=True)
def api_log_transaction():
    data = request.get_json() or {}
    ok, res = log_portfolio_transaction(
        data.get("portefeuille_id"),
        data.get("ticker"),
        data.get("type"),
        float(data.get("aantal") or 0),
        float(data.get("koers") or 0),
        float(data.get("wisselkoers") or 1),
        data.get("munt"),
        data.get("datum_tr"),
    )
    if not ok:
        return jsonify({"error": res}), 400
    return jsonify({"transaction": res})


@main_bp.route("/api/groups/<int:group_id>/portfolio/positions", methods=["POST"])
@login_required(response="json")
@with_group_context(response="json", require_active=True, require_host=True)
def api_create_portfolio_position(group_id: int):
    payload = request.get_json() or {}
    ticker = (payload.get("ticker") or "").strip().upper()
    quantity = payload.get("quantity")
    price = payload.get("avg_price") or payload.get("price")
    name = payload.get("name")
    sector = payload.get("sector")
    transaction_cost = payload.get("transactiekost")

    if not ticker:
        return jsonify({"error": "Ticker verplicht"}), 400

    ok, result = add_portfolio_position(
        group_id,
        ticker,
        quantity,
        price,
        g.user_id,
        asset_name=name,
        asset_sector=sector,
        transaction_cost=transaction_cost,
    )
    if not ok:
        return jsonify({"error": result}), 400

    return jsonify({"position": result})


@main_bp.route("/api/ai/analyze-stock", methods=["POST"])
@login_required(response="json")
def analyze_stock():
    tick = (request.get_json() or {}).get("ticker")
    prompt = (
        f"Maak een diepe analyse van aandeel {tick}. Geef nadien bull en bear argumenten. "
        "Output mag geen tabellen bevatten, maar wel een mooie opmaak titels en tussentitels mogen in het vet. "
        "Geef jouw antwoord in HTML."
    )
    return jsonify({"analysis": ai_manager.generate_ai_content_safe(prompt)})


@main_bp.route("/api/ai/analyze-portfolio", methods=["POST"])
@login_required(response="json")
def analyze_portfolio():
    data = request.get_json()
    prompt = (
        f"Maak een diepe analyse van deze portefeuille: {data}. Output mag geen tabellen bevatten, maar wel een mooie "
        "opmaak titels en tussentitels mogen in het vet. Geef jouw antwoord in HTML."
    )
    return jsonify({"analysis": ai_manager.generate_ai_content_safe(prompt)})


@main_bp.route("/group/<int:group_id>/import_csv", methods=["POST"])
@login_required()
@with_group_context(require_active=True, require_host=True)
def import_csv(group_id):
    if g.group_snapshot and g.group_snapshot["id"] != group_id:
        flash("Onbekende groep geselecteerd.", "error")
        return redirect(url_for("main.portfolio"))

    file = request.files.get("file")
    if file and file.filename:
        try:
            stream = io.StringIO(file.stream.read().decode("UTF8"), newline=None)
            try:
                df = pd.read_csv(stream, sep=None, engine="python")
            except Exception:
                stream.seek(0)
                df = pd.read_csv(stream, sep=";")

            df.columns = [str(c).lower().strip() for c in df.columns]
            col_map = {
                "ticker": ["ticker", "symbol", "symbool", "product", "isin"],
                "amount": ["aantal", "quantity", "stuks", "number"],
                "price": ["price", "prijs", "koers", "aankoopprijs", "avg price", "cost"],
            }
            found: dict[str, str] = {}
            for key, options in col_map.items():
                for opt in options:
                    if opt in df.columns:
                        found[key] = opt
                        break

            if len(found) == 3:
                cnt = 0
                for _, row in df.iterrows():
                    try:
                        ticker = str(row[found["ticker"]]).upper().strip()

                        def clean(value):
                            if isinstance(value, (int, float)):
                                return float(value)
                            text = str(value).replace("€", "").replace("$", "").strip()
                            if "," in text and "." in text:
                                if text.find(",") < text.find("."):
                                    text = text.replace(",", "")
                                else:
                                    text = text.replace(".", "").replace(",", ".")
                            elif "," in text:
                                text = text.replace(",", ".")
                            return float(text)

                        amount = clean(row[found["amount"]])
                        price = clean(row[found["price"]])

                        if ticker and amount > 0:
                            add_portfolio_position(group_id, ticker, amount, price, g.user_id)
                            cnt += 1
                    except Exception:
                        continue
                flash(f"Succes! {cnt} posities geïmporteerd.", "success")
            else:
                flash("Kolommen niet gevonden. Zorg voor: Ticker, Aantal, Prijs.", "error")
        except Exception as exc:
            flash(f"Fout bij import: {exc}", "error")

    return redirect(url_for("main.portfolio"))


@main_bp.route("/api/quote/<ticker>")
@login_required(response="json")
def api_get_quote(ticker):
    data = get_ticker_data(ticker)
    if data:
        return jsonify(data)
    return jsonify({"error": "Ticker niet gevonden of API fout"}), 404


@main_bp.route("/api/currency/<ticker>")
@login_required(response="json")
def api_get_currency(ticker):
    try:
        session = SessionLocal()
        try:
            tx = (
                session.query(Transacties.munt)
                .filter(Transacties.ticker == ticker.strip().upper())
                .order_by(Transacties.datum_tr.desc(), Transacties.transactie_id.desc())
                .first()
            )
        finally:
            session.close()
        if tx and tx[0]:
            return jsonify({"currency": tx[0]})
        return jsonify({"currency": None})
    except Exception:
        return jsonify({"currency": None})


@main_bp.route("/api/wk/<cur>")
def api_get_wk(cur):
    try:
        code = (cur or "").strip().upper()
        if code == "EUR":
            return jsonify({"rate": 1.0})

        session = SessionLocal()
        try:
            row = (
                session.query(Wisselkoersen)
                .filter(Wisselkoersen.munt == code)
                .first()
            )
            if row:
                return jsonify({"rate": row.wk})
            return jsonify({"error": "Niet gevonden"}), 404
        finally:
            session.close()
    except Exception as exc:
        return jsonify({"error": str(exc)}), 500


@main_bp.route("/api/refresh-wk", methods=["POST"])
@login_required(response="json")
def api_refresh_wk():
    try:
        data = request.get_json() or {}
        currencies = data.get("currencies", [])
        count = sync_exchange_rates_to_db(currencies=currencies)
        return jsonify({"updated": count, "message": "Koersen bijgewerkt"})
    except Exception as exc:
        return jsonify({"error": str(exc)}), 500


@main_bp.route("/api/search-tickers")
@login_required(response="json")
def api_search_tickers():
    query = request.args.get("q", "").strip()
    if not query:
        return jsonify([])
    results = search_tickers(query, supabase_client=supabase, limit=10, use_fallback=True)
    return jsonify(results)


@main_bp.route("/api/refresh-ticker-index", methods=["POST"])
@login_required(response="json")
def api_refresh_ticker_index():
    try:
        count = refresh_ticker_index(supabase)
        return jsonify({"count": count, "message": f"Index ververst met {count} tickers"})
    except Exception as exc:
        return jsonify({"error": str(exc)}), 500
