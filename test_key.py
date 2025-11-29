import google.generativeai as genai
import os

# Jouw sleutel
MY_KEY = "AIzaSyAZg1iH9D4oPxzR6mq3RbjUerfmNvZxYCg"

print(f"--- Sleutel testen: {MY_KEY[:10]}... ---")

try:
    # 1. Configureer
    genai.configure(api_key=MY_KEY)
    
    # 2. Vraag de modellen op (simpele test)
    print("Verbinding maken met Google...")
    models = list(genai.list_models())
    
    found = False
    for m in models:
        if "gemini" in m.name:
            found = True
            print(f"✅ Gevonden model: {m.name}")
            break
            
    if found:
        print("\n🎉 SUCCES! De sleutel werkt perfect.")
        print("Het probleem zit dus in de Flask app (app.py).")
    else:
        print("\n⚠️ Verbinding gelukt, maar geen Gemini modellen gevonden.")

except Exception as e:
    print("\n❌ FOUT: De sleutel werkt NIET.")
    print(f"Melding: {e}")
    print("\nAdvies: Maak een NIEUWE sleutel aan op https://aistudio.google.com/app/apikey")