extends RefCounted

const OFFER_COUNT := 3
const VALID_CATEGORIES := ["offense", "defense", "mobility", "utility", "ability", "build"]
const VALID_RARITIES := ["common", "rare", "epic"]
const VALID_CLASSES := ["warrior", "ranger", "mage", "rogue"]

const CARDS: Array[Dictionary] = [
	{"id":"keen_edge", "name":"Keen Edge", "category":"offense", "rarity":"common", "classes":["any"], "max_rank":3, "description":"Increase the damage of every attack.", "effects":{"damage_flat":2.0}},
	{"id":"quick_hands", "name":"Quick Hands", "category":"offense", "rarity":"common", "classes":["any"], "max_rank":3, "description":"Attack more quickly.", "effects":{"attack_speed_pct":0.08}},
	{"id":"long_reach", "name":"Long Reach", "category":"offense", "rarity":"common", "classes":["any"], "max_rank":2, "description":"Extend the reach of your attacks.", "effects":{"attack_range_pct":0.12}},
	{"id":"deadeye", "name":"Deadeye", "category":"offense", "rarity":"rare", "classes":["any"], "max_rank":3, "description":"Improve your chance to land a critical hit.", "effects":{"crit_chance":0.05}},
	{"id":"savage_critical", "name":"Savage Critical", "category":"offense", "rarity":"rare", "classes":["any"], "max_rank":2, "description":"Critical hits deal more damage.", "effects":{"crit_damage":0.25}},
	{"id":"extra_projectile", "name":"Extra Projectile", "category":"offense", "rarity":"rare", "classes":["ranger", "mage"], "max_rank":2, "description":"Launch one additional projectile per attack.", "effects":{"projectile_count":1}},
	{"id":"piercing_shots", "name":"Piercing Shots", "category":"offense", "rarity":"rare", "classes":["ranger", "mage"], "max_rank":2, "description":"Projectiles pierce one additional target.", "effects":{"projectile_pierce":1}},
	{"id":"warrior_whirlwind", "name":"Whirlwind Adept", "category":"ability", "rarity":"rare", "classes":["warrior"], "max_rank":1, "description":"Unlock the Whirlwind attack.", "effects":{"ability_unlocked":true}, "active":true, "attack_id":"Whirlwind"},
	{"id":"ranger_volley", "name":"Volley Master", "category":"ability", "rarity":"rare", "classes":["ranger"], "max_rank":1, "description":"Unlock the Volley attack.", "effects":{"ability_unlocked":true}, "active":true, "attack_id":"Volley"},
	{"id":"mage_arcane_burst", "name":"Arcane Burst", "category":"ability", "rarity":"rare", "classes":["mage"], "max_rank":1, "description":"Unlock the Arcane Burst attack.", "effects":{"ability_unlocked":true}, "active":true, "attack_id":"Arcane Burst"},
	{"id":"rogue_shadow_strike", "name":"Shadow Strike", "category":"ability", "rarity":"rare", "classes":["rogue"], "max_rank":1, "description":"Unlock the Shadow Strike attack.", "effects":{"ability_unlocked":true}, "active":true, "attack_id":"Shadow Strike"},
	{"id":"iron_vitality", "name":"Iron Vitality", "category":"defense", "rarity":"common", "classes":["any"], "max_rank":3, "description":"Increase your maximum health.", "effects":{"max_hp":18.0}},
	{"id":"reinforced_armor", "name":"Reinforced Armor", "category":"defense", "rarity":"common", "classes":["any"], "max_rank":3, "description":"Gain a little armor against incoming hits.", "effects":{"armor":3.0}},
	{"id":"warding_skin", "name":"Warding Skin", "category":"defense", "rarity":"rare", "classes":["any"], "max_rank":2, "description":"Reduce damage taken from every source.", "effects":{"damage_reduction":0.04}},
	{"id":"steady_regeneration", "name":"Steady Regeneration", "category":"defense", "rarity":"rare", "classes":["any"], "max_rank":2, "description":"Recover health over time.", "effects":{"regen":0.6}},
	{"id":"evasive_step", "name":"Evasive Step", "category":"mobility", "rarity":"rare", "classes":["any"], "max_rank":2, "description":"Gain a chance to avoid incoming damage.", "effects":{"dodge_chance":0.04}},
	{"id":"fleet_foot", "name":"Fleet Foot", "category":"mobility", "rarity":"common", "classes":["any"], "max_rank":3, "description":"Move faster across the field.", "effects":{"move_speed_pct":0.07}},
	{"id":"scholars_insight", "name":"Scholar's Insight", "category":"utility", "rarity":"common", "classes":["any"], "max_rank":3, "description":"Earn experience more quickly.", "effects":{"xp_gain_pct":0.10}},
	{"id":"magnetism", "name":"Magnetism", "category":"utility", "rarity":"common", "classes":["any"], "max_rank":2, "description":"Collect nearby drops from farther away.", "effects":{"pickup_magnet":45.0}},
	{"id":"lucky_purse", "name":"Lucky Purse", "category":"utility", "rarity":"common", "classes":["any"], "max_rank":3, "description":"Find more gold in your travels.", "effects":{"gold_bonus":0.12}},
	{"id":"forager", "name":"Forager", "category":"utility", "rarity":"common", "classes":["any"], "max_rank":2, "description":"Find more useful items.", "effects":{"item_bonus":0.12}},
	{"id":"healing_lore", "name":"Healing Lore", "category":"utility", "rarity":"rare", "classes":["any"], "max_rank":2, "description":"Potions and other healing restore more health.", "effects":{"healing_bonus":0.15}},
	{"id":"glass_cannon", "name":"Glass Cannon", "category":"build", "rarity":"epic", "classes":["any"], "max_rank":1, "description":"Deal devastatingly increased damage at the cost of health and resilience.", "drawback":"Maximum health and armor are reduced.", "effects":{"damage_pct":0.35, "max_hp":-24.0, "armor":-2.0}},
	{"id":"berserker", "name":"Berserker", "category":"build", "rarity":"epic", "classes":["warrior", "rogue"], "max_rank":1, "description":"Strike faster and harder while sacrificing defense.", "drawback":"Take increased damage.", "effects":{"damage_pct":0.18, "attack_speed_pct":0.18, "damage_reduction":-0.08}},
	{"id":"vampiric_strikes", "name":"Vampiric Strikes", "category":"build", "rarity":"epic", "classes":["any"], "max_rank":1, "description":"A portion of damage dealt restores your health.", "drawback":"Attacks deal slightly less damage.", "effects":{"lifesteal":0.06, "damage_pct":-0.05}},
	{"id":"swarm_master", "name":"Swarm Master", "category":"build", "rarity":"epic", "classes":["ranger", "mage"], "max_rank":1, "description":"Flood the field with extra projectiles.", "drawback":"Each projectile deals less damage.", "effects":{"projectile_count":2, "damage_pct":-0.12}},
	{"id":"treasure_hunter", "name":"Treasure Hunter", "category":"build", "rarity":"epic", "classes":["any"], "max_rank":1, "description":"Greatly increase gold and item finds.", "drawback":"Gain experience more slowly.", "effects":{"gold_bonus":0.40, "item_bonus":0.25, "xp_gain_pct":-0.12}},
	{"id":"arcane_overload", "name":"Arcane Overload", "category":"build", "rarity":"epic", "classes":["mage"], "max_rank":1, "description":"Unleash stronger, faster spells.", "drawback":"Maximum health and damage reduction fall.", "effects":{"damage_pct":0.28, "attack_speed_pct":0.12, "max_hp":-18.0, "damage_reduction":-0.05}},
		{"id":"battle_hardened", "name":"Battle Hardened", "category":"defense", "rarity":"rare", "classes":["warrior"], "max_rank":2, "description":"A warrior's training grants extra health and armor.", "effects":{"max_hp":14.0, "armor":2.0}},
		{"id":"ranger_focus", "name":"Ranger's Focus", "category":"offense", "rarity":"rare", "classes":["ranger"], "max_rank":2, "description":"Improve ranged precision and projectile reach.", "effects":{"crit_chance":0.04, "attack_range_pct":0.10}},
		{"id":"veterans_instinct", "name":"Veteran's Instinct", "category":"offense", "rarity":"common", "classes":["any"], "max_rank":99, "description":"A lifetime of survival sharpens every strike.", "effects":{"damage_flat":1.0}},
		{"id":"field_dressing", "name":"Field Dressing", "category":"defense", "rarity":"common", "classes":["any"], "max_rank":99, "description":"Improve your maximum health through hard-won grit.", "effects":{"max_hp":6.0}},
		{"id":"long_scout", "name":"Long Scout", "category":"utility", "rarity":"common", "classes":["any"], "max_rank":99, "description":"Spot and draw in experience from a little farther away.", "effects":{"pickup_magnet":18.0}},
	]

func all_cards() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for card in CARDS:
		result.append(card.duplicate(true))
	return result

func get_card(id: String) -> Dictionary:
	for card in CARDS:
		if card["id"] == id:
			return card.duplicate(true)
	return {}

func eligible_cards(class_id: String, owned_ranks: Dictionary, active_slots: Array[String]) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for card in CARDS:
		var classes: Array = card["classes"]
		if not classes.has("any") and not classes.has(class_id):
			continue
		if int(owned_ranks.get(card["id"], 0)) >= int(card["max_rank"]):
			continue
		if card.has("attack_id") and active_slots.has(String(card["attack_id"])):
			continue
		result.append(card.duplicate(true))
	return result

func roll_offers(class_id: String, owned_ranks: Dictionary, active_slots: Array[String], seed: int = -1) -> Array[Dictionary]:
	var pool := eligible_cards(class_id, owned_ranks, active_slots)
	if seed >= 0:
		var rng := RandomNumberGenerator.new()
		rng.seed = seed
		for i in range(pool.size() - 1, 0, -1):
			var j := rng.randi_range(0, i)
			var temp: Dictionary = pool[i]
			pool[i] = pool[j]
			pool[j] = temp
	else:
		pool.shuffle()
	var offers: Array[Dictionary] = []
	for i in range(min(OFFER_COUNT, pool.size())):
		offers.append(pool[i].duplicate(true))
	return offers
