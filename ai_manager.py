import os
import google.generativeai as genai
import re
from config import GOOGLE_API_KEY

# --- CONFIGURATIE ---
CURRENT_MODEL_NAME = "gemini-2.0-flash"
GENAI_AVAILABLE = False

if GOOGLE_API_KEY and "PLAK_HIER" not in GOOGLE_API_KEY:
    try:
        genai.configure(api_key=GOOGLE_API_KEY.strip())
        GENAI_AVAILABLE = True
        print("✅ AI Geconfigureerd")
    except Exception as e:
        print(f"⚠️ AI Configuratiefout: {e}")

def clean_ai_response(text):
    """Verwijder Markdown, preambles en rare tekens uit de AI output."""
    if not text: return ""
    
    # 1. Verwijder markdown code blocks (```html en ```)
    clean = text.replace("```html", "").replace("```", "")
    
    # 2. Probeer alles VÓÓR de eerste <h3> of <div> weg te knippen
    # Dit verwijdert introducties zoals "Hier is de analyse:" of disclaimers
    # We zoeken naar de eerste HTML tag die structuur geeft.
    match = re.search(r'<(h[1-6]|div|p|ul|table)', clean, re.IGNORECASE)
    if match:
        clean = clean[match.start():]
        
    return clean.strip()

# --- FUNCTIES ---
def generate_ai_content_safe(prompt):
    """Probeert AI aan te roepen. Geeft altijd schone HTML terug."""
    
    if not GENAI_AVAILABLE:
        return "<p class='text-red-500'>⚠️ AI library niet geladen of geen API Key.</p>"
    
    try:
        model = genai.GenerativeModel(CURRENT_MODEL_NAME)
        
        # We voegen instructies toe aan de prompt om de AI te dwingen
        strict_prompt = (
            f"{prompt}\n\n"
            "BELANGRIJK: Geef ALLEEN de HTML code terug. "
            "Begin direct met <div> of <h3>. "
            "Geen introductie, geen 'Hier is de analyse', geen markdown backticks. "
            "Geef geen disclaimer buiten de HTML."
        )
        
        response = model.generate_content(strict_prompt)
        
        if response and hasattr(response, 'text') and response.text:
            # Maak de output schoon
            return clean_ai_response(response.text)
        else:
            return "<p class='text-slate-500'>⚠️ AI gaf een leeg antwoord terug.</p>"
            
    except Exception as e:
        error_msg = str(e)
        if "429" in error_msg or "quota" in error_msg.lower():
             return "<p class='text-amber-600'>⚠️ AI limiet bereikt (Quota exceeded). Probeer later.</p>"
        return f"<p class='text-red-500'>⚠️ AI Fout: {error_msg}</p>"