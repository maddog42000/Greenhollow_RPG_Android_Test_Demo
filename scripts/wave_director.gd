extends RefCounted

const SPAWN_INTERVAL := 1.0
const SPAWN_BATCH_SIZE := 3
const CLEAR_PAUSE := 4.0
const MAX_ENEMIES := 50

var wave_number:int = 0
var phase:String = "idle"
var timer:float = 0.0
var enemies_to_spawn:int = 0
var total_enemies:int = 0

func reset():
 wave_number = 0
 phase = "idle"
 timer = 0.0
 enemies_to_spawn = 0
 total_enemies = 0

func start_run(first_countdown:float=3.0):
 wave_number = 1
 _prepare_wave(maxf(0.0, first_countdown))

func _prepare_wave(countdown:float):
 var spec:Dictionary = wave_spec(wave_number)
 total_enemies = int(spec["count"])
 enemies_to_spawn = total_enemies
 timer = countdown
 phase = "warning"

func tick(delta:float, living_enemies:int)->Dictionary:
 var step:float = maxf(0.0, delta)
 if phase == "warning":
  timer = maxf(0.0, timer - step)
  if timer <= 0.000001:
   phase = "spawning"
   timer = 0.0
   return {"event":"wave_started", "wave":wave_number}
  return {}
 if phase == "spawning":
  timer -= step
  if enemies_to_spawn > 0 and timer <= 0.000001:
   var spawn_count:int = mini(SPAWN_BATCH_SIZE, enemies_to_spawn)
   enemies_to_spawn -= spawn_count
   timer = SPAWN_INTERVAL
   return {"event":"spawn_batch", "spawn_count":spawn_count, "wave":wave_number}
  if enemies_to_spawn == 0 and living_enemies <= 0:
   phase = "pause"
   timer = CLEAR_PAUSE
   return {"event":"wave_cleared", "wave":wave_number}
  return {}
 if phase == "pause":
  timer = maxf(0.0, timer - step)
  if timer <= 0.000001:
   if wave_number % 2 == 0 or wave_number % 5 == 0:
    phase = "checkpoint"
    return {"event":"checkpoint", "wave":wave_number}
   _advance_wave()
   return {"event":"next_wave", "wave":wave_number}
  return {}
 return {}

func continue_after_checkpoint():
 if phase != "checkpoint":
  return
 _advance_wave()

func _advance_wave():
 wave_number += 1
 _prepare_wave(3.0)

func wave_spec(wave:int)->Dictionary:
 var safe_wave:int = maxi(1, wave)
 var count:int
 if safe_wave == 1:
  count = 10
 elif safe_wave == 2:
  count = 14
 elif safe_wave == 3:
  count = 19
 else:
  count = mini(MAX_ENEMIES, 19 + (safe_wave - 3) * 5)
 var boss:bool = safe_wave % 10 == 0
 var elite:bool = safe_wave % 5 == 0
 return {
  "count":count,
  "elite":elite,
  "boss":boss,
  "health_scale":clampf(1.0 + float(safe_wave - 1) * 0.12, 1.0, 4.0),
  "damage_scale":clampf(1.0 + float(safe_wave - 1) * 0.08, 1.0, 2.5),
  "speed_scale":clampf(1.0 + float(safe_wave - 1) * 0.025, 1.0, 1.5),
  "interval":SPAWN_INTERVAL
 }

func remaining_total(living_enemies:int)->int:
 return maxi(0, enemies_to_spawn + living_enemies)
