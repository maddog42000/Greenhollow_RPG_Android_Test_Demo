extends SceneTree

func _initialize():
 call_deferred("_run")

func _run():
 var game = load("res://scenes/main.tscn").instantiate()
 root.add_child(game)
 await process_frame
 game.set("screen", "inventory")
 game.set("hp", 50)
 game.get("inventory")["Small Health Potion"] = 2
 game.call("_tap", Vector2(300,525))
 assert(game.get("inventory")["Small Health Potion"] == 1, "Potion action should consume one potion")
 assert(game.get("hp") == 85, "Potion action should restore 35 HP")
 game.get("inventory")["Forest Herb"] = 1
 game.set("quest_active", true)
 game.set("quest_kills", 1)
 game.get("villager_quests")["Mira"] = "active"
 game.get("villager_quests")["Tomas"] = "complete"
 assert(game.call("_elder_quest_status").contains("1 / 3"), "Elder progress should show in the journal")
 assert(game.call("_villager_task_progress_for", "Mira").contains("1 / 2"), "Mira task progress should show in the journal")
 assert(game.call("_villager_task_progress_for", "Tomas").begins_with("Completed"), "Completed tasks should be labeled")
 game.call("_tap", Vector2(640,610))
 assert(game.get("screen") == "game", "Back button should return to the game")
 print("INVENTORY_SMOKE_TEST=PASS")
 quit()
