from datetime import date

from flask import Blueprint, render_template, request, jsonify, session
from sqlalchemy import desc, asc
from models import SessionLocal, Transacties, Portefeuille, Wisselkoersen, Activa, GroepLeden
from market_data import get_latest_price, get_currency_rate
from auth import log_portfolio_transaction, get_membership_for_user_in_group

transacties_bp = Blueprint("transacties", __name__)


def _is_host():
    """Helper to determine if current user is host of their active group."""
    uid = session.get("user_id")
    gid = session.get("group_id")
    if not uid or not gid:
        return False
    ok, mem = get_membership_for_user_in_group(uid, gid)
    if not ok or not mem:
        return False
    return mem.get("role") == "host"


@transacties_bp.route("/transactions")
def transactions():
    """Transactie-overzicht gefilterd op actieve groep en optioneel `port_id`."""
    if "user_id" not in session:
        return render_template("transactions.html", transactions=[], is_host=False)
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
                return render_template("transactions.html", transactions=[], group_id=gid, port_id=q_port, is_host=_is_host())
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
    return render_template("transactions.html", transactions=txs, group_id=gid, port_id=q_port, is_host=_is_host())


@transacties_bp.route("/api/transactions/log", methods=["POST"])
def api_log_transaction():
    """Log een transactie in de `Transacties`-tabel. Vereist login en host."""
    if "user_id" not in session:
        return jsonify({"error": "Login"}), 401
    if not _is_host():
        return jsonify({"error": "Alleen hosts"}), 403
    data = request.get_json() or {}
    ok, res = log_portfolio_transaction(
        data.get("portefeuille_id"), data.get("ticker"), data.get("type"),
        float(data.get("aantal") or 0), float(data.get("koers") or 0),
        float(data.get("wisselkoers") or 1), data.get("munt"), data.get("datum_tr")
    )
    if not ok:
        return jsonify({"error": res}), 400
    return jsonify({"transaction": res})


# =============================================================================
# HULPFUNCTIES
# =============================================================================

def _safe_float(value, default=0.0):
    """Veilig converteren naar float."""
    try:
        if value is None:
            return default
        result = float(value)
        return result
    except (TypeError, ValueError):
        return default


def _safe_wk(wk_value):
    """Wisselkoers valideren en normaliseren."""
    wk = _safe_float(wk_value, 1.0)
    return wk if wk > 0 else 1.0


def _lookup_rate(db, cache: dict, currency: str | None) -> float:
    code = (currency or 'EUR').upper()
    if code == 'EUR':
        return 1.0
    if code in cache:
        return cache[code]
    rate = None
    try:
        row = db.query(Wisselkoersen).filter(Wisselkoersen.munt == code).first()
        if row:
            rate = _safe_wk(row.wk)
    except Exception:
        db.rollback()
    if rate is None:
        fallback = get_currency_rate(code)
        rate = _safe_wk(fallback) if fallback else 1.0
    cache[code] = rate
    return rate


def _get_current_wk_from_table(db, as_of: date | None = None) -> dict:
    """Haal de actuele wisselkoersen uit de Wisselkoersen-tabel (zonder datum)."""
    wk_map = {'EUR': 1.0}
    try:
        rows = db.query(Wisselkoersen).all()
        for row in rows:
            code = (row.munt or '').upper()
            if code:
                wk_map[code] = _safe_wk(row.wk)
    except Exception:
        db.rollback()
    return wk_map


def _get_position_currency_from_buy(db, port_ids: list) -> dict:
    """
    Haal de munt op uit de EERSTE BUY transactie per positie.
    Dit is de oorspronkelijke valuta waarin het aandeel werd gekocht.
    
    Returns:
        dict: {port_id: 'USD', ...}
    """
    currency_map = {}
    if not port_ids:
        return currency_map
    
    try:
        # Haal alleen BUY transacties op, gesorteerd op datum (oudste eerst)
        tx_rows = (
            db.query(Transacties)
            .filter(Transacties.portefeuille_id.in_(port_ids))
            .filter(Transacties.ticker != 'CASH')
            .filter(Transacties.type == 'BUY')
            .order_by(asc(Transacties.datum_tr), asc(Transacties.transactie_id))
            .all()
        )
        
        for row in tx_rows:
            pid = row.portefeuille_id
            # Neem alleen de eerste BUY per positie
            if pid not in currency_map:
                munt = (row.munt or 'EUR').upper()
                # Valideer dat het een echte munt is (niet leeg of ongeldig)
                if munt and len(munt) == 3:
                    currency_map[pid] = munt
                else:
                    currency_map[pid] = 'EUR'
    except Exception:
        pass
    
    return currency_map


def _calculate_realized_profit_fifo(db, port_ids: list) -> dict:
    """
    Berekent gerealiseerde winst/verlies met FIFO methode.
    
    BELANGRIJK: Gebruikt de wisselkoers OP HET MOMENT VAN DE TRANSACTIE.
    """
    if not port_ids:
        return {
            "total": 0.0,
            "dividends": 0.0,
            "fees": 0.0,
            "sell_count": 0,
            "breakdown": {"trading_gains": 0.0, "dividends": 0.0, "fees": 0.0}
        }
    
    tx_rows = (
        db.query(Transacties)
        .filter(Transacties.portefeuille_id.in_(port_ids))
        .filter(Transacties.type.in_(["BUY", "SELL", "PAYOUT", "FEE", "KOST", "DIVIDEND"]))
        .order_by(Transacties.datum_tr, Transacties.transactie_id)
        .all()
    )
    
    fifo_queues = {}
    rate_cache = {}
    overall_realized = 0.0
    total_dividends = 0.0
    total_fees = 0.0
    trading_gains = 0.0
    sell_count = 0
    
    for row in tx_rows:
        try:
            pid = row.portefeuille_id
            if pid is None:
                continue
            
            ttype = (row.type or "").upper()
            ticker = (row.ticker or "").upper()
            
            if ticker == "CASH":
                continue
            
            qty = _safe_float(row.aantal)
            price_local = _safe_float(row.koers)
            stored_rate = _safe_float(getattr(row, "wisselkoers", None), 0.0)
            wk = stored_rate if stored_rate > 0 else _lookup_rate(db, rate_cache, row.munt)
            
            queue_key = (pid, ticker)
            fifo_queues.setdefault(queue_key, [])
            
            if ttype == "BUY" and qty > 0:
                total_cost_eur = (qty * price_local) / wk
                fifo_queues[queue_key].append({
                    "qty": qty,
                    "cost_eur": total_cost_eur
                })
            
            elif ttype in ("SELL", "PAYOUT") and qty > 0:
                proceeds_eur = (qty * price_local) / wk
                cost_basis_eur = 0.0
                remaining = qty
                queue = fifo_queues[queue_key]
                
                while remaining > 0 and queue:
                    lot = queue[0]
                    if lot["qty"] <= remaining:
                        cost_basis_eur += lot["cost_eur"]
                        remaining -= lot["qty"]
                        queue.pop(0)
                    else:
                        fraction = remaining / lot["qty"]
                        cost_basis_eur += lot["cost_eur"] * fraction
                        lot["qty"] -= remaining
                        lot["cost_eur"] *= (1 - fraction)
                        remaining = 0
                
                realized = proceeds_eur - cost_basis_eur
                overall_realized += realized
                trading_gains += realized
                sell_count += 1
            
            elif ttype == "DIVIDEND":
                dividend_local = qty * price_local if qty > 0 else price_local
                dividend_eur = dividend_local / wk
                overall_realized += dividend_eur
                total_dividends += dividend_eur
            
            elif ttype in ("FEE", "KOST"):
                fee_local = price_local if price_local > 0 else abs(qty)
                fee_eur = fee_local / wk
                overall_realized -= fee_eur
                total_fees += fee_eur
                
        except Exception:
            continue
    
    return {
        "total": round(overall_realized, 2),
        "dividends": round(total_dividends, 2),
        "fees": round(total_fees, 2),
        "sell_count": sell_count,
        "breakdown": {
            "trading_gains": round(trading_gains, 2),
            "dividends": round(total_dividends, 2),
            "fees": round(total_fees, 2)
        }
    }


# =============================================================================
# API ENDPOINTS
# =============================================================================

@transacties_bp.route("/api/groups/<int:group_id>/realized_profit")
def api_realized_profit(group_id: int):
    """Gerealiseerde winst/verlies in EUR."""
    if "user_id" not in session:
        return jsonify({"error": "Niet ingelogd"}), 401

    uid = session.get("user_id")
    ok, mem = get_membership_for_user_in_group(uid, group_id)
    if not (ok and mem):
        return jsonify({"error": "Geen toegang tot deze groep"}), 403

    db = SessionLocal()
    try:
        q_port = request.args.get("port_id", type=int)
        all_port_ids = [r.port_id for r in db.query(Portefeuille.port_id).filter(Portefeuille.groep_id == group_id).all()]
        
        if q_port and q_port in all_port_ids:
            target_port_ids = [q_port]
        else:
            target_port_ids = all_port_ids

        result = _calculate_realized_profit_fifo(db, target_port_ids)
        return jsonify(result)
        
    except Exception as e:
        return jsonify({"error": f"Fout: {str(e)}"}), 500
    finally:
        db.close()


@transacties_bp.route("/api/groups/<int:group_id>/portfolio_summary")
def api_portfolio_summary(group_id: int):
    """
    Volledige portefeuille samenvatting voor dashboard.
    """
    if "user_id" not in session:
        return jsonify({"error": "Niet ingelogd"}), 401

    uid = session.get("user_id")
    ok, mem = get_membership_for_user_in_group(uid, group_id)
    if not (ok and mem):
        return jsonify({"error": "Geen toegang tot deze groep"}), 403

    db = SessionLocal()
    try:
        positions = db.query(Portefeuille).filter(Portefeuille.groep_id == group_id).all()
        port_ids = [p.port_id for p in positions]

        current_wk_map = _get_current_wk_from_table(db)
        currency_map = _get_position_currency_from_buy(db, port_ids)
        realized_data = _calculate_realized_profit_fifo(db, port_ids)

        cash_amount = 0.0
        total_value = 0.0
        total_cost = 0.0
        total_unrealized = 0.0
        sectors = {}
        position_list = []
        price_cache = {}

        for pos in positions:
            ticker = (pos.ticker or '').upper()
            if ticker == 'CASH':
                cash_amount = _safe_float(pos.quantity)
                continue

            qty = _safe_float(pos.quantity)
            if qty <= 0:
                continue

            munt = currency_map.get(pos.port_id, 'EUR')
            wk = 1.0 if munt == 'EUR' else current_wk_map.get(munt, 1.0)

            if ticker not in price_cache:
                fetched_price = get_latest_price(ticker)
                price_cache[ticker] = _safe_float(fetched_price)
            current_price_local = price_cache[ticker]

            current_price_eur = current_price_local / wk if wk > 0 else current_price_local
            current_value_eur = qty * current_price_eur

            avg_price_eur = _safe_float(pos.avg_price)
            fees_eur = _safe_float(pos.transactiekost)
            cost_basis_eur = (qty * avg_price_eur) + fees_eur
            unrealized = current_value_eur - cost_basis_eur
            unrealized_pct = (unrealized / cost_basis_eur * 100) if cost_basis_eur > 0 else 0

            total_value += current_value_eur
            total_cost += cost_basis_eur
            total_unrealized += unrealized

            asset = getattr(pos, "asset", None)
            sector = (asset.sector if asset and asset.sector else "Overig")
            sectors[sector] = sectors.get(sector, 0) + current_value_eur

            position_list.append({
                "port_id": pos.port_id,
                "ticker": ticker,
                "name": asset.name if asset and asset.name else ticker,
                "sector": sector,
                "munt": munt,
                "quantity": qty,
                "current_price_local": round(current_price_local, 2),
                "current_price_eur": round(current_price_eur, 2),
                "wisselkoers": round(wk, 4),
                "value_eur": round(current_value_eur, 2),
                "cost_basis_eur": round(cost_basis_eur, 2),
                "unrealized": round(unrealized, 2),
                "unrealized_pct": round(unrealized_pct, 2)
            })

        total_return = realized_data["total"] + total_unrealized
        return_pct = (total_return / total_cost * 100) if total_cost > 0 else 0

        return jsonify({
            "positions": position_list,
            "cash": round(cash_amount, 2),
            "totals": {
                "portfolio_value": round(total_value, 2),
                "total_value_with_cash": round(total_value + cash_amount, 2),
                "cost_basis": round(total_cost, 2),
                "total_return": round(total_return, 2),
                "return_percentage": round(return_pct, 2),
                "unrealized": round(total_unrealized, 2),
                "realized": realized_data["total"],
                "dividends": realized_data["dividends"],
                "fees": realized_data["fees"],
                "sell_count": realized_data["sell_count"],
            },
            "sectors": {k: round(v, 2) for k, v in sectors.items()},
            "position_count": len(position_list),
        })

    except Exception as e:
        import traceback
        return jsonify({
            "error": f"Fout bij ophalen: {str(e)}",
            "traceback": traceback.format_exc()
        }), 500
    finally:
        db.close()


@transacties_bp.route("/api/groups/<int:group_id>/debug_portfolio")
def api_debug_portfolio(group_id: int):
    """Debug endpoint om te zien wat er in de database staat."""
    if "user_id" not in session:
        return jsonify({"error": "Niet ingelogd"}), 401

    db = SessionLocal()
    try:
        positions = db.query(Portefeuille).filter(Portefeuille.groep_id == group_id).all()
        pos_data = []
        for p in positions:
            asset = getattr(p, "asset", None)
            pos_data.append({
                "port_id": p.port_id,
                "ticker": p.ticker,
                "quantity": p.quantity,
                "avg_price": p.avg_price,
                "transactiekost": p.transactiekost,
                "asset_name": asset.name if asset else None,
                "asset_sector": asset.sector if asset else None,
            })
        
        port_ids = [p.port_id for p in positions]
        txs = []
        if port_ids:
            rate_cache = {}
            tx_rows = db.query(Transacties).filter(Transacties.portefeuille_id.in_(port_ids)).order_by(desc(Transacties.datum_tr)).limit(20).all()
            for t in tx_rows:
                fx_rate = _lookup_rate(db, rate_cache, t.munt)
                txs.append({
                    "id": t.transactie_id,
                    "type": t.type,
                    "ticker": t.ticker,
                    "aantal": t.aantal,
                    "koers": t.koers,
                    "munt": t.munt,
                    "datum": str(t.datum_tr),
                    "port_id": t.portefeuille_id,
                    "fx_rate": fx_rate,
                })
        
        wk_rows = db.query(Wisselkoersen).all()
        wk_data = [
            {
                "munt": row.munt,
                "datum": row.datum.isoformat() if row.datum else None,
                "wk": row.wk,
            }
            for row in wk_rows
        ]
        
        # Extra: toon welke munt per positie wordt gedetecteerd
        currency_map = _get_position_currency_from_buy(db, port_ids)
        
        return jsonify({
            "positions": pos_data,
            "transactions": txs,
            "wisselkoersen": wk_data,
            "detected_currencies": currency_map
        })
        
    except Exception as e:
        return jsonify({"error": str(e)}), 500
    finally:
        db.close()

@transacties_bp.route("/api/groups/<int:group_id>/member_count")
def api_member_count(group_id: int):
    """Haal het aantal leden in een groep op."""
    if "user_id" not in session:
        return jsonify({"error": "Niet ingelogd"}), 401

    uid = session.get("user_id")
    ok, mem = get_membership_for_user_in_group(uid, group_id)
    if not (ok and mem):
        return jsonify({"error": "Geen toegang tot deze groep"}), 403

    db = SessionLocal()
    try:
        # Tel het aantal leden in de groep
        count = db.query(GroepLeden).filter(GroepLeden.groep_id == group_id).count()
        return jsonify({"member_count": count})
    except Exception as e:
        return jsonify({"error": f"Fout: {str(e)}"}), 500
    finally:
        db.close()