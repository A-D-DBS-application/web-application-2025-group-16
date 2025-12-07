from config import supabase


def get_group_data(group_id: int):
    """Ophalen van groep data"""
    resp = supabase.table("Groep").select("*").eq("groep_id", group_id).execute()
    if not resp.data:
        return None
    return resp.data[0]


def count_members(group_id):
    resp = supabase.table("groep_leden").select("ledenid").eq("groep_id", group_id).execute()
    return len(resp.data) if resp.data else 0

def get_group_nav(group_id):
    resp = supabase.table("Portefeuille").select("quantity, current_price").eq("groep_id", group_id).execute()
    if not resp.data:
        return 0
    
    total = 0
    for row in resp.data:
        qty = row.get("quantity") or 0
        price = row.get("current_price") or 0
        total += qty * price
    
    return total




# ---------- INSTAPKOST ----------
def calculate_entry_cost(group_id):
    total_nav = get_group_nav(group_id)
    members = count_members(group_id) or 1

    nav_per_member = total_nav / members
    entry_cost = nav_per_member * 1.02

    return True, {
        "nav_per_member": nav_per_member,
        "entry_cost": entry_cost,
        "fee_rate": 0.02
    }


def calculate_exit_cost(group_id):
    group = get_group_data(group_id)
    total_nav = get_group_nav(group_id)
    members = count_members(group_id) or 1

    buffer = group.get("liquidatie_voorziening") or 0

    nav_per_member = total_nav / members
    base = nav_per_member - buffer
    after_fee = base * 0.99

    return True, {
        "nav_per_member": nav_per_member,
        "liquidatie_buffer": buffer,
        "exit_payout": after_fee,
        "fee_rate": 0.01
    }
