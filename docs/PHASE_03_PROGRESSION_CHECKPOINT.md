# Greenhollow RPG — Phase 03 Progression Checkpoint

**Date:** 2026-10-28  
**Checkpoint:** Phase 03 — XP pickups, level choices and retry progression  
**Engine:** Godot 4.7.2 stable  
**Project status:** Godot source demo; Android APK not exported

## Gameplay delivered

Every enemy defeat now creates a visible XP gem at the enemy's location instead of granting XP immediately. Walk near a gem and it magnetizes toward the player; collect it to fill the XP meter. The HUD shows current XP, XP needed for the next level, the number of loose gems and their unclaimed XP total. Gems bob, glow and show an XP-drop notification.

Each level pauses play and presents three distinct random attack choices. A new attack fills an available hotbar slot; once all three are filled, choices upgrade equipped attacks. If one large pickup crosses multiple thresholds, the player must make one selection for every level before play resumes. Already-collected XP, levels and chosen attack upgrades carry through failed runs.

Room transitions and death discard XP gems that were not collected; the transition/death message reports the loss. Expedition gold and supplies remain at risk until a homeward roll returns the player to Greenhollow. The field journal now records best depth, successful returns and falls so players can track attempts and try to beat their record. XP gem positions, best depth and run counters are persisted in the local save.

## Controls and demo

Use **WASD** or arrow keys to move. Collect the glowing cyan gems, then choose a level-up card with a mouse/tap or **1**, **2** or **3**. The selected active attacks appear in the lower-center hotbar; use them with **1–3** or their on-screen buttons. Mobile joystick/touch controls remain available. A cardinal exit only works after the room is cleared; an unclaimed shard is left behind when changing rooms.

Open the project in Godot and launch the seeded XP-shard preview with `--progression-demo`. Add `--walk-demo` to record a short approach that reaches a shard and opens the level-choice screen. `--choices-demo` opens the level-up card screen directly.

## Validation

Verified using Godot 4.7.2 headless import/startup and five regression suites: `progression_pickup_smoke_test.gd`, `art_ui_smoke_test.gd`, `expedition_smoke_test.gd`, `villager_smoke_test.gd` and `inventory_smoke_test.gd`. Coverage includes shard creation, magnet movement/collection, exact XP thresholds, multi-level queued choices, retaining earned XP after death, uncollected shard loss on room exit/death, save/load of shard coordinates and best-run records, clickable picks/hotbar attacks, expedition risk/banking, NPC tasks and inventory.

Android export and on-device touch testing remain to be done with matching Godot export templates and the Android SDK/JDK.
