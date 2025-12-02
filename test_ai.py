import google.generativeai as genai

# Jouw API key uit app.py
KEY = "AIzaSyAZg1iH9D4oPxzR6mq3RbjUerfmNvZxYCg" 

try:
    genai.configure(api_key=KEY)
    print("✅ Verbinding met Google gelukt. Bezig met ophalen modellen...")
    print("-" * 30)
    
    found = False
    for m in genai.list_models():
        if 'generateContent' in m.supported_generation_methods:
            print(f"beschikbaar: {m.name}")
            found = True
            
    if not found:
        print("❌ Geen modellen gevonden die tekst kunnen genereren.")
    else:
        print("-" * 30)
        print("Kies een van de bovenstaande namen en zet die in CURRENT_MODEL_NAME in app.py")

except Exception as e:
    print(f"❌ Fout bij verbinden: {e}")