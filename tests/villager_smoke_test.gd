extends SceneTree

func _initialize():
 call_deferred("_run")

func _run():
 var game = load("res://scenes/main.tscn").instantiate()
 root.add_child(game)
 await process_frame
 assert(game.get("villagers").size() == 2, "Expected two initialized villagers")
 game.set("screen", "game")
 game.set("area_id", "village")
 var villagers = game.get("villagers")
 var mira_start: Vector2 = villagers[0]["pos"]
 game.call("_update_villagers", 1.0)
 game.call("_update_villagers", 1.0)
 var mira_after: Vector2 = game.get("villagers")[0]["pos"]
 assert(mira_start.distance_to(mira_after) > 1.0, "Mira should walk along her route")
 game.set("hero", mira_after)
 assert(game.call("_nearest") == "Mira", "Mira should be the nearest interaction")
 game.call("_interact")
 assert(game.get("screen") == "villager_dialogue", "Interacting should open dialogue")
 assert(game.get("talking_to") == "Mira", "Dialogue should target Mira")
 assert(game.call("_villager_dialogue", "Mira") != "", "Mira should have dialogue text")
 var key_event := InputEventKey.new()
 key_event.keycode = KEY_E
 key_event.pressed = true
 game.call("_input", key_event)
 assert(game.get("villager_quests")["Mira"] == "active", "Mira's task should accept")
 assert(game.get("screen") == "game", "Accepting by keyboard should close dialogue")
 game.set("screen", "villager_dialogue")
 game.set("talking_to", "Mira")
 game.call("_advance_villager_task")
 assert(game.get("villager_quests")["Mira"] == "active", "Insufficient items must not complete a task")
 game.get("inventory")["Forest Herb"] = 2
 var gold_before: int = game.get("gold")
 key_event = InputEventKey.new()
 key_event.keycode = KEY_E
 key_event.pressed = true
 game.call("_input", key_event)
 assert(game.get("villager_quests")["Mira"] == "complete", "Mira's task should turn in")
 assert(game.get("inventory")["Forest Herb"] == 0, "Turn-in should consume requested herbs")
 assert(game.get("gold") == gold_before + 15, "Mira's reward should be granted")
 var tomas_pos: Vector2 = game.get("villagers")[1]["pos"]
 game.set("hero", tomas_pos)
 game.set("screen", "game")
 assert(game.call("_nearest") == "Tomas", "Tomas should be the nearest interaction")
 game.call("_interact")
 game.call("_advance_villager_task")
 assert(game.get("villager_quests")["Tomas"] == "active", "Tomas's task should accept")
 game.get("inventory")["Oak Wood"] = 2
 game.set("hero", game.get("villagers")[1]["pos"])
 game.set("screen", "game")
 game.call("_interact")
 game.call("_advance_villager_task")
 assert(game.get("villager_quests")["Tomas"] == "complete", "Tomas's task should turn in")
 assert(game.get("inventory")["Oak Wood"] == 0, "Turn-in should consume requested wood")
 game.call("_save")
 game.call("_reset_villager_quests")
 game.call("_load")
 assert(game.get("villager_quests")["Mira"] == "complete", "Mira's completed task should persist")
 assert(game.get("villager_quests")["Tomas"] == "complete", "Tomas's completed task should persist")
 print("VILLAGER_FETCH_TASK_TEST=PASS")
 quit()
