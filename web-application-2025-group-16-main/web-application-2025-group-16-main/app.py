from flask import Flask, render_template, request, redirect, session, url_for
import os, logging, traceback
from werkzeug.exceptions import HTTPException
from auth import sign_up_user, sign_in_user, list_leden
import re

app = Flask(__name__)
app.secret_key = os.environ.get("FLASK_SECRET_KEY", "dev-secret")
logging.basicConfig(level=logging.INFO)

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
    return render_template("home.html")  # simple HOME page

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
    mode = request.form.get("mode") if request.method == "POST" else request.args.get("mode", "login")
    if request.method == "POST":
        email = (request.form.get("email") or "").strip().lower()
        if not email:
            return render_template("login.html", error="Voer een e-mailadres in.", email_value=email, mode_value=mode or "login")
        pattern = r"^[^@\s]+@[^@\s]+\.[^@\s]+$"
        if not re.match(pattern, email):
            return render_template("login.html", error="Ongeldig e-mailadres formaat.", email_value=email, mode_value=mode or "login")
        if mode == "register":
            return redirect(url_for("register", email=email))
        ok, res = sign_in_user(email)
        if not ok:
            return render_template("login.html", error=res, email_value=email, mode_value="login")
        session["user_id"] = res.get("ledenid")
        session["email"] = res.get("email")
        return redirect(url_for("home"))
    preset_email = request.args.get("email", "")
    return render_template("login.html", email_value=preset_email, mode_value=mode or "login")

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
        return e  # let Flask serve 404/other HTTP errors as-is
    logging.error("Unhandled exception: %s", e)
    traceback.print_exc()
    return render_template("error.html", error=str(e)), 500

if __name__ == "__main__":
    app.run(debug=True)
