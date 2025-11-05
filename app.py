# 1. Alle benodigde imports
import os
from flask import Flask, render_template, request, redirect, url_for
from supabase import create_client, Client

# (Zorg dat je 'python-dotenv' hebt geïnstalleerd met 'pip install python-dotenv')
# Laad de omgevingsvariabelen (zoals SUPABASE_URL) uit je .env bestand
from dotenv import load_dotenv
load_dotenv()

# 2. Initialiseer de Flask App
app = Flask(__name__)

# 3. Initialiseer de Supabase Client
# Haal je keys uit de environment variables (veilig!)
url = os.environ.get("SUPABASE_URL")
key = os.environ.get("SUPABASE_KEY")
supabase: Client = create_client(url, key)

# --- Routes ---

# 4. Route voor de Homepagina ('/')
@app.route('/')
def home():
    # Voorbeeld van data meegeven aan je template
    club_naam_uit_db = "De Gouden Aandelen" 
    return render_template('index.html', club_naam=club_naam_uit_db)

# 5. Route voor Inloggen ('/inloggen')
@app.route('/inloggen', methods=['GET', 'POST'])
def inloggen():
    if request.method == 'POST':
        # Als het formulier is verstuurd (POST)
        username = request.form['username']
        password = request.form['password']
        
        # --- HIER KOMT JE SUPABASE AUTHENTICATIE LOGICA ---
        # (bijv. supabase.auth.sign_in_with_password(...))
        
        print(f"Gebruiker probeert in te loggen: {username}")
        
        # Stuur door naar het portfolio na "succesvol" inloggen
        return redirect(url_for('portfolio')) 
        
    # Als de pagina gewoon wordt geladen (GET), toon het loginformulier
    # Hiervoor heb je 'templates/login.html' nodig
    return render_template('login.html')

# 6. Route voor het Portfolio ('/portfolio')
@app.route('/portfolio')
def portfolio():
    # --- HIER KOMT JE SUPABASE DATA OPHAAL LOGICA ---
    # 1. Check eerst of de gebruiker wel is ingelogd (via 'session')
    
    # 2. Haal de data op (voorbeeld)
    try:
        response = supabase.table('investments').select("*").execute()
        data = response.data
    except Exception as e:
        print(f"Fout bij ophalen data: {e}")
        data = [] # Geef een lege lijst bij een fout
    
    # Geef de opgehaalde data mee aan het template
    # Hiervoor heb je 'templates/portfolio.html' nodig
    return render_template('portfolio.html', investments=data)

# 7. Start de applicatie
if __name__ == '__main__':
    app.run(debug=True) # debug=True is voor ontwikkeling
    