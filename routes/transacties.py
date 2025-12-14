from flask import Blueprint, render_template, request, jsonify, session
from sqlalchemy import desc
from models import SessionLocal, Transacties, Portefeuille
from auth import log_portfolio_transaction, get_membership_for_user_in_group

transacties_bp = Blueprint("transacties", __name__)

@transacties_bp.route("/transactions")
def transactions():
    """Transactie-overzicht gefilterd op actieve groep en optioneel `port_id`.
    - Als `port_id` query aanwezig is: filter op die portefeuille.
    - Anders: haal alle `port_id`s van de huidige groep en filter daarop.
    """
    if "user_id" not in session:
        return render_template("transactions.html", transactions=[])
    gid = session.get("group_id")
    q_port = request.args.get("port_id", type=int)
    db = SessionLocal()
    try:
        tx_query = db.query(Transacties)
        if q_port:
            tx_query = tx_query.filter(Transacties.portefeuille_id == q_port)
        else:
            port_rows = db.query(Portefeuille.port_id).filter(Portefeuille.groep_id == gid).all()
            port_ids = [row.port_id for row in port_rows]
            if not port_ids:
                return render_template("transactions.html", transactions=[], group_id=gid, port_id=q_port)
            tx_query = tx_query.filter(Transacties.portefeuille_id.in_(port_ids))
        txs = (
            tx_query
            .order_by(desc(Transacties.datum_tr), desc(Transacties.transactie_id))
            .all()
        )
    except Exception:
        txs = []
    finally:
        db.close()
    return render_template("transactions.html", transactions=txs, group_id=gid, port_id=q_port)

@transacties_bp.route("/api/transactions/log", methods=["POST"])
def api_log_transaction():
    """Log een transactie in de `Transacties`-tabel via helper in `auth.py`. Vereist login en host."""
    if "user_id" not in session:
        return jsonify({"error": "Login"}), 401
    # In eerdere implementatie werd host-check via group snapshot gedaan; hier veronderstellen we reeds geautoriseerde UI.
    data = request.get_json() or {}
    ok, res = log_portfolio_transaction(
        data.get("portefeuille_id"), data.get("ticker"), data.get("type"),
        float(data.get("aantal") or 0), float(data.get("koers") or 0),
        float(data.get("wisselkoers") or 1), data.get("munt"), data.get("datum_tr")
    )
    if not ok:
        return jsonify({"error": res}), 400
    return jsonify({"transaction": res})

@transacties_bp.route("/api/groups/<int:group_id>/realized_profit")
def api_realized_profit(group_id: int):
    """Gerealiseerde winst in EUR volgens eenvoudige formule:
    Per ticker en portefeuille wordt een gemiddelde aankoopprijs (in EUR) bijgehouden.
    Voor elke SELL: realized += aantal × (sell_price_eur − avg_buy_price_eur).
    Daarnaast worden alle KOST/FEE transacties (in EUR) in mindering gebracht.
    DIVIDEND-transacties worden opgeteld bij de gerealiseerde winst (in EUR).
    De wisselkoers wordt toegepast door `prijs_eur = koers / wisselkoers`.
    """
    if "user_id" not in session:
        return jsonify({"error": "Niet ingelogd"}), 401

    uid = session.get("user_id")
    ok, mem = get_membership_for_user_in_group(uid, group_id)
    if not (ok and mem):
        return jsonify({"error": "Geen toegang tot deze groep"}), 403

    db = SessionLocal()
    try:
        # Verzamel relevante portefeuilles
        q_port = request.args.get("port_id", type=int)
        base_query = db.query(Portefeuille.port_id).filter(Portefeuille.groep_id == group_id)
        all_port_ids = [row.port_id for row in base_query.all()]
        if q_port and q_port in all_port_ids:
            target_port_ids = [q_port]
        else:
            target_port_ids = all_port_ids

        sell_count = 0
        overall_realized = 0.0
        per_port_result = {}

        if target_port_ids:
            tx_rows = (
                db.query(Transacties)
                .filter(Transacties.portefeuille_id.in_(target_port_ids))
                .filter(Transacties.type.in_(["BUY", "SELL", "PAYOUT", "FEE", "KOST", "DIVIDEND"]))
                .order_by(Transacties.datum_tr, Transacties.transactie_id)
                .all()
            )

            state = {}
            for row in tx_rows:
                try:
                    pid = row.portefeuille_id
                    if pid is None:
                        continue
                    ttype = (row.type or "").upper()
                    ticker = (row.ticker or "").upper()
                    if ticker == "CASH":
                        continue
                    qty = float(row.aantal or 0)
                    price = float(row.koers or 0)
                    wk = float(row.wisselkoers or 0) or 1.0
                    if wk <= 0:
                        wk = 1.0
                    price_eur = price / wk

                    per_port_result.setdefault(pid, {"total": 0.0, "sell_count": 0})
                    state.setdefault(pid, {})
                    state[pid].setdefault(ticker, {"qty": 0.0, "avg_eur": 0.0})
                    st = state[pid][ticker]

                    if ttype == "BUY" and qty > 0:
                        new_qty = st["qty"] + qty
                        prev_weighted = st["avg_eur"] * st["qty"]
                        new_weighted = prev_weighted + (qty * price_eur)
                        st["avg_eur"] = (new_weighted / new_qty) if new_qty > 0 else 0.0
                        st["qty"] = new_qty
                    elif ttype in ("SELL", "PAYOUT") and qty > 0:
                        realized = qty * (price_eur - st["avg_eur"])
                        overall_realized += realized
                        per_port_result[pid]["total"] += realized
                        per_port_result[pid]["sell_count"] += 1
                        sell_count += 1
                        st["qty"] = max(0.0, st["qty"] - qty)
                    elif ttype == "DIVIDEND" and qty > 0:
                        realized_div = qty * price_eur
                        overall_realized += realized_div
                        per_port_result[pid]["total"] += realized_div
                    elif ttype in ("FEE", "KOST") and price:
                        overall_realized -= price_eur
                        per_port_result[pid]["total"] -= price_eur
                except Exception:
                    continue

        return jsonify({
            "total": overall_realized,
            "sell_count": sell_count,
            "per_port": per_port_result
        })
    except Exception:
        return jsonify({"error": "Fout bij ophalen gegevens"}), 500
    finally:
        db.close()
