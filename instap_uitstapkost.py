from config import supabase


# --------------------------------------------------------
#   NAV BEREKENEN (alleen portefeuille, geen kas)
# --------------------------------------------------------
def get_group_nav(group_id):
    port = supabase.table("Portefeuille") \
        .select("quantity, current_price") \
        .eq("groep_id", group_id).execute().data or []

    nav_total = sum([float(r["quantity"]) * float(r["current_price"]) for r in port])

    return nav_total


# --------------------------------------------------------
#   Liquiditeit totaal ophalen
# --------------------------------------------------------
def get_total_liquidity(group_id):
    rows = supabase.table("Liquiditeit").select("*").eq("groep_id", group_id).execute().data or []
    return sum(float(r["bedrag"]) for r in rows)




# --------------------------------------------------------
#   Instapkost berekenen
# --------------------------------------------------------
def calculate_entry_cost(group_id):
    try:
        # --- NAV berekenen ---
        nav_total = get_group_nav(group_id)
        if nav_total is None:
            return False, "NAV kon niet berekend worden"

        # leden tellen
        members = supabase.table("groep_leden") \
            .select("*").eq("groep_id", group_id).execute().data or []
        leden = len(members)
        if leden == 0:
            return False, "Geen leden gevonden"

        nav_per_member = nav_total / leden

        # instellingen ophalen
        settings = supabase.table("Groep") \
            .select("*") \
            .eq("groep_id", group_id) \
            .single().execute().data

        instap_nav_pct = float(settings.get("instap_nav_pct", 0))

        # NAV fee
        nav_fee = nav_per_member * (instap_nav_pct / 100)

        # ❌ GEEN LIQUIDITEITSKOST VOOR INSTAPPERS
        liq_fee = 0

        entry_cost = nav_per_member + nav_fee

        return True, {
            "nav_per_member": nav_per_member,
            "nav_fee": nav_fee,
            "liq_fee": liq_fee,
            "entry_cost": entry_cost
        }

    except Exception as e:
        return False, str(e)





def calculate_exit_cost(group_id):
    try:
        # 1) NAV ophalen
        nav_total = get_group_nav(group_id)
        if nav_total is None:
            return False, "Kan NAV niet berekenen"

        # 2) aantal leden
        members = supabase.table("groep_leden") \
            .select("*") \
            .eq("groep_id", group_id).execute().data or []
        leden = len(members)
        if leden == 0:
            return False, "Geen leden"

        # NAV per lid
        nav_per_member = nav_total / leden

        # 3) instellingen ophalen
        settings = supabase.table("Groep") \
            .select("*") \
            .eq("groep_id", group_id) \
            .single().execute().data

        uitstap_nav_pct = float(settings.get("uitstap_nav_pct", 0))
        uitstap_liq_pct = float(settings.get("uitstap_liq_pct", 0))
        liq_per_lid = settings.get("liq_per_lid", False)

        # 4) totale liquiditeitsbuffer
        total_liq = get_total_liquidity(group_id)

        # NAV fee:
        nav_fee = nav_per_member * (uitstap_nav_pct / 100)

        # 5) Liquiditeitsfee:
        if liq_per_lid:
            # gelijk delen
            liq_fee = total_liq / leden
        else:
            # percentage van totale liquiditeitsbuffer
            liq_fee = (total_liq * (uitstap_liq_pct / 100)) / leden


        # 6) totale uitstapwaarde
        exit_payout = nav_per_member - nav_fee - liq_fee

        return True, {
            "nav_per_member": nav_per_member,
            "nav_fee": nav_fee,
            "liq_fee": liq_fee,
            "exit_payout": exit_payout
        }

    except Exception as e:
        return False, str(e)
