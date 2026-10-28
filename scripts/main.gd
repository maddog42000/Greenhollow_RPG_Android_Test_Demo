extends Node2D

const CLASSES = {
 "warrior":{"hp":140,"mp":35,"damage":18,"speed":175,"color":Color("#526e86")},
 "ranger":{"hp":95,"mp":65,"damage":15,"speed":205,"color":Color("#496d4a")},
 "mage":{"hp":80,"mp":130,"damage":22,"speed":165,"color":Color("#58487e")},
 "rogue":{"hp":90,"mp":50,"damage":17,"speed":225,"color":Color("#643c49")}
}
const LEVELUP_ATTACKS := {
 "Whirlwind":{"icon":"warrior","mode":"aoe","reach":132.0,"damage":1.6,"targets":99,"cost":10,"cooldown":4.0,"description":"Spin through every nearby foe."},
 "Volley":{"icon":"ranger","mode":"multi","reach":245.0,"damage":1.0,"targets":3,"cost":10,"cooldown":3.0,"description":"Strike up to three distant foes."},
 "Arcane Burst":{"icon":"mage","mode":"aoe","reach":185.0,"damage":1.35,"targets":99,"cost":13,"cooldown":4.5,"description":"Blast a wide circle with arcane force."},
 "Shadow Strike":{"icon":"rogue","mode":"single","reach":205.0,"damage":2.4,"targets":1,"cost":11,"cooldown":3.7,"description":"Deal heavy damage to one nearby foe."}
}
const SAVE_PATH = "user://greenhollow_save.json"
const DAY_CYCLE_SECONDS := 240.0
const WaveDirector = preload("res://scripts/wave_director.gd")
const UpgradeCatalog = preload("res://scripts/upgrade_catalog.gd")
const CLASS_COMBAT := {
 "warrior":{"style":"melee","range":104.0,"interval":0.72,"damage":1.15,"projectile_speed":0.0},
 "ranger":{"style":"arrow","range":320.0,"interval":0.90,"damage":0.82,"projectile_speed":520.0},
 "mage":{"style":"orb","range":285.0,"interval":1.10,"damage":1.0,"projectile_speed":400.0},
 "rogue":{"style":"melee","range":128.0,"interval":0.48,"damage":0.78,"projectile_speed":0.0}
}
const ENEMY_PROFILES := {
 "slime":{"hp":34,"damage":6,"xp":10,"speed":82.0,"role":"swarm","texture":"slime","radius":22.0},
 "wolf":{"hp":52,"damage":10,"xp":16,"speed":126.0,"role":"stalker","texture":"wolf","radius":24.0},
 "bandit":{"hp":68,"damage":9,"xp":22,"speed":58.0,"role":"ranged","texture":"bandit","radius":25.0,"range":240.0},
 "brute":{"hp":132,"damage":18,"xp":32,"speed":48.0,"role":"brute","texture":"bandit","radius":32.0},
 "archer":{"hp":58,"damage":12,"xp":25,"speed":68.0,"role":"ranged","texture":"bandit","radius":23.0,"range":310.0},
 "boss":{"hp":640,"damage":23,"xp":160,"speed":45.0,"role":"boss","texture":"wolf","radius":49.0,"range":95.0}
}
const RUN_STAT_DEFAULTS := {"damage_flat":0.0,"damage_pct":0.0,"attack_speed_pct":0.0,"attack_range_pct":0.0,"crit_chance":0.05,"crit_damage":1.5,"projectile_count":0,"projectile_pierce":0,"max_hp":0.0,"armor":0.0,"damage_reduction":0.0,"regen":0.0,"dodge_chance":0.0,"move_speed_pct":0.0,"xp_gain_pct":0.0,"pickup_magnet":124.0,"gold_bonus":0.0,"item_bonus":0.0,"healing_bonus":0.0,"lifesteal":0.0}
var screen := "title"
var hero_class := "warrior"
var hero_name := "Adventurer"
var hero := Vector2(640,380)
var move_vec := Vector2.ZERO
var joy_center := Vector2(110,600)
var joy_knob := Vector2(110,600)
var joy_id := -1
var level := 1
var xp := 0
var xp_next := 50
var skill_points := 0
var gold := 25
var hp := 100
var mp := 50
var kills := 0
var quest_active := false
var quest_kills := 0
var hardcore := false
var inventory := {"Small Health Potion":2,"Forest Herb":0,"Rough Ore":0,"Oak Wood":0}
var attack_slots:Array[String]=[]
var attack_ranks:Dictionary={}
var attack_cooldowns:Dictionary={}
var levelup_options:Array[Dictionary]=[]
var pending_levelup_count:=0
var levelup_return_screen:="game"
var xp_pickups:Array[Dictionary]=[]
var best_depth:=0
var runs_completed:=0
var runs_lost:=0
var best_wave:=0
var wave_director=WaveDirector.new()
var upgrade_catalog=UpgradeCatalog.new()
var run_stats:Dictionary=RUN_STAT_DEFAULTS.duplicate(true)
var upgrade_ranks:Dictionary={}
var mastery_bonus_damage:=0
var projectiles:Array[Dictionary]=[]
var next_enemy_uid:=1
var auto_attack_timer:=0.0
var passive_timer:=0.0
var home_return_opportunity:=false
var pending_return_chance:=0.0
var at_home_intermission:=false
var run_death_summary:=""
var pointer_pos:=Vector2(-1000,-1000)
var active_attack_id:=""
var enemies:Array[Dictionary] = []
var villagers:Array[Dictionary] = []
var talking_to := ""
var villager_quests:Dictionary = {"Mira":"available","Tomas":"available"}
var floats:Array[Dictionary] = []
var notice := "Welcome to Greenhollow."
var notice_time := 3.0
var last_attack := 0.0
var attack_flash := 0.0
var skill_cooldown := 0.0
var unlocked_skills: Array[String] = []
var selected_skill := ""
var skill_flash := 0.0
var levelup_time := 0.0
var spawn_timer := 0.0
var encounter_active := false
var previous_in_wilds := false
var area_id := "village"
var transition_flash := 0.0
var walk_clock := 0.0
var world_anim_clock := 0.0
var hero_is_moving := false
var combat_engaged := false
var expedition_active:=false
var expedition_depth:=0
var expedition_loot:Dictionary={"gold":0,"Forest Herb":0,"Rough Ore":0,"Oak Wood":0}
var waystone_built:=false
const GRASS := preload("res://assets/world/grass.png")
const DIRT := preload("res://assets/world/dirt.png")
const STONE := preload("res://assets/world/stone.png")
const TREE := preload("res://assets/original_art_pass/oak_tree.png")
const PINE := preload("res://assets/original_art_pass/pine_tree.png")
const AUTUMN_TREE := preload("res://assets/original_art_pass/autumn_tree.png")
const COTTAGE := preload("res://assets/original_art_pass/cottage.png")
const MANOR := preload("res://assets/original_art_pass/manor.png")
const MARKET := preload("res://assets/original_art_pass/market_stall.png")
const WELL := preload("res://assets/original_art_pass/well.png")
const CAMPFIRE := preload("res://assets/original_art_pass/campfire.png")
const RUIN_ARCH := preload("res://assets/original_art_pass/ruin_arch.png")
const COBBLE := preload("res://assets/world/cobble.png")
const MOSS := preload("res://assets/world/moss.png")
const SAND := preload("res://assets/world/sand.png")
const PIXEL_ART := preload("res://assets/user_art/greenhollow_sprite_atlas.png")
const CHARACTER_FRAME_LAYOUT := {
 "warrior":{"x":18,"walk_y":670,"attack_y":740,"step":58,"width":58,"height":68},
 "ranger":{"x":280,"walk_y":670,"attack_y":740,"step":61,"width":61,"height":68},
 "mage":{"x":548,"walk_y":670,"attack_y":740,"step":62,"width":62,"height":68},
 "rogue":{"x":819,"walk_y":670,"attack_y":740,"step":58,"width":58,"height":68}
}
const HERO_PORTRAITS := {"warrior": preload("res://assets/characters/warrior/warrior.png"), "ranger": preload("res://assets/characters/ranger/ranger.png"), "mage": preload("res://assets/characters/mage/mage.png"), "rogue": preload("res://assets/characters/rogue/rogue.png")}
const SKILL_ICONS := {"warrior": preload("res://assets/skills/whirlwind.png"), "ranger": preload("res://assets/skills/volley.png"), "mage": preload("res://assets/skills/arcane_burst.png"), "rogue": preload("res://assets/skills/shadow_strike.png")}
const ENEMY_TEXTURES := {"slime": preload("res://assets/enemies/slime.png"), "wolf": preload("res://assets/enemies/wolf.png"), "bandit": preload("res://assets/enemies/bandit.png")}
var settings := {"sfx":true,"music":true,"large_text":false}
var time_of_day := 0.42

func _ready():
 randomize()
 _reset_villagers()
 _reset_villager_quests()
 var launch_args := OS.get_cmdline_user_args()
 if launch_args.has("--demo") or launch_args.has("--night-demo") or launch_args.has("--quest-demo") or launch_args.has("--inventory-demo") or launch_args.has("--forest-demo") or launch_args.has("--levelup-demo") or launch_args.has("--skills-demo") or launch_args.has("--skillfx-demo") or launch_args.has("--walk-demo") or launch_args.has("--choices-demo") or launch_args.has("--expedition-demo") or launch_args.has("--workshop-demo") or launch_args.has("--progression-demo"):
  hero_class = "ranger"
  for demo_class in ["warrior","ranger","mage","rogue"]:
   if launch_args.has("--class-"+demo_class): hero_class=demo_class
  _start()
  if launch_args.has("--night-demo"):
   time_of_day = 0.94
  if launch_args.has("--quest-demo"):
   hero = villagers[0]["pos"]
   _interact()
  if launch_args.has("--inventory-demo"):
   inventory["Forest Herb"]=1
   quest_active=true; quest_kills=1
   villager_quests["Mira"]="active"
   villager_quests["Tomas"]="complete"
   screen="inventory"
  if launch_args.has("--forest-demo"):
   _change_area("forest",Vector2(640,380))
  if launch_args.has("--levelup-demo"):
   level=2; skill_points=1; hp=CLASSES[hero_class].hp+10; mp=CLASSES[hero_class].mp+5; levelup_time=3.5
  if launch_args.has("--skills-demo"):
   level=2; skill_points=1; screen="skills"
  if launch_args.has("--skillfx-demo"):
   level=2; unlocked_skills.append(_class_skill_name()); area_id="forest"; hero=Vector2(640,380)
   enemies.clear(); _spawn("slime",hero+Vector2(92,-10)); _spawn("wolf",hero+Vector2(-105,22))
   encounter_active=true; combat_engaged=true; _use_skill()
  if launch_args.has("--walk-demo"):
   move_vec=Vector2(0.72,0.28)
  if launch_args.has("--choices-demo"):
   screen="game"; xp=xp_next; _level_check()
  if launch_args.has("--expedition-demo"):
   level=3; hp=CLASSES[hero_class].hp+20; mp=CLASSES[hero_class].mp+10
   _change_area("forest",Vector2(640,380))
   expedition_depth=4
   expedition_loot={"gold":42,"Forest Herb":2,"Rough Ore":1,"Oak Wood":1}
   attack_slots.assign(["Whirlwind","Volley","Arcane Burst"])
   attack_ranks={"Whirlwind":1,"Volley":2,"Arcane Burst":1}
   _spawn_expedition_room(); encounter_active=true; combat_engaged=true
  if launch_args.has("--progression-demo"):
   level=2; hp=CLASSES[hero_class].hp+10; mp=CLASSES[hero_class].mp+5
   _change_area("forest",Vector2(640,380))
   expedition_depth=2; best_depth=4; xp=42; xp_next=55
   xp_pickups.append({"pos":hero+Vector2(245,-4),"xp":13,"phase":0.6})
   attack_slots.assign(["Volley"]); attack_ranks={"Volley":1}
   _spawn("slime",hero+Vector2(185,-80)); _spawn("wolf",hero+Vector2(-205,70))
   encounter_active=true; combat_engaged=launch_args.has("--walk-demo")
  if launch_args.has("--workshop-demo"):
   gold=75
   inventory={"Small Health Potion":1,"Forest Herb":3,"Rough Ore":5,"Oak Wood":4}
   screen="shop"
   _say("Workshop preview • buy, craft, or build before you venture out.")

func _process(delta):
 world_anim_clock+=delta
 notice_time=maxf(0,notice_time-delta)
 last_attack=maxf(0,last_attack-delta)
 attack_flash=maxf(0.0,attack_flash-delta)
 skill_cooldown=maxf(0.0,skill_cooldown-delta)
 for attack_id in attack_cooldowns.keys():
  attack_cooldowns[attack_id]=maxf(0.0,float(attack_cooldowns[attack_id])-delta)
 skill_flash=maxf(0.0,skill_flash-delta)
 levelup_time=maxf(0.0,levelup_time-delta)
 transition_flash=maxf(0.0,transition_flash-delta)
 if screen=="game": time_of_day=fposmod(time_of_day+delta/DAY_CYCLE_SECONDS,1.0)
 for floating_text in floats:
  floating_text.time-=delta
  floating_text.pos.y-=25*delta
 floats=floats.filter(func(item): return item.time>0)
 if screen=="game":
  var velocity:=move_vec
  if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT): velocity.x-=1
  if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT): velocity.x+=1
  if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP): velocity.y-=1
  if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN): velocity.y+=1
  if velocity.length()>1: velocity=velocity.normalized()
  hero_is_moving=velocity.length()>0.05
  if hero_is_moving: walk_clock+=delta
  var speed_mult:=1.0+float(run_stats.get("move_speed",0.0))
  hero+=velocity*float(CLASSES[hero_class].speed)*speed_mult*delta
  if hero.x<24.0:
   var left_map:Dictionary={"village":"west","west":"ruins","ruins":"forest","forest":"village","north":"west","south":"west"}
   _change_area(str(left_map.get(area_id,"village")),Vector2(1215,hero.y))
  elif hero.x>1256.0:
   var right_map:Dictionary={"village":"forest","west":"village","forest":"ruins","ruins":"west","north":"forest","south":"forest"}
   _change_area(str(right_map.get(area_id,"village")),Vector2(65,hero.y))
  elif hero.y<90.0:
   var up_map:Dictionary={"village":"north","north":"north","south":"village","west":"north","forest":"north","ruins":"forest"}
   _change_area(str(up_map.get(area_id,"village")),Vector2(hero.x,665))
  elif hero.y>690.0:
   var down_map:Dictionary={"village":"south","south":"south","north":"village","west":"south","forest":"ruins","ruins":"south"}
   _change_area(str(down_map.get(area_id,"village")),Vector2(hero.x,125))
  hero.x=clampf(hero.x,18,1262); hero.y=clampf(hero.y,80,700)
  var in_wilds:bool=(area_id in ["forest","ruins"] or expedition_active) and area_id!="village" and Rect2(40,80,1200,610).has_point(hero)
  if in_wilds and not previous_in_wilds and not expedition_active:
   encounter_active=true
   if enemies.is_empty():
    _spawn("slime",Vector2(clampf(hero.x+125,70,1200),clampf(hero.y+20,120,650)))
    _spawn("wolf",Vector2(clampf(hero.x-120,70,1200),clampf(hero.y+90,120,650)))
   _say("Whisperwood: attack to engage the creatures, or retreat to an exit.")
  elif not in_wilds and previous_in_wilds and not expedition_active:
   encounter_active=false; enemies.clear(); projectiles.clear()
   _say("You escaped to safety.")
  previous_in_wilds=in_wilds
  if area_id=="village": _update_villagers(delta)
  if expedition_active and area_id!="village":
   _update_wave_director(delta)
   if screen=="game":
    _update_auto_attacks(delta)
    _update_projectiles(delta)
    _update_enemies(delta)
    _update_xp_pickups(delta)
    _update_run_regeneration(delta)
  elif encounter_active and combat_engaged:
   _update_enemies(delta)
   _update_projectiles(delta)
 queue_redraw()

func _homeward_chance()->float:
 var current_wave:=maxi(1,int(wave_director.wave_number))
 var chance:=0.20 if current_wave<=4 else (0.17 if current_wave<=8 else 0.15)
 if waystone_built: chance+=0.08
 return clampf(chance,0.05,0.40)

func _begin_expedition():
 if expedition_active: return
 expedition_active=true
 expedition_depth=0
 expedition_loot={"gold":0,"Forest Herb":0,"Rough Ore":0,"Oak Wood":0}
 xp_pickups.clear(); projectiles.clear(); at_home_intermission=false
 home_return_opportunity=false
 wave_director.start_run(3.0)
 encounter_active=true; combat_engaged=true; auto_attack_timer=0.35
 _say("Expedition begins • first wave in 3 seconds. Auto-attacks are active.")

func _bank_expedition()->String:
 if not expedition_active: return "No active expedition to bank."
 var reached_depth:=expedition_depth
 var loot:Dictionary=expedition_loot.duplicate(true)
 var banked_gold:=maxi(0,int(loot.get("gold",0)))
 gold+=banked_gold
 var banked_supplies:Array[String]=[]
 for supply in ["Forest Herb","Rough Ore","Oak Wood"]:
  var amount:=maxi(0,int(loot.get(supply,0)))
  if amount>0:
   inventory[supply]=int(inventory.get(supply,0))+amount
   banked_supplies.append("%d %s" % [amount,supply])
 expedition_loot={"gold":0,"Forest Herb":0,"Rough Ore":0,"Oak Wood":0}
 runs_completed+=1
 best_depth=maxi(best_depth,reached_depth)
 expedition_active=false
 expedition_depth=0
 wave_director.reset()
 enemies.clear(); projectiles.clear(); xp_pickups.clear()
 encounter_active=false; combat_engaged=false; previous_in_wilds=false
 at_home_intermission=true; home_return_opportunity=false
 var supply_text=", ".join(banked_supplies) if not banked_supplies.is_empty() else "no supplies"
 return "Safe return • banked %dG, %s. Your build is preserved; choose when to venture out again." % [banked_gold,supply_text]

func _lose_expedition()->String:
 if not expedition_active: return ""
 var lost_depth:=expedition_depth
 var lost_gold:=int(expedition_loot.get("gold",0))
 var lost_supplies:=int(expedition_loot.get("Forest Herb",0))+int(expedition_loot.get("Rough Ore",0))+int(expedition_loot.get("Oak Wood",0))
 var lost_xp:=_xp_pickup_total()
 best_depth=maxi(best_depth,lost_depth)
 best_wave=maxi(best_wave,int(wave_director.wave_number))
 expedition_active=false; runs_lost+=1; expedition_depth=0
 expedition_loot={"gold":0,"Forest Herb":0,"Rough Ore":0,"Oak Wood":0}
 enemies.clear(); projectiles.clear(); xp_pickups.clear()
 encounter_active=false; combat_engaged=false; previous_in_wilds=false
 home_return_opportunity=false; at_home_intermission=false; wave_director.reset()
 return "Run ended at wave %d • lost unbanked %dG, %d supplies and %d uncollected XP." % [best_wave,lost_gold,lost_supplies,lost_xp]

func _reset_temporary_build():
 level=1; xp=0; xp_next=50; skill_points=0
 attack_slots.clear(); attack_ranks.clear(); attack_cooldowns.clear()
 upgrade_ranks.clear(); mastery_bonus_damage=0; run_stats=RUN_STAT_DEFAULTS.duplicate(true)
 pending_levelup_count=0; levelup_options.clear(); levelup_time=0.0
 unlocked_skills.clear(); selected_skill=""; skill_cooldown=0.0
 hp=CLASSES[hero_class].hp; mp=CLASSES[hero_class].mp
 auto_attack_timer=0.0; passive_timer=0.0; projectiles.clear()

func _end_run_on_death():
 run_death_summary=_lose_expedition()
 _reset_temporary_build()
 area_id="village"; hero=Vector2(640,380); screen="death"
 _say(run_death_summary+" A new expedition starts with your class's normal loadout.")

func _return_to_village():
 if not expedition_active or not home_return_opportunity: return
 var bank_message:=_bank_expedition()
 area_id="village"; hero=Vector2(640,380); screen="game"
 _say(bank_message)

func _continue_expedition():
 if not expedition_active or not home_return_opportunity: return
 home_return_opportunity=false
 expedition_depth+=1
 screen="game"
 wave_director.continue_after_checkpoint()
 at_home_intermission=false
 _say("Press on • wave %d incoming. Your current haul remains at risk." % wave_director.wave_number)

func _spawn_expedition_room():
 # Legacy preview/test hook now delegates to the wave pack; production uses WaveDirector.
 var spec:Dictionary=wave_director.wave_spec(maxi(1,wave_director.wave_number))
 _spawn_wave_pack(int(spec.get("count",10)),spec)

func _change_area(next_area:String,next_pos:Vector2,route_roll_override:float=-1.0):
 if next_area not in ["village","forest","north","south","west","ruins"]: return
 if next_area==area_id and not expedition_active:
  hero=Vector2(clampf(next_pos.x,24,1256),clampf(next_pos.y,90,690)); return
 if expedition_active and area_id!="village":
  if wave_director.phase=="spawning" or not enemies.is_empty():
   hero.x=clampf(hero.x,35.0,1245.0); hero.y=clampf(hero.y,100.0,680.0)
   _say("Finish the active wave before crossing to another area.")
   return
  if route_roll_override>=0.0:
   var test_roll:=clampf(route_roll_override,0.0,1.0)
   if test_roll<_homeward_chance():
    home_return_opportunity=true; _return_to_village(); return
   expedition_depth+=1
   best_depth=maxi(best_depth,expedition_depth)
   var choices:Array[String]=["forest","north","south","west","ruins"]
   choices.erase(area_id)
   if choices.is_empty(): choices=["forest","north","south","west","ruins"]
   next_area=choices.pick_random()
   _say("Checkpoint test roll missed • depth %d." % expedition_depth)
 if next_area=="village" and expedition_active:
  hero.x=clampf(hero.x,35.0,1245.0); hero.y=clampf(hero.y,100.0,680.0)
  _say("A direct road home is sealed. Look for a village route at a wave checkpoint.")
  return
 var starting_run:=not expedition_active and next_area!="village" and area_id=="village"
 if starting_run: _begin_expedition()
 if area_id=="village" and expedition_active and next_area!="village" and at_home_intermission:
  at_home_intermission=false
  expedition_depth+=1
  best_depth=maxi(best_depth,expedition_depth)
  wave_director.continue_after_checkpoint()
 var abandoned_xp:=_xp_pickup_total()
 if expedition_active and abandoned_xp>0: xp_pickups.clear()
 area_id=next_area
 hero=Vector2(clampf(next_pos.x,35.0,1245.0),clampf(next_pos.y,100.0,680.0))
 projectiles.clear()
 encounter_active=expedition_active and area_id!="village"
 combat_engaged=encounter_active
 previous_in_wilds=false
 transition_flash=0.45
 var area_name:String={"village":"Greenhollow Village • Safe sanctuary","forest":"Whisperwood Forest","north":"Northwatch Trail","south":"The Old Road","west":"Mossy Crossing","ruins":"Sunken Ruins"}.get(area_id,"Greenhollow")
 if abandoned_xp>0: _say("Entered %s • left %d uncollected XP behind." % [area_name,abandoned_xp])
 else: _say("Entered %s • wave %d progress preserved." % [area_name,int(wave_director.wave_number)])

func _random_spawn_position()->Vector2:
 var direction:=Vector2.RIGHT.rotated(randf_range(0.0,TAU))
 var distance:=randf_range(370.0,480.0)
 var candidate:=hero+direction*distance
 candidate.x=clampf(candidate.x,64.0,1216.0); candidate.y=clampf(candidate.y,112.0,668.0)
 if candidate.distance_to(hero)<245.0:
  candidate=hero-direction*320.0
  candidate.x=clampf(candidate.x,64.0,1216.0); candidate.y=clampf(candidate.y,112.0,668.0)
 return candidate

func _enemy_kind_for_wave(wave:int)->String:
 var pool:Array[String]=["slime"]
 if wave>=2: pool.append("wolf")
 if wave>=3: pool.append("bandit")
 if wave>=5: pool.append("brute")
 if wave>=7: pool.append("archer")
 if area_id=="ruins" and wave>=4: pool=["bandit","brute","archer"]
 return pool.pick_random()

func _spawn_wave_pack(requested_count:int,spec:Dictionary):
 var count:=clampi(requested_count,1,50)
 var boss_count:=1 if bool(spec.get("boss",false)) else 0
 var elite_count:=1 if bool(spec.get("elite",false)) and boss_count==0 else 0
 for i in range(maxi(0,count-boss_count-elite_count)):
  if enemies.size()>=54: break
  _spawn(_enemy_kind_for_wave(int(wave_director.wave_number)),_random_spawn_position(),false,false,spec)
 if elite_count>0 and enemies.size()<54:
  _spawn(_enemy_kind_for_wave(int(wave_director.wave_number)),_random_spawn_position(),true,false,spec)
 if boss_count>0 and enemies.size()<54:
  _spawn("boss",_random_spawn_position(),false,true,spec)

func _spawn(kind:String,p:Vector2,elite:bool=false,boss:bool=false,wave_spec:Dictionary={}):
 if enemies.size()>=55: return
 var data:Dictionary=ENEMY_PROFILES.get(kind,ENEMY_PROFILES["slime"])
 var wave_health:=float(wave_spec.get("health_scale",1.0))
 var wave_damage:=float(wave_spec.get("damage_scale",1.0))
 var depth_health:=1.0+minf(float(expedition_depth)*0.035,0.8)
 var depth_damage:=1.0+minf(float(expedition_depth)*0.025,0.6)
 var special_health:=4.5 if boss else (1.75 if elite else 1.0)
 var special_damage:=1.65 if boss else (1.35 if elite else 1.0)
 var hp_value:=maxi(1,int(round(float(data["hp"])*wave_health*depth_health*special_health)))
 var damage_value:=maxi(1,int(round(float(data["damage"])*wave_damage*depth_damage*special_damage)))
 var xp_value:=maxi(1,int(round(float(data["xp"])*(1.0+minf(float(expedition_depth)*0.05,0.8))*(1.8 if boss else (1.45 if elite else 1.0)))))
 var speed_value:float=float(data["speed"])*float(wave_spec.get("speed_scale",1.0))*(1.08 if elite else 1.0)
 next_enemy_uid+=1
 enemies.append({"uid":next_enemy_uid,"kind":kind,"role":str(data["role"]),"texture":str(data["texture"]),"pos":p,"hp":hp_value,"max_hp":hp_value,"damage":damage_value,"xp":xp_value,"speed":speed_value,"radius":float(data["radius"])+(17.0 if boss else (6.0 if elite else 0.0)),"attack_range":float(data.get("range",float(data["radius"])+12.0)),"attack_timer":randf_range(0.3,1.1),"windup":0.0,"windup_pos":p,"elite":elite,"boss":boss})

func _update_wave_director(delta:float):
 if not expedition_active or area_id=="village" or screen!="game": return
 var result:Dictionary=wave_director.tick(delta,enemies.size())
 var event_name:=str(result.get("event",""))
 var spawn_count:=int(result.get("spawn_count",0))
 if event_name=="wave_started":
  encounter_active=true; combat_engaged=true
  var current:=int(wave_director.wave_number)
  var spec:Dictionary=wave_director.wave_spec(current)
  var warning:="WAVE %d • %d foes" % [current,int(spec.get("count",0))]
  if bool(spec.get("elite",false)): warning+=" • ELITE"
  if bool(spec.get("boss",false)): warning+=" • BOSS"
  _say(warning)
 elif event_name=="wave_cleared":
  best_wave=maxi(best_wave,int(wave_director.wave_number))
  var recovery:=maxi(1,int(round(_hero_max_hp()*0.06)))
  hp=mini(_hero_max_hp(),hp+recovery)
  _float(hero+Vector2(0,-48),"WAVE CLEAR • +%d HP" % recovery,Color("#a9edc0"))
  _say("Wave %d clear • breathe and recover." % int(wave_director.wave_number))
 elif event_name=="checkpoint":
  var checkpoint_wave:=int(wave_director.wave_number)
  expedition_depth=maxi(expedition_depth,int(ceil(float(checkpoint_wave)/2.0)))
  best_depth=maxi(best_depth,expedition_depth)
  pending_return_chance=_homeward_chance()+float(run_stats.get("homeward_bonus",0.0))
  pending_return_chance=clampf(pending_return_chance,0.05,0.45)
  if randf()<pending_return_chance:
   home_return_opportunity=true
   screen="home_route"
   _say("A trail home has appeared at this checkpoint.")
   return
  expedition_depth+=1
  wave_director.continue_after_checkpoint()
  _say("No trail home this time • continuing to wave %d." % int(wave_director.wave_number))
 elif event_name=="next_wave":
  var next_wave:=int(wave_director.wave_number)
  if next_wave==5 or next_wave%5==0:
   var at_risk:=int(expedition_loot.get("gold",0))
   _say("Danger warning • Wave %d elite ahead; %dG unbanked is at risk." % [next_wave,at_risk])
  elif next_wave==10 or next_wave%10==0:
   _say("BOSS WARNING • Wave %d • %dG haul at risk." % [next_wave,int(expedition_loot.get("gold",0))])
  else:
   _say("Wave %d incoming." % next_wave)
 if spawn_count>0:
  var current_wave:=int(wave_director.wave_number)
  var spec:Dictionary=wave_director.wave_spec(current_wave)
  var total:=int(wave_director.total_enemies)
  var spawned_so_far:=total-int(wave_director.enemies_to_spawn)
  for i in range(spawn_count):
   if enemies.size()>=54: break
   var spawn_index:=spawned_so_far-spawn_count+i
   var boss_flag:=bool(spec.get("boss",false)) and spawn_index==0
   var elite_flag:=bool(spec.get("elite",false)) and not boss_flag and spawn_index==total-1
   var kind:="boss" if boss_flag else (_enemy_kind_for_wave(current_wave) if not elite_flag else _enemy_kind_for_wave(current_wave))
   _spawn(kind,_random_spawn_position(),elite_flag,boss_flag,spec)
  encounter_active=true; combat_engaged=true
  if event_name=="" or event_name=="spawn_batch":
   result["event"]="spawn_batch"

func _hero_max_hp()->int:
 return maxi(1,int(round(float(CLASSES[hero_class].hp)+float(maxi(0,level-1))*10.0+float(run_stats.get("max_hp",0.0)))))

func _hero_max_mp()->int:
 return maxi(1,int(CLASSES[hero_class].mp+maxi(0,level-1)*5))

func _rebuild_run_stats():
 run_stats=RUN_STAT_DEFAULTS.duplicate(true)
 run_stats["damage_flat"]+=float(mastery_bonus_damage)
 for upgrade_id in upgrade_ranks.keys():
  var card:Dictionary=upgrade_catalog.get_card(str(upgrade_id))
  if card.is_empty(): continue
  var rank:=maxi(0,int(upgrade_ranks.get(upgrade_id,0)))
  var effects:Dictionary=card.get("effects",{})
  for stat_key in effects.keys():
   var effect_value:Variant=effects[stat_key]
   if run_stats.has(stat_key) and (typeof(effect_value)==TYPE_FLOAT or typeof(effect_value)==TYPE_INT):
    run_stats[stat_key]=float(run_stats[stat_key])+float(effect_value)*float(rank)

func _update_run_regeneration(delta:float):
 var regen:=maxf(0.0,float(run_stats.get("regen",0.0)))
 if regen>0.0 and hp<_hero_max_hp(): hp=minf(float(_hero_max_hp()),float(hp)+regen*delta)

func _update_auto_attacks(delta:float):
 if not expedition_active or enemies.is_empty() or wave_director.phase!="spawning": return
 auto_attack_timer=maxf(0.0,auto_attack_timer-delta)
 if auto_attack_timer>0.0: return
 var combat:Dictionary=CLASS_COMBAT[hero_class]
 var attack_range:=float(combat["range"])*(1.0+float(run_stats.get("attack_range_pct",0.0)))
 var closest_index:=-1
 var closest_distance:=attack_range
 for i in range(enemies.size()):
  var distance:=hero.distance_to(enemies[i].pos)
  if distance<closest_distance: closest_distance=distance; closest_index=i
 if closest_index<0:
  auto_attack_timer=0.12
  return
 var attack_speed:=clampf(1.0+float(run_stats.get("attack_speed_pct",0.0)),0.55,2.5)
 auto_attack_timer=maxf(0.16,float(combat["interval"])/attack_speed)
 var low_health_bonus:=float(run_stats.get("damage_pct",0.0))
 if hp<=_hero_max_hp()*0.35: low_health_bonus+=float(run_stats.get("low_health_damage",0.0))
 var crowd_count:=0
 for enemy in enemies:
  if hero.distance_to(enemy.pos)<190.0: crowd_count+=1
 var crowd_bonus:=float(run_stats.get("crowd_damage",0.0)) if crowd_count>=4 else 0.0
 var damage_value:=maxi(1,int(round((float(CLASSES[hero_class].damage)+float(run_stats.get("damage_flat",0.0))+float(level-1)*1.2)*(1.0+low_health_bonus+crowd_bonus)*float(combat["damage"]))))
 var crit_chance:=float(run_stats.get("crit_chance",0.05))+(0.12 if hero_class=="rogue" else (0.05 if hero_class=="ranger" else 0.0))
 if str(combat["style"])=="melee":
  var hit_indices:Array[int]=[]
  if hero_class=="warrior":
   for i in range(enemies.size()):
    if hero.distance_to(enemies[i].pos)<=minf(125.0,attack_range): hit_indices.append(i)
  else: hit_indices.append(closest_index)
  hit_indices.sort()
  for cursor in range(hit_indices.size()-1,-1,-1):
   var index:int=hit_indices[cursor]
   var hit_damage:=damage_value
   if randf()<clampf(crit_chance,0.0,0.75): hit_damage=int(round(float(hit_damage)*float(run_stats.get("crit_damage",1.5))))
   _damage_enemy(index,hit_damage,"auto")
  attack_flash=0.16
  if hero_class=="warrior": skill_flash=0.12
 else:
  var target_position:Vector2=enemies[closest_index].pos
  var count:=1+maxi(0,int(run_stats.get("projectile_count",0)))
  var pierce:=maxi(0,int(run_stats.get("projectile_pierce",0)))
  for projectile_index in range(count):
   var offset:=float(projectile_index)-float(count-1)*0.5
   var direction:Vector2=(target_position-hero).normalized().rotated(offset*0.11)
   var hit_damage:=damage_value
   if randf()<clampf(crit_chance,0.0,0.75): hit_damage=int(round(float(hit_damage)*float(run_stats.get("crit_damage",1.5))))
   projectiles.append({"pos":hero+direction*18.0,"direction":direction,"speed":float(combat["projectile_speed"]),"damage":hit_damage,"pierce":pierce,"splash":28.0 if hero_class=="mage" else 0.0,"life":1.5,"color":Color("#80dcff") if hero_class=="mage" else Color("#f1d28a")})
  attack_flash=0.12

func _damage_enemy(index:int,amount:int,source:String):
 if index<0 or index>=enemies.size(): return
 var target:Dictionary=enemies[index]
 var damage:=maxi(1,amount)
 target.hp=int(target.hp)-damage
 _float(target.pos+Vector2(0,-32),str(damage),Color("#8ce7f0") if source=="projectile" else Color("#ffdf80"))
 var lifesteal:=float(run_stats.get("lifesteal",0.0))
 if lifesteal>0.0:
  var healing:=maxi(1,int(round(float(damage)*lifesteal)))
  hp=mini(_hero_max_hp(),hp+healing)
 if int(target.hp)<=0:
  _register_enemy_kill(target)
  enemies.remove_at(index)
  if enemies.is_empty() and not expedition_active:
   encounter_active=false; combat_engaged=false
 else:
  enemies[index]=target

func _update_projectiles(delta:float):
 for i in range(projectiles.size()-1,-1,-1):
  var projectile:Dictionary=projectiles[i]
  projectile.life=float(projectile.get("life",1.0))-delta
  var position:Vector2=projectile.get("pos",hero)
  position+=Vector2(projectile.get("direction",Vector2.RIGHT))*float(projectile.get("speed",350.0))*delta
  projectile.pos=position
  if float(projectile.life)<=0.0:
   projectiles.remove_at(i); continue
  var hit_index:=-1
  for enemy_index in range(enemies.size()):
   var enemy_radius:=float(enemies[enemy_index].get("radius",22.0))
   if position.distance_to(enemies[enemy_index].pos)<=enemy_radius+7.0:
    hit_index=enemy_index; break
  if hit_index>=0:
   var splash:=float(projectile.get("splash",0.0))
   if splash>0.0:
    for enemy_index in range(enemies.size()-1,-1,-1):
     if position.distance_to(enemies[enemy_index].pos)<=splash:
      _damage_enemy(enemy_index,int(projectile.damage),"projectile")
   else: _damage_enemy(hit_index,int(projectile.damage),"projectile")
   if int(projectile.get("pierce",0))>0:
    projectile.pierce=int(projectile.pierce)-1
    projectile.pos=position+Vector2(projectile.direction)*12.0
    projectiles[i]=projectile
   else: projectiles.remove_at(i)
  else: projectiles[i]=projectile

func _update_enemies(delta:float):
 for i in range(enemies.size()-1,-1,-1):
  var enemy:Dictionary=enemies[i]
  var offset:Vector2=hero-enemy.pos
  var distance:=offset.length()
  var role:=str(enemy.get("role","swarm"))
  var attack_timer:=float(enemy.get("attack_timer",0.0))-delta
  var windup:=float(enemy.get("windup",0.0))
  if role=="ranged":
   var preferred:=float(enemy.get("attack_range",240.0))
   if distance>preferred*0.78: enemy.pos+=offset.normalized()*float(enemy.speed)*delta
   elif distance<preferred*0.48: enemy.pos-=offset.normalized()*float(enemy.speed)*delta
   if windup>0.0:
    windup-=delta
    if windup<=0.0:
     var target_pos:Vector2=enemy.get("windup_pos",hero)
     if hero.distance_to(target_pos)<42.0 and _take_player_damage(int(enemy.damage),"ranged"):
      enemies[i]=enemy; break
     attack_timer=1.8
    enemy.windup=windup
   elif attack_timer<=0.0:
    enemy.windup=0.62; enemy.windup_pos=hero; attack_timer=2.3
   enemy.attack_timer=attack_timer
  else:
   var contact_radius:=float(enemy.get("radius",22.0))+22.0
   if distance>contact_radius: enemy.pos+=offset.normalized()*float(enemy.speed)*delta
   if bool(enemy.get("boss",false)):
    if windup>0.0:
     windup-=delta
     if windup<=0.0:
      var target_pos:Vector2=enemy.get("windup_pos",hero)
      if hero.distance_to(target_pos)<82.0 and _take_player_damage(int(enemy.damage*1.7),"boss"):
       enemies[i]=enemy; break
      attack_timer=3.4
     enemy.windup=windup
    elif attack_timer<=0.0:
     enemy.windup=0.9; enemy.windup_pos=hero; attack_timer=4.1
    if distance<=contact_radius and attack_timer<=0.0:
     if _take_player_damage(int(enemy.damage),"boss melee"):
      enemies[i]=enemy; break
   elif distance<=contact_radius and attack_timer<=0.0:
    if _take_player_damage(int(enemy.damage),role):
     enemies[i]=enemy; break
    attack_timer=1.45 if role=="stalker" else 1.8
   enemy.attack_timer=attack_timer
  enemies[i]=enemy

func _take_player_damage(raw_damage:int,source:String)->bool:
 if randf()<clampf(float(run_stats.get("dodge_chance",0.0)),0.0,0.45):
  _float(hero+Vector2(0,-35),"DODGE",Color("#b7e9ff")); return false
 var reduction:=clampf(float(run_stats.get("damage_reduction",0.0)),0.0,0.55)
 var armor:=maxf(-5.0,float(run_stats.get("armor",0.0)))
 var vulnerability:=maxf(0.0,float(run_stats.get("damage_taken_pct",0.0)))
 var final_damage:=maxi(1,int(round(float(raw_damage)*(1.0+vulnerability)*(1.0-reduction)-armor)))
 hp-=final_damage
 _float(hero+Vector2(0,-38),"-%d" % final_damage,Color("#ff7068"))
 if hp<=0:
  _end_run_on_death()
  return true
 return false

func _say(s:String):
 notice=s; notice_time=2.5

func _float(p:Vector2,t:String,c:Color):
 floats.append({"pos":p,"text":t,"color":c,"time":1.0})

func _class_skill_name() -> String:
 match hero_class:
  "warrior": return "Whirlwind"
  "ranger": return "Volley"
  "mage": return "Arcane Burst"
  "rogue": return "Shadow Strike"
 return "Special Move"

func _skill_description()->String:
 match hero_class:
  "warrior": return "A close-range spin that hits every nearby foe."
  "ranger": return "A long-range volley that can strike multiple enemies."
  "mage": return "A burst of arcane energy across a wide radius."
  "rogue": return "A swift shadow strike with a chance to deal bonus damage."
 return "A signature technique for wilderness battles."

func _skill_icon_key()->String:
 return hero_class if SKILL_ICONS.has(hero_class) else "warrior"

func _use_skill():
 if not encounter_active:
  _say("Special moves are available during wilderness encounters.")
  return
 if skill_cooldown > 0.0:
  _say("Special move recharging: %.1fs" % skill_cooldown)
  return
 if level < 2 and not unlocked_skills.has(_class_skill_name()):
  _say("Reach level 2 to unlock your class special move.")
  return
 if mp < 15:
  _say("Not enough MP. Special moves cost 15 MP.")
  return
 mp -= 15
 combat_engaged = true
 skill_cooldown = 4.0
 skill_flash = 0.35
 active_attack_id=""
 var base_damage: int = int(CLASSES[hero_class].damage * 2.2) + level * 2
 var hit_count := 0
 for i in range(enemies.size() - 1, -1, -1):
  var e: Dictionary = enemies[i]
  var reach := 185.0 if hero_class in ["ranger", "mage"] else 125.0
  if hero.distance_to(e.pos) <= reach:
   var damage := base_damage
   if hero_class == "warrior" and hero.distance_to(e.pos) < 110.0:
    damage += 8
   if hero_class == "rogue" and randf() < 0.35:
    damage = int(damage * 1.8)
   e.hp -= damage
   _float(e.pos + Vector2(0, -32), str(damage) + "!", Color("#8ce7f0"))
   hit_count += 1
   if e.hp <= 0:
    _register_enemy_kill(e)
    enemies.remove_at(i)
   else:
    enemies[i] = e
 if hit_count == 0:
  mp += 15
  skill_cooldown = 0.0
  _say("No enemies in range. Move closer first.")
 else:
  _say(_class_skill_name() + "! Hit %d target(s)." % hit_count)
 if enemies.is_empty():
   encounter_active = false
   combat_engaged=false
   _say("Room clear! Use a cardinal exit for the next homeward roll." if expedition_active else "Encounter cleared! The wilds are quiet.")

func _attack():
 if not encounter_active or enemies.is_empty():
  _say("Auto-attacks begin when expedition enemies arrive."); return
 if last_attack>0.0: return
 last_attack=0.35
 combat_engaged=true
 var class_data:Dictionary=CLASS_COMBAT[hero_class]
 var attack_range:=float(class_data["range"])*(1.0+float(run_stats.get("attack_range_pct",0.0)))
 var target_index:=-1; var closest_distance:=attack_range
 for i in range(enemies.size()):
  var distance:=hero.distance_to(enemies[i].pos)
  if distance<closest_distance: closest_distance=distance; target_index=i
 if target_index<0: _say("No enemy in manual range; your automatic weapon keeps firing."); return
 var base_damage:float=float(CLASSES[hero_class].damage)+float(run_stats.get("damage_flat",0.0))+float(maxi(0,level-1))*1.2
 base_damage*=float(class_data["damage"])*(1.0+float(run_stats.get("damage_pct",0.0)))
 var critical_chance:=float(run_stats.get("crit_chance",0.05))+(0.12 if hero_class=="rogue" else (0.05 if hero_class=="ranger" else 0.0))
 if randf()<clampf(critical_chance,0.0,0.75): base_damage*=float(run_stats.get("crit_damage",1.5))
 _damage_enemy(target_index,maxi(1,int(round(base_damage))),"manual")
 attack_flash=0.22
 if enemies.is_empty() and not expedition_active:
  encounter_active=false; combat_engaged=false

func _register_enemy_kill(enemy:Dictionary):
 var xp_reward:=maxi(1,int(enemy.get("xp",0)))
 var enemy_pos:Vector2=enemy.get("pos",hero)
 var gold_base:=randi_range(2,7)+int(expedition_depth/5)
 var gold_reward:=maxi(1,int(round(float(gold_base)*(1.0+float(run_stats.get("gold_bonus",0.0))))))
 kills+=1
 if quest_active: quest_kills+=1
 if expedition_active:
  expedition_loot["gold"]=int(expedition_loot.get("gold",0))+gold_reward
  var drop_chance:=clampf(0.30+float(run_stats.get("item_bonus",0.0)),0.0,0.85)
  if randf()<drop_chance:
   var drops:Array[String]=["Forest Herb","Rough Ore","Oak Wood"]
   var drop:String=drops[randi_range(0,drops.size()-1)]
   expedition_loot[drop]=int(expedition_loot.get(drop,0))+1
   _float(enemy_pos+Vector2(0,-48),"+1 "+drop,Color("#a9edc0"))
  _float(enemy_pos,"+%dG HAUL" % gold_reward,Color("#83efaa"))
 else:
  gold+=gold_reward
  _float(enemy_pos,"+%dG" % gold_reward,Color("#83efaa"))
 _float(enemy_pos+Vector2(0,-42),"XP GEM +%d" % xp_reward,Color("#78eaff"))
 if bool(enemy.get("boss",false)): _float(enemy_pos+Vector2(0,-66),"BOSS DEFEATED • BONUS HAUL",Color("#ffe08c"))
 xp_pickups.append({"pos":enemy_pos,"xp":xp_reward,"phase":randf_range(0.0,TAU)})

func _update_xp_pickups(delta:float):
 for i in range(xp_pickups.size()-1,-1,-1):
  var gem:Dictionary=xp_pickups[i]
  var gem_pos:Vector2=gem.get("pos",hero)
  var distance:=gem_pos.distance_to(hero)
  gem["phase"]=float(gem.get("phase",0.0))+delta*3.0
  var magnet_range:=clampf(float(run_stats.get("pickup_magnet",124.0)),80.0,440.0)
  if distance<magnet_range:
   gem_pos=gem_pos.move_toward(hero,210.0*delta)
   gem["pos"]=gem_pos
   xp_pickups[i]=gem
  if gem_pos.distance_to(hero)<24.0:
   var base_xp:=maxi(1,int(gem.get("xp",1)))
   var xp_value:=maxi(1,int(round(float(base_xp)*(1.0+float(run_stats.get("xp_gain_pct",0.0))))))
   xp+=xp_value
   _float(hero+Vector2(0,-54),"+%d XP" % xp_value,Color("#88edff"))
   xp_pickups.remove_at(i)
   _level_check()
   if screen!="game": break

func _xp_pickup_total()->int:
 var total:=0
 for gem in xp_pickups: total+=maxi(0,int(gem.get("xp",0)))
 return total

func _level_check():
 var gained_levels:=0
 if pending_levelup_count==0: levelup_return_screen=screen
 while xp>=xp_next:
  xp-=xp_next; level+=1; skill_points+=1
  xp_next=int(round(float(xp_next)*1.34+4.0))
  pending_levelup_count+=1; gained_levels+=1
  hp=mini(_hero_max_hp(),hp+10)
  mp=mini(_hero_max_mp(),mp+5)
  _float(hero+Vector2(0,-60),"LEVEL UP!",Color("#ffe17a"))
 if pending_levelup_count>0 and screen!="level_up": _show_next_levelup()
 if gained_levels>0: _say("Level %d • pause to choose one of three upgrades." % level)

func _roll_levelup_options()->Array[Dictionary]:
 var offered_slots:Array[String]=attack_slots.duplicate()
 if attack_slots.size()>=3:
  for attack_id in LEVELUP_ATTACKS.keys():
   if not offered_slots.has(str(attack_id)): offered_slots.append(str(attack_id))
 return upgrade_catalog.roll_offers(hero_class,upgrade_ranks,offered_slots)

func _show_next_levelup():
 if pending_levelup_count<=0: return
 levelup_options=_roll_levelup_options()
 screen="level_up"

func _apply_levelup_card(card:Dictionary):
 var card_id:=str(card.get("id",""))
 var card_data:Dictionary=upgrade_catalog.get_card(card_id)
 if card_data.is_empty(): return
 var old_max_hp:=_hero_max_hp()
 if bool(card_data.get("active",false)):
  var attack_id:=str(card_data.get("attack_id",""))
  if attack_id!="" and not attack_slots.has(attack_id) and attack_slots.size()<3:
   attack_slots.append(attack_id); attack_ranks[attack_id]=1
   _say("Ability learned: %s • use its new hotbar button." % attack_id)
  else:
   _say("Ability capacity is full; choose a passive upgrade instead.")
   return
 else:
  upgrade_ranks[card_id]=int(upgrade_ranks.get(card_id,0))+1
  _rebuild_run_stats()
  _say("%s • rank %d acquired." % [str(card_data.get("name",card_id)),int(upgrade_ranks[card_id])])
 var new_max_hp:=_hero_max_hp()
 if new_max_hp>old_max_hp: hp=mini(new_max_hp,hp+new_max_hp-old_max_hp)
 mp=mini(_hero_max_mp(),mp+3)

func _choose_levelup(index:int):
 if screen!="level_up" or index<0 or index>=levelup_options.size(): return
 var choice:Dictionary=levelup_options[index]
 _apply_levelup_card(choice)
 pending_levelup_count=maxi(0,pending_levelup_count-1)
 levelup_options.clear()
 if pending_levelup_count>0: _show_next_levelup()
 else:
  screen=levelup_return_screen
  levelup_time=3.5

func _upgrade_effect_summary(card:Dictionary)->String:
 var effects:Dictionary=card.get("effects",{})
 var labels:Array[String]=[]
 for key in effects.keys():
  var value:Variant=effects[key]
  var amount:=float(value) if typeof(value)==TYPE_FLOAT or typeof(value)==TYPE_INT else 0.0
  match str(key):
   "damage_flat": labels.append("+%d attack damage" % int(amount))
   "damage_pct": labels.append("%+d%% damage" % int(round(amount*100.0)))
   "attack_speed_pct": labels.append("%+d%% attack speed" % int(round(amount*100.0)))
   "attack_range_pct": labels.append("%+d%% range" % int(round(amount*100.0)))
   "crit_chance": labels.append("%+d%% critical chance" % int(round(amount*100.0)))
   "crit_damage": labels.append("%+d%% critical damage" % int(round(amount*100.0)))
   "projectile_count": labels.append("+%d projectile(s)" % int(amount))
   "projectile_pierce": labels.append("+%d pierce" % int(amount))
   "max_hp": labels.append("%+d max HP" % int(amount))
   "armor": labels.append("%+d armor" % int(amount))
   "damage_reduction": labels.append("%+d%% damage reduction" % int(round(amount*100.0)))
   "regen": labels.append("+%.1f HP/s" % amount)
   "dodge_chance": labels.append("%+d%% dodge" % int(round(amount*100.0)))
   "move_speed_pct": labels.append("%+d%% move speed" % int(round(amount*100.0)))
   "xp_gain_pct": labels.append("%+d%% XP" % int(round(amount*100.0)))
   "pickup_magnet": labels.append("+%d pickup range" % int(amount))
   "gold_bonus": labels.append("%+d%% gold" % int(round(amount*100.0)))
   "item_bonus": labels.append("%+d%% item chance" % int(round(amount*100.0)))
   "healing_bonus": labels.append("%+d%% healing" % int(round(amount*100.0)))
   "lifesteal": labels.append("%.0f%% lifesteal" % (amount*100.0))
   "ability_unlocked": labels.append("Unlocks %s" % str(card.get("attack_id","ability")))
 return " • ".join(labels)

func _levelup_card_rect(slot:int)->Rect2:
 return Rect2(170+slot*315,210,290,330)

func _attack_slot_rect(slot:int)->Rect2:
 return Rect2(495+slot*98,560,90,100)

func _use_learned_attack(slot:int):
 if slot<0 or slot>=attack_slots.size(): return
 var attack_id:=attack_slots[slot]
 var data:Dictionary=LEVELUP_ATTACKS[attack_id]
 if not encounter_active or enemies.is_empty():
  _say("Learned attacks can be used during an encounter.")
  return
 var remaining:=float(attack_cooldowns.get(attack_id,0.0))
 if remaining>0.0:
  _say("%s recharging: %.1fs" % [attack_id,remaining])
  return
 var cost:=int(data["cost"])
 if mp<cost:
  _say("Not enough MP. %s costs %d." % [attack_id,cost])
  return
 var targets:Array[int]=[]
 var mode:=str(data["mode"])
 if mode=="aoe":
  for i in range(enemies.size()):
   if hero.distance_to(enemies[i].pos)<=float(data["reach"]): targets.append(i)
 else:
  var candidates:Array[Dictionary]=[]
  for i in range(enemies.size()):
   var distance:=hero.distance_to(enemies[i].pos)
   if distance<=float(data["reach"]): candidates.append({"index":i,"distance":distance})
  candidates.sort_custom(func(a:Dictionary,b:Dictionary)->bool: return float(a["distance"])<float(b["distance"]))
  for i in range(mini(int(data["targets"]),candidates.size())): targets.append(int(candidates[i]["index"]))
 targets.sort()
 if targets.is_empty():
  _say("No enemies in range. Move closer first.")
  return
 mp-=cost
 combat_engaged=true
 attack_cooldowns[attack_id]=float(data["cooldown"])
 skill_flash=0.35
 attack_flash=0.28
 active_attack_id=attack_id
 var rank:=int(attack_ranks.get(attack_id,1))
 var base_damage:=maxi(1,int(round((float(CLASSES[hero_class].damage)+float(level)*2.0)*float(data["damage"])*(1.0+0.25*float(rank-1)))))
 var hit_count:=0
 for target_cursor in range(targets.size()-1,-1,-1):
  var target_index:=targets[target_cursor]
  var enemy:Dictionary=enemies[target_index]
  enemy.hp-=base_damage
  _float(enemy.pos+Vector2(0,-30),str(base_damage)+"!",Color("#8ce7f0"))
  hit_count+=1
  if enemy.hp<=0:
   _register_enemy_kill(enemy)
   enemies.remove_at(target_index)
  else: enemies[target_index]=enemy
 _say("%s! Hit %d target(s)." % [attack_id,hit_count])
 if enemies.is_empty():
  encounter_active=false
  combat_engaged=false
  _say("Room clear! Choose a direction to continue; return home to bank your haul." if expedition_active else "Encounter cleared! The wilds are quiet.")

func _nearest()->String:
 if area_id != "village": return ""
 var list=[["Elder",Vector2(630,230)],["Blacksmith",Vector2(460,265)],["Herbalist",Vector2(810,265)],
 ["Chest",Vector2(930,440)],["Herb",Vector2(320,485)],["Ore",Vector2(1060,510)],["Tree",Vector2(270,340)]]
 var best:=75.0; var result:=""
 for item in list:
  var d:float=hero.distance_to(item[1])
  if d<best: best=d; result=item[0]
 for villager in villagers:
  var villager_pos:Vector2=villager["pos"]
  var villager_distance:float=hero.distance_to(villager_pos)
  if villager_distance<best:
   best=villager_distance; result=villager["name"]
 return result

func _reset_villagers():
 villagers = [
  {"name":"Mira","pos":Vector2(365,355),"path":[Vector2(365,355),Vector2(435,355),Vector2(435,380),Vector2(365,380)],"target_index":1,"speed":24.0,"wait":0.2,"color":Color("#bd765f")},
  {"name":"Tomas","pos":Vector2(1000,350),"path":[Vector2(1000,350),Vector2(1065,350),Vector2(1065,375),Vector2(1000,375)],"target_index":1,"speed":20.0,"wait":0.8,"color":Color("#648c78")}
 ]

func _update_villagers(delta:float):
 for i in range(villagers.size()):
  var villager:Dictionary=villagers[i]
  var wait_left:float=float(villager.get("wait",0.0))
  if wait_left>0.0:
   villager["wait"]=maxf(0.0,wait_left-delta)
   villagers[i]=villager
   continue
  var route:Array=villager["path"]
  if route.is_empty(): continue
  var target_index:int=int(villager.get("target_index",0)) % route.size()
  var position:Vector2=villager["pos"]
  var destination:Vector2=route[target_index]
  var offset:Vector2=destination-position
  if offset.length()<3.0:
   villager["target_index"]=(target_index+1)%route.size()
   villager["wait"]=randf_range(0.6,1.8)
  else:
   var step:float=minf(float(villager["speed"])*delta,offset.length())
   villager["pos"]=position+offset.normalized()*step
  villagers[i]=villager

func _villager_dialogue(villager_name:String)->String:
 match villager_name:
  "Mira": return "I need herbs to make remedies for the village."
  "Tomas": return "The roadside signposts are coming loose."
 return "It's a peaceful day in Greenhollow."

func _reset_villager_quests():
 villager_quests={"Mira":"available","Tomas":"available"}

func _villager_task(villager_name:String)->Dictionary:
 if villager_name == "Mira": return {"item":"Forest Herb","amount":2,"reward":15}
 if villager_name == "Tomas": return {"item":"Oak Wood","amount":2,"reward":20}
 return {}

func _villager_task_summary(villager_name:String)->String:
 var task := _villager_task(villager_name)
 if task.is_empty(): return "No errands to run right now."
 return "Task: bring %d %s." % [int(task.amount),str(task.item)]

func _villager_task_progress(villager_name:String)->String:
 var state:String=str(villager_quests.get(villager_name,"available"))
 var task := _villager_task(villager_name)
 if task.is_empty(): return ""
 if state == "available": return "Reward: %d gold • Accept to begin" % int(task.reward)
 if state == "complete": return "Task complete • Thank you for helping Greenhollow!"
 var have:int=int(inventory.get(str(task.item),0))
 return "Collected: %d / %d %s" % [have,int(task.amount),str(task.item)]

func _advance_villager_task():
 var task := _villager_task(talking_to)
 if task.is_empty(): return
 var state:String=str(villager_quests.get(talking_to,"available"))
 if state == "available":
  villager_quests[talking_to]="active"
  _say(talking_to+"'s task accepted. Come back with the items.")
  screen="game"; talking_to=""
 elif state == "active":
  var item_name:String=str(task.item)
  var required:int=int(task.amount)
  var have:int=int(inventory.get(item_name,0))
  if have<required:
   _say("You need %d more %s." % [required-have,item_name])
   return
  inventory[item_name]=have-required
  gold+=int(task.reward)
  villager_quests[talking_to]="complete"
  _say("Task complete! +%d gold." % int(task.reward))
  screen="game"; talking_to=""
 else:
  _say("Thanks again for helping the village.")
  screen="game"; talking_to=""

func _interact():
 var n=_nearest()
 match n:
  "Elder": screen="dialogue"
  "Blacksmith","Herbalist": screen="shop"; _say("Home workshop • prepare supplies before your next expedition.")
  "Mira","Tomas": talking_to=n; screen="villager_dialogue"
  "Chest": inventory["Forest Herb"]+=1; gold+=5; _say("Chest: +1 herb and +5 gold.")
  "Herb": inventory["Forest Herb"]+=1; _say("Collected a forest herb.")
  "Ore": inventory["Rough Ore"]+=1; _say("Collected rough ore.")
  "Tree": inventory["Oak Wood"]+=1; _say("Collected oak wood.")
  _: _say("Nothing nearby to interact with.")

func _craft_home_potion():
 if int(inventory.get("Forest Herb",0))<2 or int(inventory.get("Oak Wood",0))<1:
  _say("Need 2 Forest Herbs and 1 Oak Wood to brew a health potion.")
  return
 inventory["Forest Herb"]-=2
 inventory["Oak Wood"]-=1
 inventory["Small Health Potion"]=int(inventory.get("Small Health Potion",0))+1
 _say("Brewed a Small Health Potion from village supplies.")

func _build_home_waystone():
 if waystone_built:
  _say("The Waystone is already built. Homeward chance bonus is active.")
  return
 if int(inventory.get("Rough Ore",0))<4 or int(inventory.get("Oak Wood",0))<3:
  _say("Need 4 Rough Ore and 3 Oak Wood to build the Waystone.")
  return
 inventory["Rough Ore"]-=4
 inventory["Oak Wood"]-=3
 waystone_built=true
 _say("Waystone built! Expedition homeward chance is permanently +8%.")

func _save():
 var serialized_pickups:Array=[]
 for gem in xp_pickups:
  var gem_pos:Vector2=gem.get("pos",Vector2.ZERO)
  serialized_pickups.append({"pos":[gem_pos.x,gem_pos.y],"xp":int(gem.get("xp",0)),"phase":float(gem.get("phase",0.0))})
 var current_wave:=int(wave_director.wave_number) if expedition_active else 0
 var saved_wave_phase:=str(wave_director.phase) if expedition_active else "idle"
 var data={"save_version":4,"class":hero_class,"name":hero_name,"area":area_id,"pos":[hero.x,hero.y],"level":level,"xp":xp,"xp_next":xp_next,"skill_points":skill_points,"gold":gold,"hp":hp,"mp":mp,"kills":kills,"quest_active":quest_active,"quest_kills":quest_kills,"hardcore":hardcore,"inventory":inventory,"settings":settings,"unlocked_skills":unlocked_skills,"villager_quests":villager_quests,"attack_slots":attack_slots,"attack_ranks":attack_ranks,"upgrade_ranks":upgrade_ranks,"mastery_bonus_damage":mastery_bonus_damage,"expedition_active":expedition_active,"expedition_depth":expedition_depth,"expedition_loot":expedition_loot,"waystone_built":waystone_built,"xp_pickups":serialized_pickups,"best_depth":best_depth,"best_wave":best_wave,"runs_completed":runs_completed,"runs_lost":runs_lost,"wave_number":current_wave,"wave_phase":saved_wave_phase,"at_home_intermission":at_home_intermission}
 var file:=FileAccess.open(SAVE_PATH,FileAccess.WRITE)
 if file:
  file.store_string(JSON.stringify(data))
  file.close()
  _say("Progress saved • run build, wave and unbanked haul recorded.")
 else: _say("Could not write the save file.")

func _load():
 if not FileAccess.file_exists(SAVE_PATH): _say("No save yet."); return
 var parsed:Variant=JSON.parse_string(FileAccess.get_file_as_string(SAVE_PATH))
 if typeof(parsed)!=TYPE_DICTIONARY: _say("Save file invalid."); return
 var data:Dictionary=parsed
 hero_class=str(data.get("class","warrior"))
 if not CLASSES.has(hero_class): hero_class="warrior"
 hero_name=str(data.get("name","Adventurer"))
 area_id=str(data.get("area","village"))
 if area_id not in ["village","forest","north","south","west","ruins"]: area_id="village"
 var saved_position:Variant=data.get("pos",[640,380])
 if typeof(saved_position)==TYPE_ARRAY and saved_position.size()>=2: hero=Vector2(float(saved_position[0]),float(saved_position[1]))
 else: hero=Vector2(640,380)
 level=maxi(1,int(data.get("level",1))); xp=maxi(0,int(data.get("xp",0))); xp_next=maxi(50,int(data.get("xp_next",50)))
 skill_points=maxi(0,int(data.get("skill_points",0))); gold=maxi(0,int(data.get("gold",25)))
 hp=maxi(1,int(data.get("hp",CLASSES[hero_class].hp))); mp=maxi(0,int(data.get("mp",CLASSES[hero_class].mp)))
 kills=maxi(0,int(data.get("kills",0))); quest_active=bool(data.get("quest_active",false)); quest_kills=maxi(0,int(data.get("quest_kills",0))); hardcore=bool(data.get("hardcore",false))
 var saved_inventory:Variant=data.get("inventory",inventory)
 if typeof(saved_inventory)==TYPE_DICTIONARY: inventory=saved_inventory
 for item in ["Small Health Potion","Forest Herb","Rough Ore","Oak Wood"]:
  inventory[item]=maxi(0,int(inventory.get(item,0)))
 var saved_settings:Variant=data.get("settings",settings)
 if typeof(saved_settings)==TYPE_DICTIONARY: settings=saved_settings
 unlocked_skills.clear()
 var saved_skills:Variant=data.get("unlocked_skills",[])
 if typeof(saved_skills)==TYPE_ARRAY:
  for skill in saved_skills:
   if _class_skill_names().has(str(skill)) and not unlocked_skills.has(str(skill)): unlocked_skills.append(str(skill))
 attack_slots.clear()
 var saved_attacks:Variant=data.get("attack_slots",[])
 if typeof(saved_attacks)==TYPE_ARRAY:
  for attack_id in saved_attacks:
   var attack_id_string:=str(attack_id)
   if LEVELUP_ATTACKS.has(attack_id_string) and not attack_slots.has(attack_id_string) and attack_slots.size()<3: attack_slots.append(attack_id_string)
 var saved_ranks:Variant=data.get("attack_ranks",{})
 attack_ranks={}
 for attack_name in attack_slots:
  attack_ranks[attack_name]=clampi(int(saved_ranks.get(attack_name,1)),1,5) if typeof(saved_ranks)==TYPE_DICTIONARY else 1
 attack_cooldowns.clear(); xp_pickups.clear(); projectiles.clear()
 var saved_pickups:Variant=data.get("xp_pickups",[])
 if typeof(saved_pickups)==TYPE_ARRAY:
  for saved_gem in saved_pickups:
   if typeof(saved_gem)!=TYPE_DICTIONARY: continue
   var gem_pos:Variant=saved_gem.get("pos",[])
   if typeof(gem_pos)!=TYPE_ARRAY or gem_pos.size()<2: continue
   var gem_xp:=int(saved_gem.get("xp",0))
   if gem_xp>0: xp_pickups.append({"pos":Vector2(float(gem_pos[0]),float(gem_pos[1])),"xp":gem_xp,"phase":float(saved_gem.get("phase",0.0))})
 expedition_active=bool(data.get("expedition_active",false))
 expedition_depth=maxi(0,int(data.get("expedition_depth",0))) if expedition_active else 0
 var saved_loot:Variant=data.get("expedition_loot",{})
 expedition_loot={"gold":0,"Forest Herb":0,"Rough Ore":0,"Oak Wood":0}
 if typeof(saved_loot)==TYPE_DICTIONARY:
  for loot_key in expedition_loot.keys(): expedition_loot[loot_key]=maxi(0,int(saved_loot.get(loot_key,0)))
 waystone_built=bool(data.get("waystone_built",false))
 best_depth=maxi(0,int(data.get("best_depth",0))); best_wave=maxi(0,int(data.get("best_wave",0)))
 runs_completed=maxi(0,int(data.get("runs_completed",0))); runs_lost=maxi(0,int(data.get("runs_lost",0)))
 var saved_upgrades:Variant=data.get("upgrade_ranks",{})
 mastery_bonus_damage=maxi(0,int(data.get("mastery_bonus_damage",0)))
 upgrade_ranks={}
 if typeof(saved_upgrades)==TYPE_DICTIONARY:
  for upgrade_id in saved_upgrades.keys():
   var card:Dictionary=upgrade_catalog.get_card(str(upgrade_id))
   if card.is_empty(): continue
   var saved_rank:=clampi(int(saved_upgrades[upgrade_id]),0,int(card.get("max_rank",1)))
   if saved_rank>0: upgrade_ranks[str(upgrade_id)]=saved_rank
 _rebuild_run_stats()
 at_home_intermission=bool(data.get("at_home_intermission",false)) and expedition_active and area_id=="village"
 wave_director.reset()
 if expedition_active:
  var saved_wave:=maxi(1,int(data.get("wave_number",1)))
  wave_director.wave_number=saved_wave
  wave_director.phase="checkpoint"
  wave_director.timer=0.0
  wave_director.total_enemies=0
  wave_director.enemies_to_spawn=0
  if not at_home_intermission:
   expedition_depth+=1
   wave_director.continue_after_checkpoint()
 enemies.clear(); encounter_active=expedition_active and area_id!="village"; combat_engaged=encounter_active
 previous_in_wilds=false; home_return_opportunity=false; pending_return_chance=0.0
 pending_levelup_count=0; levelup_options.clear(); screen="game"
 _reset_villagers()
 _say("Save loaded • run build restored; unfinished wave safely resumes at its next checkpoint.")
 _reset_villager_quests()
 var saved_quests:Variant=data.get("villager_quests",{})
 if typeof(saved_quests)==TYPE_DICTIONARY:
  for villager_name in ["Mira","Tomas"]:
   var state:String=str(saved_quests.get(villager_name,"available"))
   villager_quests[villager_name]=state if state in ["available","active","complete"] else "available"

func _class_skill_names()->Array[String]:
 return ["Whirlwind","Volley","Arcane Burst","Shadow Strike"]

func _start():
 level=1; xp=0; xp_next=50; skill_points=0; gold=25; kills=0; quest_kills=0; quest_active=false
 hp=CLASSES[hero_class].hp; mp=CLASSES[hero_class].mp; hero=Vector2(640,380)
 inventory={"Small Health Potion":2,"Forest Herb":0,"Rough Ore":0,"Oak Wood":0}
 enemies.clear(); projectiles.clear(); encounter_active=false; previous_in_wilds=false; area_id="village"
 attack_slots.clear(); attack_ranks.clear(); attack_cooldowns.clear(); upgrade_ranks.clear()
 mastery_bonus_damage=0; run_stats=RUN_STAT_DEFAULTS.duplicate(true); pending_levelup_count=0; levelup_options.clear(); levelup_time=0.0
 active_attack_id=""; xp_pickups.clear(); best_depth=0; best_wave=0; runs_completed=0; runs_lost=0
 expedition_active=false; expedition_depth=0; expedition_loot={"gold":0,"Forest Herb":0,"Rough Ore":0,"Oak Wood":0}; waystone_built=false
 wave_director.reset(); home_return_opportunity=false; at_home_intermission=false; pending_return_chance=0.0
 auto_attack_timer=0.0; passive_timer=0.0; next_enemy_uid=1
 _reset_villager_quests()
 unlocked_skills.clear(); selected_skill=""; skill_cooldown=0.0; screen="game"
 _reset_villagers()
 _say("Welcome to Greenhollow, "+hero_name+".")

func _start_next_run():
 _reset_temporary_build()
 expedition_active=false; expedition_depth=0
 expedition_loot={"gold":0,"Forest Herb":0,"Rough Ore":0,"Oak Wood":0}
 wave_director.reset(); enemies.clear(); projectiles.clear(); xp_pickups.clear()
 area_id="village"; hero=Vector2(640,380); encounter_active=false; combat_engaged=false
 previous_in_wilds=false; at_home_intermission=false; home_return_opportunity=false
 screen="game"
 _say("A fresh %s expedition is ready. Your banked supplies remain safe." % hero_class.capitalize())

func _input(event):
 if event is InputEventMouseMotion:
  pointer_pos=event.position*Vector2(1280,720)/get_viewport_rect().size
 if event is InputEventKey and event.pressed and not event.echo:
  if event.keycode==KEY_ESCAPE:
   if screen=="game": screen="pause"
   elif screen=="level_up": _say("Choose one upgrade to continue.")
   elif screen in ["pause","inventory","skills","settings","shop","dialogue","villager_dialogue"]: screen="game"; talking_to=""
   else: screen="title"
  elif screen=="home_route" and event.keycode==KEY_R: _return_to_village()
  elif screen=="home_route" and event.keycode in [KEY_C,KEY_ENTER,KEY_SPACE]: _continue_expedition()
  elif screen=="death" and event.keycode in [KEY_ENTER,KEY_SPACE]: _start_next_run()
  elif screen=="level_up" and event.keycode in [KEY_1,KEY_2,KEY_3]: _choose_levelup(event.keycode-KEY_1)
  elif screen=="game" and event.keycode in [KEY_1,KEY_2,KEY_3]: _use_learned_attack(event.keycode-KEY_1)
  elif screen=="villager_dialogue" and event.keycode in [KEY_E,KEY_ENTER,KEY_SPACE]: _advance_villager_task()
  elif screen=="game" and event.keycode==KEY_SPACE: _attack()
  elif screen=="game" and event.keycode==KEY_Q: _use_skill()
  elif screen=="game" and event.keycode==KEY_E: _interact()
 if event is InputEventScreenTouch:
  var p=event.position*Vector2(1280,720)/get_viewport_rect().size
  if event.pressed:
   if screen=="game" and p.x<470 and p.y>470:
    joy_id=event.index; joy_center=p; joy_knob=p
   else: _tap(p)
  elif event.index==joy_id:
   joy_id=-1; move_vec=Vector2.ZERO; joy_center=Vector2(110,600); joy_knob=joy_center
 elif event is InputEventScreenDrag and event.index==joy_id:
  joy_knob=event.position*Vector2(1280,720)/get_viewport_rect().size
  move_vec=((joy_knob-joy_center)/58).limit_length(1)
 elif event is InputEventMouseButton and event.pressed and event.button_index==MOUSE_BUTTON_LEFT:
  _tap(event.position*Vector2(1280,720)/get_viewport_rect().size)

func _tap(p:Vector2):
 if screen=="title":
  if Rect2(440,370,400,65).has_point(p): screen="character"
  elif Rect2(440,445,400,55).has_point(p): _load()
  elif Rect2(440,510,400,55).has_point(p): screen="settings"
 elif screen=="character":
  if p.y>180 and p.y<480:
   var i=clampi(int((p.x-80)/285),0,3); hero_class=["warrior","ranger","mage","rogue"][i]
  elif Rect2(420,555,440,65).has_point(p): _start()
  elif Rect2(25,25,150,55).has_point(p): screen="title"
 elif screen=="game":
  for slot in range(3):
   if _attack_slot_rect(slot).has_point(p):
    _use_learned_attack(slot)
    return
  if Rect2(990,550,120,120).has_point(p): _attack()
  elif Rect2(1110,550,150,120).has_point(p):
   if unlocked_skills.has(_class_skill_name()) and encounter_active: _use_skill()
   else: _interact()
  elif Rect2(1110,265,140,55).has_point(p): _save()
  elif Rect2(1110,325,140,55).has_point(p): screen="pause"
  elif Rect2(1110,385,140,55).has_point(p): screen="skills"
  elif Rect2(1110,445,140,55).has_point(p): screen="inventory"
  elif Rect2(1110,505,140,40).has_point(p): _use_skill()
 elif screen=="level_up":
  for slot in range(levelup_options.size()):
   if _levelup_card_rect(slot).has_point(p):
    _choose_levelup(slot)
    return
 elif screen=="home_route":
  if Rect2(285,475,330,84).has_point(p): _return_to_village()
  elif Rect2(665,475,330,84).has_point(p): _continue_expedition()
 elif screen=="pause":
  if Rect2(470,260,340,55).has_point(p): screen="game"
  elif Rect2(470,325,340,55).has_point(p): _save()
  elif Rect2(470,390,340,55).has_point(p): screen="settings"
  elif Rect2(470,455,340,55).has_point(p): screen="title"
 elif screen=="inventory":
  if Rect2(225,500,340,52).has_point(p) and inventory.get("Small Health Potion",0)>0:
   inventory["Small Health Potion"]-=1
   var potion_heal:=int(round(35.0*(1.0+float(run_stats.get("healing_bonus",0.0)))))
   hp=min(_hero_max_hp(),hp+potion_heal)
   _say("Used health potion • restored %d HP." % potion_heal)
  elif Rect2(470,580,340,60).has_point(p): screen="game"
 elif screen=="skills":
  if Rect2(330,275,620,55).has_point(p):
   var skill_name := _class_skill_name()
   if level < 2: _say("Reach level 2 to unlock " + skill_name + ".")
   elif unlocked_skills.has(skill_name): _say(skill_name + " is already unlocked. Tap Q or SPECIAL in battle.")
   elif skill_points > 0:
    skill_points -= 1
    unlocked_skills.append(skill_name)
    _say("Unlocked " + skill_name + "! Costs 15 MP in combat.")
   else: _say("Earn a skill point by leveling up.")
  elif Rect2(330,345,620,55).has_point(p) and skill_points > 0:
   skill_points-=1
   mastery_bonus_damage+=3
   _rebuild_run_stats()
   _say("Weapon mastery upgraded: +3 basic attack damage for this run.")
  elif Rect2(470,580,340,60).has_point(p): screen="game"
 elif screen=="shop":
  if Rect2(390,260,500,58).has_point(p):
   if gold>=12: gold-=12; inventory["Small Health Potion"]=inventory.get("Small Health Potion",0)+1; _say("Bought health potion.")
   else: _say("Not enough gold.")
  elif Rect2(390,350,500,58).has_point(p): _craft_home_potion()
  elif Rect2(390,440,500,58).has_point(p): _build_home_waystone()
  elif Rect2(470,580,340,60).has_point(p): screen="game"
 elif screen=="dialogue":
  if Rect2(420,420,440,65).has_point(p): quest_active=true; _say("Quest accepted: defeat three forest creatures.")
  elif Rect2(470,580,340,60).has_point(p): screen="game"
 elif screen=="villager_dialogue":
  if Rect2(420,430,440,60).has_point(p): _advance_villager_task()
  elif Rect2(470,510,340,55).has_point(p): screen="game"; talking_to=""
 elif screen=="settings":
  if Rect2(430,260,420,55).has_point(p): settings.sfx=!settings.sfx
  elif Rect2(430,325,420,55).has_point(p): settings.large_text=!settings.large_text
  elif Rect2(430,390,420,55).has_point(p): settings.music=!settings.music
  elif Rect2(470,580,340,60).has_point(p): screen="game"
 elif screen=="death":
  if Rect2(470,525,340,70).has_point(p): _start_next_run()

func _panel(r:Rect2,fill=Color("#1d2b30"),edge=Color("#b58b4f")):
 draw_rect(r,fill); draw_rect(r,edge,false,3); draw_rect(r.grow(-7),Color("#49605c"),false,1)
func _text(t:String,p:Vector2,size:=18,c:=Color("#f3e8d2"),center:=false):
 var s=size+(2 if settings.get("large_text",false) else 0); var font=ThemeDB.fallback_font
 var x=p.x-font.get_string_size(t,HORIZONTAL_ALIGNMENT_LEFT,-1,s).x/2 if center else p.x
 draw_string(font,Vector2(x,p.y),t,HORIZONTAL_ALIGNMENT_LEFT,-1,s,c)
func _button(r:Rect2,t:String,selected:=false):
 _panel(r,Color("#31443f") if selected else Color("#25343a"),Color("#d5ad68") if selected else Color("#71827a"))
 _text(t,Vector2(r.position.x+r.size.x/2,r.position.y+r.size.y/2+7),19,Color("#f3e8d2"),true)
func _draw():
 draw_rect(Rect2(0,0,1280,720),Color("#17252a"))
 match screen:
  "title":
   draw_texture_rect(preload("res://assets/ui/title_background.png"),Rect2(0,0,1280,720),false)
   _text("GREENHOLLOW",Vector2(640,180),58,Color("#e4c17d"),true)
   _text("An original fantasy RPG test demo",Vector2(640,230),23,Color("#bdd1c3"),true)
   _button(Rect2(440,370,400,65),"START NEW ADVENTURE",true)
   _button(Rect2(440,445,400,55),"CONTINUE / LOAD")
   _button(Rect2(440,510,400,55),"SETTINGS")
  "character":
   _panel(Rect2(25,25,1230,660))
   _text("CHOOSE YOUR CLASS",Vector2(640,100),36,Color("#e4c17d"),true)
   var names=["warrior","ranger","mage","rogue"]
   for i in range(4):
    var x=80+i*285; var n=names[i]
    _panel(Rect2(x,165,245,335),Color("#30443e") if n==hero_class else Color("#202f34"))
    draw_texture_rect(HERO_PORTRAITS[n],Rect2(x+85,190,75,100),false)
    _text(n.to_upper(),Vector2(x+122,320),23,Color("#e4c17d"),true)
    _text("HP %d   MP %d" % [CLASSES[n].hp, CLASSES[n].mp],Vector2(x+122,360),17,Color("#f3e8d2"),true)
    _text("Damage %d"%CLASSES[n].damage,Vector2(x+122,390),17,Color("#bdd1c3"),true)
    _text(["Heavy melee","Mobile archer","Magic damage","Agile dual blades"][i],Vector2(x+122,440),16,Color("#bdd1c3"),true)
   _button(Rect2(420,555,440,65),"ENTER GREENHOLLOW",true); _button(Rect2(25,25,150,55),"BACK")
  "game": _draw_game()
  "level_up": _draw_levelup()
  "pause":
   _panel(Rect2(360,145,560,470)); _text("PAUSED",Vector2(640,220),36,Color("#e4c17d"),true)
   _button(Rect2(470,260,340,55),"RESUME",true); _button(Rect2(470,325,340,55),"SAVE GAME")
   _button(Rect2(470,390,340,55),"SETTINGS"); _button(Rect2(470,455,340,55),"RETURN TO TITLE")
  "inventory": _draw_inventory()
  "skills":
   _panel(Rect2(250,100,780,550)); _text("SKILLS & CHARACTER",Vector2(640,155),34,Color("#e4c17d"),true)
   _panel(Rect2(295,180,690,100),Color("#26373a"),Color("#8d7850"))
   draw_texture_rect(HERO_PORTRAITS[hero_class],Rect2(305,184,66,88),false)
   draw_texture_rect(SKILL_ICONS[_skill_icon_key()],Rect2(390,194,68,68),false)
   _text("%s  •  LEVEL %d  •  %d SKILL POINT(S)" % [hero_class.to_upper(),level,skill_points],Vector2(478,207),15,Color("#bdd1c3"))
   _text(_class_skill_name(),Vector2(478,238),23,Color("#f0d087"))
   _text(_skill_description(),Vector2(478,263),15,Color("#f3e8d2"))
   var skill_unlocked:bool=unlocked_skills.has(_class_skill_name())
   var unlock_label:String="SIGNATURE UNLOCKED • PRESS Q / SPECIAL" if skill_unlocked else "UNLOCK SIGNATURE • LEVEL 2 • 1 POINT • 15 MP"
   _button(Rect2(330,290,620,55),unlock_label,true)
   _button(Rect2(330,360,620,55),"WEAPON MASTERY: +3 BASIC DAMAGE (1 POINT)")
   _text("Special moves trigger an illustrated combat burst; spend skill points here.",Vector2(640,455),16,Color("#bdd1c3"),true)
   _button(Rect2(470,580,340,60),"BACK TO GAME",true)
  "settings":
   _panel(Rect2(250,100,780,550)); _text("SETTINGS",Vector2(640,170),36,Color("#e4c17d"),true)
   _button(Rect2(430,260,420,55),"SOUND EFFECTS: %s"%("ON" if settings.sfx else "OFF"))
   _button(Rect2(430,325,420,55),"LARGE TEXT: %s"%("ON" if settings.large_text else "OFF"))
   _button(Rect2(430,390,420,55),"MUSIC: %s"%("ON" if settings.music else "OFF"))
   _button(Rect2(470,580,340,60),"BACK",true)
  "shop":
   _panel(Rect2(250,100,780,550)); _text("HOME WORKSHOP & SUPPLIES",Vector2(640,155),31,Color("#e4c17d"),true)
   _text("Safe zone • Gold: %d  •  Potion stock: %d" % [gold,int(inventory.get("Small Health Potion",0))],Vector2(640,210),18,Color("#f3e8d2"),true)
   _text("Small Health Potion • restore 35 HP • 12 gold",Vector2(640,245),16,Color("#bdd1c3"),true)
   _button(Rect2(390,260,500,58),"BUY HEALTH POTION")
   _text("Brew one: 2 Forest Herbs + 1 Oak Wood",Vector2(640,335),16,Color("#bdd1c3"),true)
   _button(Rect2(390,350,500,58),"CRAFT HEALTH POTION")
   _text("Build Waystone: 4 Rough Ore + 3 Oak Wood • +8% home chance",Vector2(640,425),15,Color("#bdd1c3"),true)
   _button(Rect2(390,440,500,58),"WAYSTONE BUILT" if waystone_built else "BUILD WAYSTONE")
   _button(Rect2(470,580,340,60),"BACK TO GAME",true)
  "dialogue":
   _panel(Rect2(230,145,820,430)); _text("ELDER OF GREENHOLLOW",Vector2(640,210),30,Color("#e4c17d"),true)
   _text("Creatures are wandering too close to the road.",Vector2(640,285),20,Color("#f3e8d2"),true)
   _text("Quest: A Quieting Forest • Defeat three creatures",Vector2(640,330),18,Color("#bdd1c3"),true)
   if quest_active: _text("Progress: %d / 3"%mini(quest_kills,3),Vector2(640,370),18,Color("#e4c17d"),true)
   _button(Rect2(420,420,440,65),"ACCEPT QUEST",true); _button(Rect2(470,580,340,60),"BACK TO GAME")
  "villager_dialogue":
   _panel(Rect2(230,145,820,450)); _text(talking_to.to_upper()+" • GREENHOLLOW",Vector2(640,215),30,Color("#e4c17d"),true)
   _text(_villager_dialogue(talking_to),Vector2(640,275),20,Color("#f3e8d2"),true)
   _text(_villager_task_summary(talking_to),Vector2(640,335),19,Color("#bdd1c3"),true)
   _text(_villager_task_progress(talking_to),Vector2(640,380),17,Color("#e4c17d"),true)
   var task_state:String=str(villager_quests.get(talking_to,"available"))
   var task_button:String="ACCEPT TASK" if task_state=="available" else ("DELIVER ITEMS" if task_state=="active" else "TASK COMPLETE")
   _button(Rect2(420,430,440,60),task_button,task_state!="complete")
   _button(Rect2(470,510,340,55),"BACK TO VILLAGE",true)
  "home_route":
   _panel(Rect2(220,120,840,500),Color("#12232a",0.98),Color("#e0bd70"))
   _text("EXPEDITION CHECKPOINT",Vector2(640,185),34,Color("#ffe193"),true)
   _text("The trail offers a rare route home. Your haul is still at risk.",Vector2(640,230),19,Color("#d5e3d6"),true)
   var haul_text:="Unbanked haul: %d gold  •  Herbs %d  •  Ore %d  •  Wood %d" % [int(expedition_loot.get("gold",0)),int(expedition_loot.get("Forest Herb",0)),int(expedition_loot.get("Rough Ore",0)),int(expedition_loot.get("Oak Wood",0))]
   _text(haul_text,Vector2(640,298),17,Color("#f0d087"),true)
   _text("SAFE RETURN banks the haul and restores you in Greenhollow.",Vector2(640,352),17,Color("#a9e3b7"),true)
   _text("CONTINUE keeps the haul unbanked; harder waves await.",Vector2(640,387),17,Color("#eaa79a"),true)
   _button(Rect2(285,455,330,84),"RETURN HOME  •  BANK HAUL",true)
   _button(Rect2(665,455,330,84),"PRESS ON  •  KEEP RISK",false)
   _text("Return chance is rolled when choosing a cardinal exit • R / C",Vector2(640,578),14,Color("#bdd1c3"),true)
  "death":
   _panel(Rect2(300,160,680,430),Color("#241b20"),Color("#9c4c4b")); _text("CHARACTER LOST",Vector2(640,260),42,Color("#d96c62"),true)
   _text("Your unbanked expedition haul is lost. Begin a new run?",Vector2(640,340),20,Color("#f3e8d2"),true)
   _button(Rect2(470,525,340,70),"START A NEW RUN",true)
 if notice_time>0 and screen not in ["title","character","level_up"] and levelup_time<=0.0:
  var notice_y := 150.0 if screen == "game" else 25.0
  _panel(Rect2(270,notice_y,740,45)); _text(notice,Vector2(640,notice_y+30),17,Color("#f0dfbd"),true)

func _elder_quest_status()->String:
 if not quest_active: return "Available • Speak with the Elder to accept"
 return "Active • Defeat forest creatures: %d / 3" % mini(quest_kills,3)

func _draw_inventory():
 _panel(Rect2(160,85,960,575)); _text("BAG & QUEST JOURNAL",Vector2(640,132),34,Color("#e4c17d"),true)
 _panel(Rect2(190,155,400,410),Color("#202f32"),Color("#71827a"))
 _panel(Rect2(610,155,480,410),Color("#202f32"),Color("#71827a"))
 _text("CARRIED ITEMS",Vector2(220,190),21,Color("#e4c17d"))
 _text("QUEST JOURNAL",Vector2(640,190),21,Color("#e4c17d"))
 _panel(Rect2(220,205,340,50),Color("#31443f"),Color("#b58b4f"))
 _text("GOLD",Vector2(245,237),16,Color("#bdd1c3"))
 _text(str(gold),Vector2(535,238),22,Color("#e4c17d"),true)
 var item_names:Array[String]=["Small Health Potion","Forest Herb","Rough Ore","Oak Wood"]
 for i in range(item_names.size()):
  var row_y := 264 + i*55
  _panel(Rect2(220,row_y,340,48),Color("#26373a"),Color("#586963"))
  _text(item_names[i],Vector2(238,row_y+30),17,Color("#f3e8d2"))
  _text("× %d" % int(inventory.get(item_names[i],0)),Vector2(535,row_y+30),18,Color("#e4c17d"),true)
 var potion_count:int=int(inventory.get("Small Health Potion",0))
 _button(Rect2(220,500,340,52),"USE HEALTH POTION (%d)" % potion_count,potion_count>0)
 _quest_card(Rect2(630,205,440,85),"ELDER • QUIETING FOREST",_elder_quest_status())
 _quest_card(Rect2(630,310,440,85),"MIRA • VILLAGE REMEDIES",_villager_task_progress_for("Mira"))
 _quest_card(Rect2(630,415,440,85),"TOMAS • ROAD SIGNPOSTS",_villager_task_progress_for("Tomas"))
 var attack_summary:=", ".join(attack_slots) if not attack_slots.is_empty() else "none learned"
 _text("ATTACKS: "+attack_summary,Vector2(850,526),11,Color("#f0d087"),true)
 var travel_summary:="DEPTH %d • HOME %.0f%% • HAUL %dG" % [expedition_depth,_homeward_chance()*100.0,int(expedition_loot.get("gold",0))] if expedition_active else ("WAYSTONE BUILT • +8%% HOME CHANCE" if waystone_built else "GREENHOLLOW SAFE • BUILD A WAYSTONE")
 _text(travel_summary,Vector2(850,548),10,Color("#bdd1c3"),true)
 _button(Rect2(470,580,340,60),"BACK TO GAME",true)

func _villager_task_progress_for(villager_name:String)->String:
 var state:String=str(villager_quests.get(villager_name,"available"))
 var task:Dictionary=_villager_task(villager_name)
 if state=="available": return "Available • Bring %d %s • %d gold" % [int(task.amount),str(task.item),int(task.reward)]
 if state=="complete": return "Completed • Reward claimed"
 var have:int=int(inventory.get(str(task.item),0))
 return "Active • %s: %d / %d" % [str(task.item),have,int(task.amount)]

func _quest_card(rect:Rect2,title:String,status:String):
 _panel(rect,Color("#26373a"),Color("#586963"))
 _text(title,Vector2(rect.position.x+16,rect.position.y+31),16,Color("#e4c17d"))
 var status_color:=Color("#84ce9a") if status.begins_with("Completed") else (Color("#e8cb80") if status.begins_with("Active") else Color("#bdd1c3"))
 _text(status,Vector2(rect.position.x+16,rect.position.y+61),15,status_color)

func _draw_levelup():
 _panel(Rect2(95,75,1090,570),Color("#101d2b",0.98),Color("#e0bd70"))
 draw_texture_rect(HERO_PORTRAITS[hero_class],Rect2(126,92,64,84),false)
 _text("LEVEL %d  •  CHOOSE ONE PICK" % level,Vector2(640,133),31,Color("#ffe193"),true)
 _text("%d LEVEL PICK(S) READY • Three randomized upgrades • Tap, click or press 1–3" % maxi(1,pending_levelup_count),Vector2(640,172),15,Color("#bdd1c3"),true)
 var rarity_colors:Dictionary={"common":Color("#8da99a"),"rare":Color("#69b5e8"),"epic":Color("#ca88ef")}
 var category_colors:Dictionary={"offense":Color("#db805a"),"defense":Color("#6ca8db"),"mobility":Color("#81c67f"),"utility":Color("#e4be6b"),"build":Color("#c88ee0"),"ability":Color("#71d8d2")}
 for slot in range(mini(3,levelup_options.size())):
  var card_rect:Rect2=_levelup_card_rect(slot)
  var offer:Dictionary=levelup_options[slot]
  var card_id:=str(offer.get("id",""))
  var data:Dictionary=upgrade_catalog.get_card(card_id)
  var category:=str(data.get("category","offense"))
  var rarity:=str(data.get("rarity","common"))
  var hovered:=card_rect.has_point(pointer_pos)
  _panel(card_rect,Color("#30494b") if hovered else Color("#25383a"),Color("#ffe193") if hovered else rarity_colors.get(rarity,Color("#d5ad68")))
  draw_circle(Vector2(card_rect.position.x+card_rect.size.x*0.5,card_rect.position.y+58),31,category_colors.get(category,Color("#8da99a")))
  draw_arc(Vector2(card_rect.position.x+card_rect.size.x*0.5,card_rect.position.y+58),32,0,TAU,40,rarity_colors.get(rarity,Color("#d5ad68")),3.0)
  _text(category.substr(0,1).to_upper(),Vector2(card_rect.position.x+card_rect.size.x*0.5,card_rect.position.y+67),27,Color("#102027"),true)
  _text(str(data.get("name",card_id)),Vector2(card_rect.position.x+card_rect.size.x*0.5,card_rect.position.y+112),18,Color("#f3e8d2"),true)
  var rank_label:="NEW ABILITY" if bool(data.get("active",false)) else "%s • RANK %d/%d" % [rarity.to_upper(),int(upgrade_ranks.get(card_id,0))+1,int(data.get("max_rank",1))]
  _text(rank_label,Vector2(card_rect.position.x+card_rect.size.x*0.5,card_rect.position.y+137),11,rarity_colors.get(rarity,Color("#e5c678")),true)
  var description_lines:=_wrap_upgrade_text(str(data.get("description","")),31)
  for line_index in range(mini(3,description_lines.size())):
   _text(description_lines[line_index],Vector2(card_rect.position.x+card_rect.size.x*0.5,card_rect.position.y+166+line_index*18),12,Color("#bdd1c3"),true)
  var effect_lines:=_wrap_upgrade_text(_upgrade_effect_summary(data),33)
  for line_index in range(mini(2,effect_lines.size())):
   _text(effect_lines[line_index],Vector2(card_rect.position.x+card_rect.size.x*0.5,card_rect.position.y+225+line_index*17),11,Color("#f0d087"),true)
  _button(Rect2(card_rect.position.x+36,card_rect.position.y+277,218,42),"CHOOSE  •  %d" % (slot+1),hovered)
 _text("Your build persists through the expedition. Pick one to resume combat.",Vector2(640,605),16,Color("#f0dfbd"),true)

func _wrap_upgrade_text(value:String,max_chars:int)->Array[String]:
 var lines:Array[String]=[]
 var current:=""
 for word in value.split(" "):
  if current.is_empty(): current=word
  elif current.length()+word.length()+1<=max_chars: current+=" "+word
  else:
   lines.append(current); current=word
 if not current.is_empty(): lines.append(current)
 return lines

func _draw_game():
 var ground_color := Color("#38523b")
 match area_id:
  "forest": ground_color=Color("#243b2b")
  "north": ground_color=Color("#4a6140")
  "south": ground_color=Color("#66543d")
  "west": ground_color=Color("#354c3a")
  "ruins": ground_color=Color("#4b4b40")
 draw_rect(Rect2(0,0,1280,720),ground_color)
 for x in range(0,1280,64):
  for y in range(0,720,64):
   var tile:Texture2D = GRASS
   var tx := x + 32
   var ty := y + 32
   if area_id in ["forest","ruins"]: tile=MOSS if (x*7+y*3)%11<3 else GRASS
   elif area_id == "north": tile=GRASS
   elif area_id == "south": tile=GRASS
   elif area_id == "west": tile=MOSS
   if area_id == "village" and ty > 290 and ty < 430:
    tile=COBBLE if (x/64)%3!=1 else DIRT
   elif area_id in ["north", "south", "west"] and ty > 325 and ty < 420:
    tile=SAND if (x/64)%4==0 else DIRT
   elif area_id == "ruins" and tx > 680 and tx < 940 and ty > 150 and ty < 390:
    tile=COBBLE
   elif area_id == "forest" and ((x * 7 + y * 3) % 11 < 3):
    tile=MOSS
   elif area_id == "south" and (x * 5 + y * 9) % 17 < 2:
    tile=SAND
   draw_texture_rect(tile,Rect2(x,y,64,64),false)
 # Layered ground dressing adds depth while remaining light enough for mobile.
 for i in range(95):
  var gx := float((i * 137 + 41) % 1270)
  var gy := float((i * 83 + 27) % 700)
  if Rect2(360,150,570,190).has_point(Vector2(gx,gy)): continue
  if gy > 305 and gy < 420: continue
  draw_circle(Vector2(gx+3,gy+1),2.0,Color("#253f2c",0.42))
  if i % 3 == 0:
   draw_line(Vector2(gx+3,gy),Vector2(gx+1,gy-5),Color("#91a965",0.7),1.5)
 # Each screen has its own path language and landmark silhouette.
 if area_id == "village":
  draw_rect(Rect2(0,301,1280,118),Color("#6f583f")); draw_rect(Rect2(0,307,1280,103),Color("#a88a63"))
  draw_line(Vector2(0,311),Vector2(1280,311),Color("#d0b184",0.7),2); draw_line(Vector2(0,405),Vector2(1280,405),Color("#72583f",0.8),2)
  for i in range(32):
   var rx := float(i * 43 + 12)
   draw_line(Vector2(rx,330 + (i % 4) * 15),Vector2(rx+12,332 + (i % 4) * 15),Color("#80684d",0.55),2)
  # Textured flagstone court stitches the homes into the central road without a flat slab.
  for court_x in range(330,950,64):
   for court_y in range(145,340,64):
    draw_texture_rect(COBBLE,Rect2(court_x,court_y,64,64),false)
  # Short fence runs frame garden edges but leave the road and NPC approaches open.
  _fence_run(Vector2(34,285),Vector2(244,285))
  _fence_run(Vector2(1010,285),Vector2(1246,285))
  _fence_run(Vector2(34,430),Vector2(154,430))
  _fence_run(Vector2(1090,430),Vector2(1246,430))
  _flower_patch(Vector2(280,240),9)
  _flower_patch(Vector2(972,220),9)
  _flower_patch(Vector2(240,515),12)
  _flower_patch(Vector2(880,500),10)
  _flower_patch(Vector2(1182,535),10)
  _draw_art_sprite(Rect2(158,390,128,119),Rect2(232,222,66,62))
  _draw_art_sprite(Rect2(158,390,128,119),Rect2(970,218,66,62))
  _draw_art_sprite(Rect2(480,395,116,110),Rect2(44,432,92,76))
  _draw_art_sprite(Rect2(480,395,116,110),Rect2(1135,430,92,76))
  _building(Vector2(390,178),"BLACKSMITH",Color("#8d5144")); _building(Vector2(745,178),"HERBALIST",Color("#507b5b")); _building(Vector2(585,120),"ELDER HALL",Color("#927447"))
  draw_texture_rect(MARKET,Rect2(140,205,126,92),false)
  draw_texture_rect(WELL,Rect2(1000,240,82,86),false)
  _lamp(Vector2(300,285)); _lamp(Vector2(960,285)); _lamp(Vector2(202,390)); _lamp(Vector2(1080,390))
 elif area_id in ["forest", "ruins"]:
  draw_rect(Rect2(0,0,1280,720),Color("#20382a",0.22))
  # Winding trail, mossy stones and dense tree lines frame the playable clearing.
  for i in range(11):
   var trail_start:=Vector2(640.0+sin(float(i)*0.62)*128.0,90.0+i*52.0)
   var trail_end:=Vector2(640.0+sin(float(i+1)*0.62)*128.0,90.0+(i+1)*52.0)
   draw_line(trail_start,trail_end,Color("#5b6040",0.75),26)
   draw_line(trail_start,trail_end,Color("#8b8059",0.65),18)
  for i in range(16):
   var tx := 40.0 + float(i)*80.0
   if i%2==0:
    var forest_tree:Texture2D = PINE if i % 4 == 0 else TREE
    draw_texture(forest_tree,Vector2(tx,45+(i%3)*16)); draw_texture(AUTUMN_TREE if i % 4 == 2 else PINE,Vector2(tx+18,575+(i%4)*17))
  if area_id == "forest":
   draw_texture_rect(CAMPFIRE,Rect2(560,455,84,58),false)
   _draw_art_sprite(Rect2(1255,26,116,145),Rect2(48,382,150,190))
   _draw_art_sprite(Rect2(870,204,120,155),Rect2(1000,478,76,96))
  if area_id == "ruins":
   draw_texture_rect(RUIN_ARCH,Rect2(730,150,245,158),false)
   for p in [Vector2(760,310),Vector2(850,315),Vector2(690,355),Vector2(930,350)]:
    draw_texture(STONE,p-Vector2(24,24))
 else:
  draw_rect(Rect2(0,325,1280,90),Color("#756044")); draw_rect(Rect2(0,333,1280,74),Color("#a58a62"))
  for i in range(9): draw_circle(Vector2(160+i*120,370+(i%3)*9),3,Color("#d3bd8a",0.6))
 var tree_points = [Vector2(85,160),Vector2(170,120),Vector2(280,210),Vector2(1060,150),Vector2(1160,215),Vector2(1140,440),Vector2(160,470),Vector2(250,550),Vector2(990,570),Vector2(1080,625)]
 if area_id in ["forest", "ruins"]:
  tree_points = [Vector2(80,130),Vector2(180,210),Vector2(300,105),Vector2(390,590),Vector2(1000,120),Vector2(1150,180),Vector2(1120,560),Vector2(950,625),Vector2(180,630),Vector2(40,430),Vector2(1220,400)]
 for idx in range(tree_points.size()):
  var p:Vector2 = tree_points[idx]
  draw_circle(p+Vector2(0,24),19,Color(0.03,0.08,0.04,0.35))
  var tree_source := Rect2(14,180,156,196)
  if area_id in ["north","west"] and idx%2==0: tree_source=Rect2(181,180,148,198)
  elif area_id=="south" and idx%3==0: tree_source=Rect2(480,180,144,197)
  elif area_id in ["forest","ruins"] and idx%2==0: tree_source=Rect2(181,180,148,198)
  elif area_id=="forest" and idx%5==1: tree_source=Rect2(626,180,135,198)
  _draw_art_sprite(tree_source,Rect2(p.x-47,p.y-104,94,120))
 _draw_xp_pickups()
 draw_circle(Vector2(320,485),16,Color("#b4d27a")); draw_circle(Vector2(320,485),8,Color("#6c9b4e"))
 draw_circle(Vector2(1060,510),17,Color("#7d8582")); draw_circle(Vector2(1060,510),9,Color("#c4c8b7"))
 if area_id == "village":
  _panel(Rect2(910,420,38,34),Color("#986b3d"),Color("#e2bc73"))
  _npc(Vector2(630,230),Color("#d4b071"),"ELDER"); _npc(Vector2(460,265),Color("#9c6c51"),"SMITH"); _npc(Vector2(810,265),Color("#76a77a"),"HERB")
  for villager in villagers:
   var villager_pos:Vector2=villager["pos"]
   var villager_color:Color=villager["color"]
   _npc(villager_pos,villager_color,str(villager["name"]).to_upper())
 elif area_id in ["forest", "ruins"]:
  draw_rect(Rect2(430,90,420,540),Color("#b7c77c",0.06),false,2)
 for e in enemies:
  var enemy_bob:=sin(world_anim_clock*4.0+e.pos.x*0.04)*2.5
  if e.kind=="slime":
   var squash:=sin(world_anim_clock*5.0+e.pos.x*0.03)*3.0
   _draw_art_sprite(Rect2(1100,585,135,90),Rect2(e.pos.x-29,e.pos.y-25-enemy_bob,58,48+squash))
  else:
   draw_texture_rect(ENEMY_TEXTURES[e.kind],Rect2(e.pos.x-24,e.pos.y-28-enemy_bob,48,56),false)
  draw_rect(Rect2(e.pos.x-22,e.pos.y-36,44,5),Color("#302d2b"))
  draw_rect(Rect2(e.pos.x-22,e.pos.y-36,44*maxf(0,float(e.hp)/e.max_hp),5),Color("#d75c52"))
 if area_id in ["forest","ruins"]:
  for i in range(4):
   var wisp_pos:=Vector2(320.0+i*205.0,245.0+sin(world_anim_clock*1.4+float(i)*1.7)*24.0)
   _draw_spirit_wisp(wisp_pos)
 var frame:=int(walk_clock*8.0)%4 if hero_is_moving else 0
 _draw_character_sprite(hero_class,hero,frame,attack_flash>0.0 or skill_flash>0.0,Vector2(64,80))
 if skill_flash > 0.0: _draw_ability_effect()
 _draw_ambient_lighting()
 _draw_hud()
 _panel(Rect2(475,15,330,50),Color("#101f2c",0.94),Color("#c69b58"))
 var area_title: String = {"village":"GREENHOLLOW VILLAGE","forest":"WHISPERWOOD FOREST","north":"NORTHWATCH TRAIL","south":"THE OLD ROAD","west":"MOSSY CROSSING","ruins":"SUNKEN RUINS"}.get(area_id,"GREENHOLLOW")
 _text(area_title,Vector2(640,38),16,Color("#f4d184"),true)
 _text(_time_of_day_label(),Vector2(640,55),11,Color("#bdd1c3"),true)
 if encounter_active: _text("COMBAT ACTIVE",Vector2(1010,430),15,Color("#ffcc83"),true)
 if unlocked_skills.has(_class_skill_name()): _text(("SPECIAL READY" if skill_cooldown <= 0.0 else "RECHARGE %.1fs" % skill_cooldown),Vector2(1180,535),13,Color("#8ce7f0"),true)
 _button(Rect2(1110,265,140,55),"SAVE"); _button(Rect2(1110,325,140,55),"PAUSE")
 _button(Rect2(1110,385,140,55),"SKILLS"); _button(Rect2(1110,445,140,55),"BAG")
 if unlocked_skills.has(_class_skill_name()):
  _button(Rect2(1110,505,140,40),"",true)
  draw_texture_rect(SKILL_ICONS[_skill_icon_key()],Rect2(1117,510,28,28),false)
  _text("SPECIAL (Q)",Vector2(1190,530),13,Color("#f3e8d2"),true)
 else: _button(Rect2(1110,505,140,40),"SPECIAL (Q)",false)
 draw_circle(joy_center if joy_id>=0 else Vector2(110,600),48,Color(0.07,0.12,0.13,0.7))
 draw_arc(joy_center if joy_id>=0 else Vector2(110,600),48,0,TAU,40,Color("#c4c3a5"),2)
 draw_circle(joy_knob if joy_id>=0 else Vector2(110,600),19,Color(0.75,0.79,0.69,0.85))
 _button(Rect2(990,550,120,120),"ATTACK",true)
 if unlocked_skills.has(_class_skill_name()):
  _button(Rect2(1110,550,150,120),"",true)
  draw_texture_rect(SKILL_ICONS[_skill_icon_key()],Rect2(1162,565,48,48),false)
  _text("SPECIAL",Vector2(1185,642),15,Color("#f3e8d2"),true)
 else: _button(Rect2(1110,550,150,120),"INTERACT")
 _draw_attack_hotbar()
 var n=_nearest()
 if n!="": _panel(Rect2(455,500,360,38)); _text("NEARBY: %s • INTERACT"%n,Vector2(635,525),15,Color("#f0dfbd"),true)
 for f in floats: _text(f.text,f.pos,18,f.color,true)
 if levelup_time>0.0: _draw_levelup_banner()

func _draw_attack_hotbar():
 for slot in range(3):
  var rect:Rect2=_attack_slot_rect(slot)
  var has_attack:=slot<attack_slots.size()
  _panel(rect,Color("#21323a",0.94),Color("#c59a5a") if has_attack else Color("#56645f"))
  if not has_attack:
   _text("EMPTY",Vector2(rect.position.x+rect.size.x*0.5,rect.position.y+52),12,Color("#98aaa0"),true)
   _text("LEVEL UP",Vector2(rect.position.x+rect.size.x*0.5,rect.position.y+73),10,Color("#748780"),true)
   continue
  var attack_id:=attack_slots[slot]
  var data:Dictionary=LEVELUP_ATTACKS[attack_id]
  draw_texture_rect(SKILL_ICONS[str(data["icon"])],Rect2(rect.position.x+28,rect.position.y+7,34,34),false)
  _text(attack_id.to_upper(),Vector2(rect.position.x+rect.size.x*0.5,rect.position.y+59),10,Color("#f3e8d2"),true)
  _text("R%d • %dMP" % [int(attack_ranks.get(attack_id,1)),int(data["cost"])],Vector2(rect.position.x+rect.size.x*0.5,rect.position.y+80),10,Color("#bdd1c3"),true)
  var cooldown:=float(attack_cooldowns.get(attack_id,0.0))
  if cooldown>0.0:
   draw_rect(rect,Color("#08141a",0.70))
   _text("%.1fs" % cooldown,Vector2(rect.position.x+rect.size.x*0.5,rect.position.y+54),17,Color("#ffe193"),true)

func _draw_xp_pickups():
 for gem in xp_pickups:
  var phase:=float(gem.get("phase",0.0))
  var base_pos:Vector2=gem.get("pos",Vector2.ZERO)
  var pos:=base_pos+Vector2(0.0,sin(world_anim_clock*4.8+phase)*3.0)
  var nearby:bool=base_pos.distance_to(hero)<124.0
  var glow_alpha:=0.17+0.08*(sin(world_anim_clock*5.0+phase)+1.0)
  draw_circle(pos,13.0 if nearby else 10.0,Color("#43d9ff",glow_alpha))
  var gem_points:=PackedVector2Array([pos+Vector2(0,-9),pos+Vector2(7,-2),pos+Vector2(5,6),pos+Vector2(0,10),pos+Vector2(-5,6),pos+Vector2(-7,-2)])
  draw_colored_polygon(gem_points,Color("#62eaff"))
  draw_line(pos+Vector2(0,-8),pos+Vector2(0,8),Color("#fff1ab",0.92),2.0)
  draw_line(pos+Vector2(-5,-2),pos+Vector2(5,-2),Color("#dcfbff",0.82),1.0)

func _draw_ability_effect():
 var progress:=1.0-skill_flash/0.35
 var radius:=38.0+progress*150.0
 var palettes:Dictionary={"warrior":Color("#ffc45d"),"ranger":Color("#95e484"),"mage":Color("#63dafa"),"rogue":Color("#bf83f1")}
 var icon_key:=hero_class
 if LEVELUP_ATTACKS.has(active_attack_id): icon_key=str(LEVELUP_ATTACKS[active_attack_id]["icon"])
 var burst_color:Color=palettes.get(icon_key,Color("#82e9e6"))
 burst_color.a=clampf(skill_flash*2.2,0.0,0.82)
 draw_arc(hero,radius,0.0,TAU,48,burst_color,5.0)
 draw_arc(hero,radius*0.66,-progress*TAU,TAU-progress*TAU,36,Color("#e6d29a",burst_color.a*0.7),2.0)
 var icon_size:=36.0+progress*24.0
 var icon_y:=hero.y-80.0-progress*42.0
 var fade:=clampf(skill_flash*3.5,0.0,1.0)
 draw_texture_rect(SKILL_ICONS[icon_key],Rect2(hero.x-icon_size*0.5,icon_y-icon_size*0.5,icon_size,icon_size),false,Color(1.0,1.0,1.0,fade))

func _draw_levelup_banner():
 _panel(Rect2(410,78,460,88),Color("#122638",0.97),Color("#e2bd68"))
 draw_texture_rect(SKILL_ICONS[_skill_icon_key()],Rect2(425,92,58,58),false)
 _text("LEVEL UP  •  LEVEL %d" % level,Vector2(500,112),22,Color("#ffe193"))
 _text("+10 MAX HP   •   +5 MAX MP   •   1 SKILL POINT",Vector2(500,142),14,Color("#d4e3d7"))

func _bar(r:Rect2,v:float,c:Color):
 draw_rect(r,Color("#2c3435")); draw_rect(Rect2(r.position,Vector2(r.size.x*clampf(v,0,1),r.size.y)),c)

func _draw_hud():
 _panel(Rect2(14,12,360,128),Color("#101d2b",0.96),Color("#c89d59"))
 _panel(Rect2(21,20,64,86),Color("#263b45"),Color("#8c774e"))
 draw_texture_rect(HERO_PORTRAITS[hero_class],Rect2(25,22,56,78),false)
 _text(hero_name,Vector2(96,38),19,Color("#f1e6cf"))
 _text("%s  •  LEVEL %d" % [hero_class.to_upper(),level],Vector2(96,57),12,Color("#d9bd7a"))
 _bar(Rect2(96,65,240,13),float(hp)/float(_hero_max_hp()),Color("#d35d58"))
 _text("HP %d / %d" % [hp,_hero_max_hp()],Vector2(100,76),10,Color("#fff1df"))
 _bar(Rect2(96,82,240,11),float(mp)/float(_hero_max_mp()),Color("#60a8d7"))
 _text("MP %d / %d" % [mp,_hero_max_mp()],Vector2(100,91),10,Color("#edf3fa"))
 _bar(Rect2(96,101,240,9),float(xp)/float(maxi(1,xp_next)),Color("#55d8e7"))
 _text("XP %d / %d  •  GEMS %d" % [xp,xp_next,xp_pickups.size()],Vector2(96,124),10,Color("#bdeffc"))
 _text("◈ %d" % gold,Vector2(350,124),13,Color("#f4d17e"),true)
 _panel(Rect2(874,12,392,150),Color("#101d2b",0.96),Color("#9c8451"))
 var title_text:="EXPEDITION • DEPTH %d • BEST %d" % [expedition_depth,best_depth] if expedition_active else "FIELD JOURNAL • BEST DEPTH %d" % best_depth
 _text(title_text,Vector2(894,37),13,Color("#f1d28a"))
 draw_line(Vector2(894,45),Vector2(1245,45),Color("#c89d59",0.55),1)
 var wave_text:=_wave_status_text()
 var wave_color:=Color("#ffcf80") if wave_director.phase in ["warning","checkpoint"] else Color("#cfe1d5")
 if wave_director.phase in ["warning","spawning"] and bool(wave_director.wave_spec(wave_director.wave_number).get("boss",false)): wave_color=Color("#ff8277")
 _text(wave_text,Vector2(894,65),12,wave_color)
 if expedition_active:
  var total_left:=wave_director.remaining_total(enemies.size())
  var cleared:=maxi(0,wave_director.total_enemies-total_left)
  _bar(Rect2(894,73,351,7),float(cleared)/float(maxi(1,wave_director.total_enemies)),Color("#d66d54") if wave_color==Color("#ff8277") else Color("#d4aa61"))
  var supplies_count:=int(expedition_loot.get("Forest Herb",0))+int(expedition_loot.get("Rough Ore",0))+int(expedition_loot.get("Oak Wood",0))
  _text("UNBANKED %dG • %d SUPPLIES • DEATH RISKS HAUL" % [int(expedition_loot.get("gold",0)),supplies_count],Vector2(894,99),11,Color("#edc982"))
  _text(_active_quest_line(),Vector2(894,120),11,Color("#f1ead9"))
  _text("XP ON GROUND %d  •  ENEMIES %d" % [_xp_pickup_total(),enemies.size()],Vector2(894,143),10,Color("#8feafa"))
 else:
  _text("BANKED %dG • FALLS %d • WAYSTONE %s" % [gold,runs_lost,"BUILT" if waystone_built else "NOT BUILT"],Vector2(894,99),11,Color("#a9c5c0"))
  _text(_active_quest_line(),Vector2(894,120),11,Color("#f1ead9"))
  _text("XP ON GROUND %d" % _xp_pickup_total(),Vector2(894,143),10,Color("#8feafa"))
 if expedition_active and wave_director.phase=="warning" and bool(wave_director.wave_spec(wave_director.wave_number).get("boss",false)):
  _panel(Rect2(444,171,392,42),Color("#401f26",0.97),Color("#f15f56"))
  _text("BOSS WARNING • WAVE %02d • %.1fs" % [wave_director.wave_number,wave_director.timer],Vector2(640,198),17,Color("#ffe1b1"),true)
 elif expedition_active and wave_director.phase=="warning":
  _panel(Rect2(444,171,392,42),Color("#3a2620",0.94),Color("#e69056"))
  _text("INCOMING • WAVE %02d • %.1fs" % [wave_director.wave_number,wave_director.timer],Vector2(640,198),18,Color("#ffe193"),true)
 elif expedition_active and bool(wave_director.wave_spec(wave_director.wave_number).get("boss",false)) and wave_director.phase=="spawning":
  _panel(Rect2(444,171,392,42),Color("#401f26",0.96),Color("#f15f56"))
  _text("BOSS MILESTONE • WAVE %02d • ENEMIES %d" % [wave_director.wave_number,enemies.size()],Vector2(640,198),16,Color("#ffe1b1"),true)

func _wave_status_text()->String:
 if not expedition_active: return "NO ACTIVE EXPEDITION • ENTER THE WILDS TO START"
 var remaining:=wave_director.remaining_total(enemies.size())
 match wave_director.phase:
  "warning": return "WAVE %02d • INCOMING IN %.1fs • %d ENEMIES" % [wave_director.wave_number,wave_director.timer,remaining]
  "spawning": return "WAVE %02d • LIVE • %d LEFT • %d TO SPAWN" % [wave_director.wave_number,remaining,wave_director.enemies_to_spawn]
  "pause": return "WAVE %02d CLEAR • NEXT IN %.1fs" % [wave_director.wave_number,wave_director.timer]
  "checkpoint": return "WAVE %02d CLEAR • CHECKPOINT CHOICE READY" % wave_director.wave_number
 return "EXPEDITION READY • WAVE %02d" % wave_director.wave_number

func _active_quest_line()->String:
 if quest_active and quest_kills>=3: return "Return to the Elder in Greenhollow"
 if quest_active: return "Elder's request  •  %d / 3 creatures" % mini(quest_kills,3)
 if villager_quests.get("Mira","available")=="active": return "Mira's remedies  •  %d / 2 herbs" % int(inventory.get("Forest Herb",0))
 if villager_quests.get("Tomas","available")=="active": return "Tomas's signposts  •  %d / 2 wood" % int(inventory.get("Oak Wood",0))
 return "XP shards pull close • explore onward for more"

func _draw_art_sprite(source_rect:Rect2,destination_rect:Rect2,tint:=Color.WHITE):
 draw_texture_rect_region(PIXEL_ART,destination_rect,source_rect,tint,false)

func _character_frame_rect(actor_class:String,frame:int,attacking:bool)->Rect2:
 var layout:Dictionary=CHARACTER_FRAME_LAYOUT.get(actor_class,CHARACTER_FRAME_LAYOUT["ranger"])
 var source_y:=int(layout["attack_y"] if attacking else layout["walk_y"])
 var source_x:=int(layout["x"])+posmod(frame,4)*int(layout["step"])
 return Rect2(source_x,source_y,int(layout["width"]),int(layout["height"]))

func _draw_character_sprite(actor_class:String,center:Vector2,frame:int,attacking:bool,size:Vector2):
 _draw_art_sprite(_character_frame_rect(actor_class,frame,attacking),Rect2(center-size*0.5,size))

func _draw_spirit_wisp(pos:Vector2):
 var pulse:=sin(world_anim_clock*4.0+pos.x*0.03)
 var glow:=0.10+0.04*(pulse+1.0)
 var sprite_size:=34.0+4.0*(pulse+1.0)
 draw_circle(pos,26+3*pulse,Color("#7dffcb",glow))
 draw_circle(pos,15+2*pulse,Color("#7dffcb",glow+0.05))
 _draw_art_sprite(Rect2(1100,585,135,90),Rect2(pos.x-sprite_size*0.5,pos.y-sprite_size*0.45,sprite_size,sprite_size*0.9),Color(0.74,1.0,0.87,0.82))

func _fence_run(start:Vector2,finish:Vector2):
 var span := finish.x - start.x
 draw_line(start+Vector2(0,3),finish+Vector2(0,3),Color("#30291d",0.35),8)
 draw_line(start+Vector2(0,-5),finish+Vector2(0,-5),Color("#704725"),5)
 draw_line(start+Vector2(0,4),finish+Vector2(0,4),Color("#8b5c30"),5)
 var post_count := int(span / 28.0)
 for i in range(post_count+1):
  var x := start.x + minf(float(i)*28.0,span)
  draw_line(Vector2(x,start.y-12),Vector2(x,start.y+11),Color("#55371f"),6)
  draw_line(Vector2(x-2,start.y-12),Vector2(x+2,start.y-12),Color("#c29453"),2)

func _flower_patch(center:Vector2,count:int):
 _flower_patch_base(center)
 var petals := [Color("#f1d16e"),Color("#db8f79"),Color("#d9c2e2"),Color("#f3e5bf")]
 for i in range(count):
  var x := center.x + float((i*17)%43) - 21.0
  var y := center.y + float((i*11)%25) - 12.0
  var stem_top := Vector2(x,y-4)
  draw_line(Vector2(x,y+4),stem_top,Color("#48633b"),1.5)
  draw_circle(stem_top,3.2,petals[i%petals.size()])
  draw_circle(stem_top+Vector2(0,1),1.1,Color("#80663a"))

func _flower_patch_base(center:Vector2):
 draw_circle(center+Vector2(0,4),25,Color("#344a2e",0.35))
 draw_circle(center,23,Color("#587545"))
 draw_arc(center,22,0.0,TAU,24,Color("#829558",0.8),2)

func _lamp(pos:Vector2):
 draw_circle(pos+Vector2(0,3),17,Color("#f2c36c",0.10))
 draw_circle(pos+Vector2(0,16),8,Color("#2d3429",0.55))
 draw_rect(Rect2(pos.x-3,pos.y-12,6,27),Color("#4d4030"))
 draw_rect(Rect2(pos.x-9,pos.y-19,18,11),Color("#3f382d"))
 draw_rect(Rect2(pos.x-6,pos.y-16,12,6),Color("#f0c76c"))
 draw_rect(Rect2(pos.x-11,pos.y-22,22,4),Color("#69513a"))
 draw_rect(Rect2(pos.x-8,pos.y-25,16,3),Color("#b39158"))
 draw_rect(Rect2(pos.x-7,pos.y+14,14,4),Color("#5a4933"))

func _draw_ambient_lighting():
 var daylight := clampf(0.5 + 0.5*cos((time_of_day - 0.5) * TAU),0.0,1.0)
 var night_strength := 1.0 - daylight
 var twilight := clampf(1.0 - absf(daylight - 0.45) / 0.45,0.0,1.0)
 if night_strength > 0.01:
  draw_rect(Rect2(0,0,1280,720),Color("#172342",night_strength * 0.52))
 if twilight > 0.01:
  draw_rect(Rect2(0,0,1280,720),Color("#bd7955",twilight * 0.075))
 if area_id == "village":
  var glow_strength := lerpf(0.08,0.95,night_strength)
  for pos in [Vector2(300,285),Vector2(960,285),Vector2(202,390),Vector2(1080,390)]:
   _draw_lantern_glow(pos + Vector2(0,-14),glow_strength)

func _draw_lantern_glow(center:Vector2,strength:float):
 draw_circle(center,94,Color("#f4a94f",0.035*strength))
 draw_circle(center,68,Color("#f6b95c",0.055*strength))
 draw_circle(center,45,Color("#ffd071",0.09*strength))
 draw_circle(center,25,Color("#ffdb82",0.15*strength))
 draw_circle(center,11,Color("#ffe6a0",0.30*strength))
 draw_circle(center,4,Color("#fff0bb",0.72*strength))

func _time_of_day_label() -> String:
 if time_of_day < 0.21 or time_of_day >= 0.78: return "NIGHT"
 if time_of_day < 0.29: return "DAWN"
 if time_of_day < 0.69: return "DAY"
 return "DUSK"

func _building(p:Vector2,label:String,roof:Color):
 var building_source := Rect2(930,798,276,210) if label == "ELDER HALL" else Rect2(660,812,270,195)
 var building_rect := Rect2(p.x-94,p.y-61,188,136)
 _draw_art_sprite(building_source,building_rect)
 _text(label,Vector2(building_rect.position.x+building_rect.size.x/2.0,building_rect.position.y+8),13,Color("#f3e8d2"),true)
func _npc(p:Vector2,c:Color,label:String):
 var npc_classes:Dictionary={"ELDER":"mage","SMITH":"warrior","HERB":"ranger","MIRA":"ranger","TOMAS":"rogue"}
 var npc_class:String=str(npc_classes.get(label,"ranger"))
 var frame:=0
 if label in ["MIRA","TOMAS"]:
  for villager in villagers:
   if str(villager["name"]).to_upper()==label:
    var route:Array=villager["path"]
    var target:Vector2=route[int(villager["target_index"])%route.size()]
    if float(villager.get("wait",0.0))<=0.0 and Vector2(villager["pos"]).distance_to(target)>3.0:
     frame=int(world_anim_clock*7.0)%4
    break
 draw_circle(p+Vector2(0,15),15,Color(0,0,0,0.32))
 _draw_character_sprite(npc_class,p+Vector2(0,2),frame,false,Vector2(48,58))
 _text(label,p+Vector2(0,-39),11,Color("#f3e8d2"),true)
