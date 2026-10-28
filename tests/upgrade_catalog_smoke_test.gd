extends SceneTree

const Catalog = preload("res://scripts/upgrade_catalog.gd")

func _initialize() -> void:
	var catalog = Catalog.new()
	var cards := catalog.all_cards()
	_check(cards.size() >= 25 and cards.size() <= 40, "catalog contains 25-40 cards")
	var ids := {}
	var categories := {}
	var build_cards := 0
	for card in cards:
		_check(card.has("id") and not String(card["id"]).is_empty(), "card has stable id")
		_check(not ids.has(card["id"]), "card ids are unique")
		ids[card["id"]] = true
		_check(card.has("name") and not String(card["name"]).is_empty(), "card has readable name")
		_check(["offense", "defense", "mobility", "utility", "ability", "build"].has(card.get("category", "")), "valid category")
		categories[card["category"]] = true
		_check(["common", "rare", "epic"].has(card.get("rarity", "")), "valid rarity")
		_check(card.get("max_rank", 0) > 0, "finite positive max rank")
		_check(card.has("classes") and card["classes"] is Array and card["classes"].size() > 0, "class eligibility is declared")
		_check(card.has("description") and not String(card["description"]).is_empty(), "plain description exists")
		_check(card.has("effects") and card["effects"] is Dictionary and not card["effects"].is_empty(), "effect data exists")
		for value in card["effects"].values():
			_check(value is int or value is float or value is bool, "effect uses a scalar number or flag")
		if card["category"] == "build":
			build_cards += 1
		if card["category"] == "ability":
			_check(card.has("attack_id") and ["Whirlwind", "Volley", "Arcane Burst", "Shadow Strike"].has(card["attack_id"]), "ability references an existing attack")
	_check(categories.size() >= 4, "at least four broad categories")
	_check(build_cards >= 4, "at least four build-defining cards")

	var offers := catalog.roll_offers("warrior", {}, [], 8675309)
	_check(offers.size() == 3, "three offers when enough eligible cards exist")
	var offer_ids := {}
	for offer in offers:
		offer_ids[offer["id"]] = true
	_check(offer_ids.size() == offers.size(), "offers are distinct")
	var repeat_offers := catalog.roll_offers("warrior", {}, [], 8675309)
	var repeat_ids: Array[String] = []
	var first_ids: Array[String] = []
	for offer in repeat_offers:
		repeat_ids.append(offer["id"])
	for offer in offers:
		first_ids.append(offer["id"])
	_check(first_ids == repeat_ids, "same seed repeats offer order")

	var mage_cards := catalog.eligible_cards("mage", {}, [])
	var mage_has_berserker := false
	for card in mage_cards:
		if card["id"] == "berserker":
			mage_has_berserker = true
	_check(not mage_has_berserker, "class-incompatible card is filtered")
	var warrior_cards := catalog.eligible_cards("warrior", {}, [])
	var warrior_has_volley := false
	for card in warrior_cards:
		if card["id"] == "ranger_volley":
			warrior_has_volley = true
	_check(not warrior_has_volley, "class-specific ability is filtered")
	var maxed := catalog.eligible_cards("warrior", {"keen_edge": 3}, [])
	var has_maxed := false
	for card in maxed:
		if card["id"] == "keen_edge":
			has_maxed = true
	_check(not has_maxed, "max-rank card is excluded")
	var active_filtered := catalog.eligible_cards("warrior", {}, ["Whirlwind"])
	var has_active := false
	for card in active_filtered:
		if card["id"] == "warrior_whirlwind":
			has_active = true
	_check(not has_active, "already active ability is excluded")

	if not _failed:
		print("PASS: upgrade catalog smoke test (%d cards)" % cards.size())
		quit(0)
	else:
		quit(1)

var _failed := false
func _check(condition: bool, message: String) -> void:
	if not condition:
		_failed = true
		push_error("FAIL: " + message)
