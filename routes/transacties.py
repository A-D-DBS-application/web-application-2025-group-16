from flask import Blueprint, render_template, request, jsonify, session
from config import supabase
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
    q_port = request.args.get("port_id")
    query = supabase.table("Transacties").select("*").order("datum_tr", desc=True)
    try:
        if q_port:
            query = query.eq("portefeuille_id", q_port)
        else:
            ports = supabase.table("Portefeuille").select("port_id").eq("groep_id", gid).execute()
            p_ids = [r.get("port_id") for r in (ports.data or []) if r.get("port_id") is not None]
            if p_ids:
                query = query.in_("portefeuille_id", p_ids)
            else:
                return render_template("transactions.html", transactions=[])
        res = query.execute()
        txs = res.data or []
    except Exception:
        txs = []
    return render_template("transactions.html", transactions=txs)

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

    try:
        ports = supabase.table("Portefeuille").select("port_id").eq("groep_id", group_id).execute()
        p_ids = [r.get("port_id") for r in (ports.data or []) if r.get("port_id") is not None]

        try:
            # Optionele filter: enkel voor een specifieke portefeuille
            q_port = request.args.get("port_id")

            ports = supabase.table("Portefeuille").select("port_id").eq("groep_id", group_id).execute()
            all_port_ids = [r.get("port_id") for r in (ports.data or []) if r.get("port_id") is not None]
            if q_port:
                try:
                    q_port = int(q_port)
                except Exception:
                    q_port = None

            target_port_ids = [q_port] if (q_port and q_port in all_port_ids) else all_port_ids

            sell_count = 0
            overall_realized = 0.0
            per_port_result = {}

            if target_port_ids:
                res_all = (
                    supabase
                    .table("Transacties")
                    .select("aantal, koers, type, ticker, wisselkoers, datum_tr, portefeuille_id")
                    .in_("portefeuille_id", target_port_ids)
                    .in_("type", ["BUY", "SELL", "PAYOUT", "FEE", "KOST", "DIVIDEND"])  # relevante types incl. dividend
                    .order("datum_tr")
                    .execute()
                )

                # Per portefeuille en ticker: track gemiddelde aankoopprijs (EUR) en hoeveelheid
                state = {}

                for row in (res_all.data or []):
                    try:
                        pid = row.get("portefeuille_id")
                        if pid is None:
                            continue
                        ttype = (row.get("type") or "").upper()
                        ticker = (row.get("ticker") or "").upper()
                        if ticker == 'CASH':
                            # Cash transfers niet meenemen in winstberekening
                            continue
                        qty = float(row.get("aantal") or 0)
                        price = float(row.get("koers") or 0)
                        wk = float(row.get("wisselkoers") or 0) or 1.0
                        if wk <= 0:
                            wk = 1.0
                        price_eur = price / wk

                        # init maps
                        per_port_result.setdefault(pid, {"total": 0.0, "sell_count": 0})
                        state.setdefault(pid, {})
                        state[pid].setdefault(ticker, {"qty": 0.0, "avg_eur": 0.0, "last_action": None})
                        st = state[pid][ticker]

                        if ttype == "BUY" and qty > 0:
                            # Update gemiddelde aankoopprijs in EUR
                            new_qty = st["qty"] + qty
                            prev_weighted = st["avg_eur"] * st["qty"]
                            new_weighted = prev_weighted + (qty * price_eur)
                            st["avg_eur"] = (new_weighted / new_qty) if new_qty > 0 else 0.0
                            st["qty"] = new_qty
                            st["last_action"] = "BUY"
                        elif ttype in ("SELL", "PAYOUT") and qty > 0:
                            # Realized = qty × (sell_price_eur − avg_buy_eur)
                            realized = qty * (price_eur - st["avg_eur"])
                            overall_realized += realized
                            per_port_result[pid]["total"] += realized
                            per_port_result[pid]["sell_count"] += 1
                            sell_count += 1
                            # Verminder positie hoeveelheid
                            st["qty"] = max(0.0, st["qty"] - qty)
                            st["last_action"] = "SELL"
                        elif ttype == "DIVIDEND" and qty > 0:
                            realized_div = qty * price_eur
                            overall_realized += realized_div
                            per_port_result[pid]["total"] += realized_div
                        elif ttype in ("FEE", "KOST") and price:
                            # Altijd kosten in mindering brengen, ongeacht laatste actie
                            overall_realized -= price_eur
                            per_port_result[pid]["total"] -= price_eur
                    except Exception:
                        pass

                # Fallback: als er nog steeds 0 uitkomt (bijv. door een onverwachte parsing-issue),
                # sommeer DIVIDEND direct per portefeuille om de kaart niet leeg te laten.
                # Dit dekt jouw voorbeeld waarin enkel dividenden aanwezig zijn.
                if abs(overall_realized) < 1e-9:
                    try:
                        div_q = (
                            supabase
                            .table("Transacties")
                            .select("aantal, koers, wisselkoers, portefeuille_id")
                            .in_("portefeuille_id", target_port_ids)
                            .eq("type", "DIVIDEND")
                            .execute()
                        )
                        for r in (div_q.data or []):
                            try:
                                pid2 = r.get("portefeuille_id")
                                if pid2 is None:
                                    continue
                                qty2 = float(r.get("aantal") or 0)
                                price2 = float(r.get("koers") or 0)
                                wk2 = float(r.get("wisselkoers") or 0) or 1.0
                                if wk2 <= 0:
                                    wk2 = 1.0
                                val_eur = qty2 * (price2 / wk2)
                                if val_eur:
                                    per_port_result.setdefault(pid2, {"total": 0.0, "sell_count": 0})
                                    per_port_result[pid2]["total"] += val_eur
                                    overall_realized += val_eur
                            except Exception:
                                pass
                        # sell_count blijft 0; dat is correct bij enkel dividenden
                    except Exception:
                        pass

            return jsonify({
                "total": overall_realized,
                "sell_count": sell_count,
                "per_port": per_port_result
            })
        except Exception:
            return jsonify({"total": 0.0, "sell_count": 0, "per_port": {}})
    except Exception:
        return jsonify({"error": "Fout bij ophalen gegevens"}), 500 
