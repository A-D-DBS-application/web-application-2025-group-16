from dotenv import load_dotenv
load_dotenv()
import os 

from supabase import create_client

url = os.environ.get("SUPABASE_URL")
key = os.environ.get("SUPABASE_ANON_KEY")   

supabase = create_client(url, key)



#inserting data
#data = supabase.table("Leden").insert({"voornaam":"testinsert"}).execute()


#updating data
data = supabase.table("Leden").update({"voornaam":"testupdate"}).eq("ledenid",3).execute() 

#deleting data
data = supabase.table("Leden").delete().eq("ledenid",5).execute()

#reading data
data = supabase.table("Leden").select("*").execute() 
# "*" betekent dat je alles aanduidt, je kan ook specifieke kolommen opvragen
#je kan ook filters toevoegen zoals .eq("kolomnaam", "waarde") voor gelijkheid
# je kan dit zien in supabase bij de javascript documentatie
print(data)