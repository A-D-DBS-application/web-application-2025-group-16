from flask import Blueprint, render_template, request, redirect, url_for, session
# We importeren jouw bestaande functies uit auth.py (die staat in de map erboven)
from auth import sign_in_user, sign_up_user

auth_bp = Blueprint('auth', __name__)

@auth_bp.route("/login", methods=["GET", "POST"])
def login():
    if request.method == "POST":
        email = (request.form.get("email") or "").strip().lower()
        ok, res = sign_in_user(email)
        if ok:
            session["user_id"] = res.get("ledenid")
            session["email"] = res.get("email")
            # Ga naar home (in main blueprint)
            return redirect(url_for("main.home"))
        return render_template("login.html", error=res, email_value=email)
    return render_template("login.html")

@auth_bp.route("/register", methods=["GET", "POST"])
def register():
    if request.method == "POST":
        email = request.form.get("email", "").strip()
        voornaam = request.form.get("voornaam", "").strip()
        achternaam = request.form.get("achternaam", "").strip()
        gsm_raw = request.form.get("gsm", "").strip()
        digits = "".join(ch for ch in gsm_raw if ch.isdigit())
        gsm = int(digits) if digits else 0
        
        ok, res = sign_up_user(email, voornaam, achternaam, gsm)
        if ok: return redirect(url_for("auth.login"))
        return render_template("register.html", error=res)
    return render_template("register.html")

@auth_bp.route("/logout")
def logout():
    session.clear()
    return redirect(url_for("auth.login"))