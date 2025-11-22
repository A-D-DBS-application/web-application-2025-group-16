import os
from supabase import create_client, Client

# --- CONFIGURATIE ---
# Vul hier je Supabase URL en SERVICE KEY in
SUPABASE_URL = "https://bpbvlfptoacijyqyugew.supabase.co"
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJwYnZsZnB0b2FjaWp5cXl1Z2V3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjA2NDk2NzAsImV4cCI6MjA3NjIyNTY3MH0.6_z9bE3aB4QMt5ASE0bxM6Ds8Tf7189sBDUVLrUeU-M"

# Initialiseer Supabase
try:
    # Debug print om te checken of de key geladen is
    print(f"--- DEBUG: Auth script start. URL ingesteld? {'Ja' if SUPABASE_URL else 'Nee'}")
    
    supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)
    print("--- DEBUG: Supabase verbinding succesvol ---")
except Exception as e:
    print(f"Supabase init error: {e}")

def sign_in_user(email):
    """Zoekt een gebruiker in de tabel 'Leden' op basis van email"""
    try:
        response = supabase.table('Leden').select("*").eq('email', email).execute()
        # Als we data terugkrijgen, is de gebruiker gevonden
        if response.data and len(response.data) > 0:
            return True, response.data[0] # Return de eerste gebruiker
        else:
            return False, "Geen gebruiker gevonden met dit e-mailadres."
    except Exception as e:
        return False, str(e)

def sign_up_user(email, voornaam, achternaam, gsm):
    """Maakt een nieuwe gebruiker aan in de tabel 'Leden'"""
    try:
        # Eerst checken of email al bestaat
        check = supabase.table('Leden').select("*").eq('email', email).execute()
        if check.data and len(check.data) > 0:
            return False, "Dit e-mailadres is al in gebruik."

        # Nieuwe gebruiker invoegen
        new_user = {
            "email": email,
            "voornaam": voornaam,
            "achternaam": achternaam,
            "GSM": gsm
        }
        response = supabase.table('Leden').insert(new_user).execute()
        return True, "Gebruiker succesvol aangemaakt."
    except Exception as e:
        return False, str(e)

def list_leden():
    """Haalt alle leden op"""
    try:
        response = supabase.table('Leden').select("*").execute()
        return True, response.data
    except Exception as e:
        return False, str(e)