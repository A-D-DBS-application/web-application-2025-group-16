from flask import Flask, redirect, url_for, session
from config import SECRET_KEY

# Importeer de blueprints
from routes.auth_routes import auth_bp
from routes.group_routes import groups_bp
from routes.main_routes import main_bp

app = Flask(__name__)
app.secret_key = SECRET_KEY
app.config['TEMPLATES_AUTO_RELOAD'] = True

# Registreer de modules
app.register_blueprint(auth_bp)
app.register_blueprint(groups_bp)
app.register_blueprint(main_bp)

@app.route("/")
def index():
    return redirect(url_for("main.home" if session.get("user_id") else "auth.login"))

@app.route("/health")
def health():
    return {"status": "ok"}

if __name__ == "__main__":
    app.run(debug=True)