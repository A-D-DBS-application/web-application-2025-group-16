from flask import Blueprint, render_template, request, redirect, url_for, session, flash
import secrets
# Importeer functies uit jouw auth.py en config
from auth import (
    create_group_record, get_group_by_code, get_group_by_id, group_code_exists,
    add_member_to_group, get_membership_for_user, get_membership_for_user_in_group,
    list_group_members, count_group_members, list_memberships_for_user, list_groups_by_ids,
    initialize_cash_position, remove_member_from_group, delete_group,
    create_group_request, list_group_requests_for_group, approve_group_request,
    update_member_role, list_leden, update_member_role
)

groups_bp = Blueprint('groups', __name__)

# --- HELPERS (lokaal in dit bestand houden) ---
def _generate_invite_code(length: int = 6) -> str:
    alphabet = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"
    return "".join(secrets.choice(alphabet) for _ in range(length))

def _current_group_membership():
    user_id = session.get("user_id")
    if not user_id: return None
    desired_group_id = session.get("group_id")
    if desired_group_id:
        ok, membership = get_membership_for_user_in_group(user_id, desired_group_id)
        if ok and membership: return membership
    ok, membership = get_membership_for_user(user_id)
    if membership: session["group_id"] = membership.get("group_id")
    return membership

def _is_current_user_host():
    mem = _current_group_membership()
    return mem and mem.get("role") == "host"

def _load_group_context():
    membership = _current_group_membership()
    if not membership: return None, [], "Je hoort momenteel niet bij een groep."
    ok, group = get_group_by_id(membership["group_id"])
    if not ok or not group: return None, [], None
    ok, member_rows = list_group_members(group["id"])
    return group, member_rows, None

def _resolve_member_profiles(member_rows):
    if not member_rows: return []
    ok, leden_data = list_leden()
    if not ok: return []
    lookup = {e.get("ledenid"): e for e in leden_data}
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

# --- ROUTES ---

@groups_bp.route("/groups/create", methods=["GET", "POST"])
def create_group():
    if "user_id" not in session: return redirect(url_for("auth.login"))
    error = None
    code_value = _generate_invite_code()

    if request.method == "POST":
        name = (request.form.get("name") or "").strip()
        desc = (request.form.get("description") or "").strip()
        req_code = (request.form.get("code") or "").strip().upper()
        
        # Check code uniek
        if req_code:
            ok, exists = group_code_exists(req_code)
            if exists: error = "Code bestaat al."
            else: code_value = req_code
        
        if not error and name:
            ok, group = create_group_record(session["user_id"], name=name, description=desc, invite_code=code_value)
            if ok:
                # Maker is host
                add_member_to_group(group["id"], session["user_id"], role="host")
                initialize_cash_position(group["id"], amount=0)
                session["group_id"] = group["id"]
                return redirect(url_for("groups.group_dashboard"))
            else: error = group
        elif not name: error = "Naam verplicht."

    return render_template("group_create.html", error=error, code_value=code_value)

@groups_bp.route("/groups/join", methods=["GET", "POST"])
def join_group():
    if "user_id" not in session: return redirect(url_for("auth.login"))
    error = None
    if request.method == "POST":
        code = (request.form.get("code") or "").strip().upper()
        ok, group = get_group_by_code(code)
        if ok and group:
            create_group_request(group["id"], session["user_id"], "join")
            flash("Aanvraag verstuurd!", "info")
            return redirect(url_for("main.home"))
        else:
            error = "Ongeldige code."
    return render_template("group_join.html", error=error)

@groups_bp.route("/groups/current")
def group_dashboard():
    if "user_id" not in session: return redirect(url_for("auth.login"))
    group, members, err = _load_group_context()
    if not group: return redirect(url_for("main.home"))

    profiles = _resolve_member_profiles(members)
    is_host = _is_current_user_host()
    
    # Aanvragen ophalen
    requests_list = []
    if is_host:
        ok, req_rows = list_group_requests_for_group(group["id"])
        if ok and req_rows:
            ok_l, leden = list_leden()
            lookup = {u.get("ledenid"): u for u in leden} if ok_l else {}
            for r in req_rows:
                u = lookup.get(r.get("ledenid"), {})
                name = f"{u.get('voornaam','')} {u.get('achternaam','')}"
                requests_list.append({"id": r.get("id"), "full_name": name, "type": r.get("type")})

    group_ctx = {
        "id": group["id"], "name": group["name"], "code": group.get("invite_code"),
        "description": group.get("description"), "member_total": len(members), "owner_id": group.get("owner_id")
    }
    
    return render_template("group.html", group=group_ctx, members=profiles, is_owner=is_host, requests=requests_list, is_host=is_host, current_user_id=session["user_id"])

@groups_bp.route("/groups/select/<int:group_id>", methods=["POST"])
def select_group(group_id):
    if "user_id" not in session: return redirect(url_for("auth.login"))
    ok, mem = get_membership_for_user_in_group(session["user_id"], group_id)
    if ok and mem:
        session["group_id"] = group_id
    return redirect(url_for("groups.group_dashboard"))

# --- Lid promoveren tot Host ---
@groups_bp.route("/groups/promote/<int:member_id>", methods=["POST"])
def promote_member(member_id):
    if "user_id" not in session: 
        return redirect(url_for("auth.login"))
    
    # Check of de huidige gebruiker zelf wel host is
    if not _is_current_user_host():
        flash("Alleen hosts kunnen anderen promoveren.", "error")
        return redirect(url_for("groups.group_dashboard"))

    # Voer de update uit (rol 'host' geven)
    ok, msg = update_member_role(session["group_id"], member_id, "host")
    
    if ok:
        flash("Lid succesvol gepromoveerd tot host!", "success")
    else:
        flash(f"Fout bij promotie: {msg}", "error")
        
    return redirect(url_for("groups.group_dashboard"))

# --- NIEUWE ROUTE: Host degraderen naar Lid ---
@groups_bp.route("/groups/demote/<int:member_id>", methods=["POST"])
def demote_member(member_id):
    if "user_id" not in session: 
        return redirect(url_for("auth.login"))
    
    # Check of huidige user host is
    if not _is_current_user_host():
        flash("Geen rechten.", "error")
        return redirect(url_for("groups.group_dashboard"))

    # Haal de groep op om te checken wie de EIGENAAR is
    # (De eigenaar mag nooit gedegradeerd worden)
    ok, group = get_group_by_id(session["group_id"])
    if ok and group:
        if group["owner_id"] == member_id:
            flash("De eigenaar van de groep kan geen lid worden.", "error")
            return redirect(url_for("groups.group_dashboard"))

    # Update rol naar 'member'
    ok, msg = update_member_role(session["group_id"], member_id, "member")
    
    if ok:
        flash("Host succesvol teruggezet naar lid.", "success")
    else:
        flash(f"Fout: {msg}", "error")
        
    return redirect(url_for("groups.group_dashboard"))

@groups_bp.route("/groups/requests/<int:req_id>/approve", methods=["POST"])
def approve_request(req_id):
    if not _is_current_user_host(): return redirect(url_for("groups.group_dashboard"))
    approve_group_request(req_id, session["user_id"])
    return redirect(url_for("groups.group_dashboard"))

@groups_bp.route("/groups/leave", methods=["POST"])
def leave_group():
    if "user_id" in session and session.get("group_id"):
        create_group_request(session["group_id"], session["user_id"], "leave")
        flash("Uitstapaanvraag verstuurd.", "info")
    return redirect(url_for("main.home"))

@groups_bp.route("/groups/delete", methods=["POST"])
def delete_group_route():
    if _is_current_user_host() and session.get("group_id"):
        delete_group(session["group_id"])
        session.pop("group_id", None)
    return redirect(url_for("main.home"))

@groups_bp.route("/groups/remove-member/<int:member_id>", methods=["POST"])
def remove_group_member(member_id):
    if _is_current_user_host() and session.get("group_id"):
        remove_member_from_group(session["group_id"], member_id)
    return redirect(url_for("groups.group_dashboard"))