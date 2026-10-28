extends SceneTree

const WaveDirector = preload("res://scripts/wave_director.gd")

func _initialize():
 call_deferred("_run")

func _run():
 var director = WaveDirector.new()
 director.start_run()
 assert(director.wave_number == 1 and director.phase == "warning", "Run should begin with wave-one warning")
 assert(director.tick(2.9, 0).is_empty(), "Wave should not start before countdown ends")
 assert(director.tick(0.2, 0)["event"] == "wave_started", "Wave should start when warning expires")
 assert(director.total_enemies == 10 and director.enemies_to_spawn == 10, "Wave one should target ten enemies")
 var first_batch:Dictionary = director.tick(0.0, 0)
 assert(first_batch["event"] == "spawn_batch" and first_batch["spawn_count"] == 3, "Spawning should occur in bounded batches")
 assert(director.remaining_total(3) == 10, "Remaining total includes queued and living enemies")
 var spawned:int = int(first_batch["spawn_count"])
 var batches:int = 1
 while director.enemies_to_spawn > 0:
  var event:Dictionary = director.tick(1.0, spawned)
  if event.get("event", "") == "spawn_batch":
   var count:int = int(event["spawn_count"])
   assert(count > 0 and count <= 3, "Each batch must be bounded and positive")
   spawned += count
   batches += 1
 assert(batches == 4 and spawned == 10, "Wave one should emit four deterministic batches")
 assert(director.tick(0.0, spawned).is_empty(), "Wave must not clear while spawned enemies remain alive")
 assert(director.tick(0.0, 1).is_empty(), "One remaining living enemy must prevent completion")
 assert(director.tick(0.0, 0)["event"] == "wave_cleared", "Wave clears after queue and living enemies are both empty")
 assert(director.phase == "pause" and is_equal_approx(director.timer, 4.0), "Clear should start a four-second pause")
 assert(director.tick(3.9, 0).is_empty(), "Pause should not finish early")
 assert(director.tick(0.1, 0)["event"] == "next_wave", "First cleared wave advances after pause")
 assert(director.wave_number == 2 and director.phase == "warning" and is_equal_approx(director.timer, 3.0), "Next wave gets one three-second warning")
 assert(director.wave_spec(2)["count"] == 14 and director.wave_spec(3)["count"] == 19, "Opening wave targets should be 10, 14, 19")
 assert(bool(director.wave_spec(5)["elite"]) and not bool(director.wave_spec(5)["boss"]), "Wave five should be elite")
 assert(bool(director.wave_spec(10)["elite"]) and bool(director.wave_spec(10)["boss"]), "Wave ten should be both elite and boss")
 var late_spec:Dictionary = director.wave_spec(1000)
 assert(late_spec["count"] == 50, "Enemy count should cap at fifty")
 assert(late_spec["health_scale"] <= 4.0 and late_spec["damage_scale"] <= 2.5 and late_spec["speed_scale"] <= 1.5, "All scaling should be bounded")
 director.wave_number = 2
 director.phase = "pause"
 director.timer = 4.0
 assert(director.tick(4.0, 0)["event"] == "checkpoint", "Every second cleared wave should reach checkpoint")
 assert(director.phase == "checkpoint", "Checkpoint waits for explicit continuation")
 director.continue_after_checkpoint()
 assert(director.wave_number == 3 and director.phase == "warning" and is_equal_approx(director.timer, 3.0), "Continue advances exactly one wave with warning")
 director.continue_after_checkpoint()
 assert(director.wave_number == 3, "Continue outside checkpoint must not advance")
 director.wave_number = 5
 director.phase = "pause"
 director.timer = 0.0
 assert(director.tick(0.0, 0)["event"] == "checkpoint", "Elite/boss milestone clears also checkpoint")
 print("WAVE_DIRECTOR_SMOKE_TEST=PASS")
 quit()
