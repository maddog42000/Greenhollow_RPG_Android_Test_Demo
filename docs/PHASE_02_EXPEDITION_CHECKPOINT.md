# Greenhollow RPG — Phase 02 Checkpoint

**Checkpoint:** 02 — Expedition Roguelite and Active Skills  
**Engine:** Godot 4.7.2 stable  
**Purpose:** A runnable source-project checkpoint for continuing development; this is not an exported Android APK.

## What Phase 02 adds

- Leaving Greenhollow starts a depth-0 expedition. After a room is cleared, a cardinal exit rolls for a homeward route. A failed roll advances depth and selects a different random biome/room.
- Homeward odds begin at 20%, fall by 0.6 percentage points per depth to a 6% floor, and gain 8 percentage points from the persistent Waystone.
- Enemies block exits until defeated. Room size, enemy count, health and damage scale with depth.
- Enemy gold and material drops are carried as unbanked expedition haul. Reaching home banks the haul; ordinary death discards the unbanked haul while retaining accumulated character levels/XP and stored inventory. Saves can resume expedition depth and haul.
- Every level pauses for three random active-attack choices. New attacks fill up to three hotbar slots; once full, choices upgrade an equipped attack. Choices support touch, mouse and keyboard 1–3. Active attacks have icons, ranks, MP costs and cooldowns.
- The village workshop sells a +35 HP potion for 12 gold, crafts one from 2 Forest Herbs + 1 Oak Wood, and builds the permanent Waystone from 4 Rough Ore + 3 Oak Wood.
- Save/load now preserves attack slots/ranks, Waystone state, expedition location/depth and carried haul; older saves receive safe defaults.
- Fixed the earlier Godot Node `name` shadowing warning and the actor disappearing/blinking by limiting player/NPC animation to populated sprite-sheet frames. Included tests assert visible walk/attack crops.

## Preview modes

Pass these as user arguments after `--` when launching Godot:

- `--expedition-demo --class-ranger` — seeded depth-4 run with a visible haul and three learned attacks.
- `--choices-demo --class-ranger` — three level-up cards.
- `--workshop-demo --class-ranger` — seeded workshop supplies, potion and Waystone recipes.
- `--walk-demo --class-ranger` — moving-player stability preview.

Normal startup is unchanged. Replace `ranger` with `warrior`, `mage` or `rogue` where relevant.

## Regression checks

All checks below passed against Godot 4.7.2 stable in headless mode:

```sh
godot --headless --path . --editor --quit
godot --headless --path . --quit-after 30
godot --headless --path . --script tests/art_ui_smoke_test.gd
godot --headless --path . --script tests/expedition_smoke_test.gd
godot --headless --path . --script tests/villager_smoke_test.gd
godot --headless --path . --script tests/inventory_smoke_test.gd
```

The tests cover art-frame visibility, class skill/progression behavior, three distinct offers, active attack use/ranks, room-clear gating, homeward success/failure, haul banking/death loss, potion purchases/recipes, Waystone bonus, save/resume, NPC tasks and inventory interaction.

## Scope and follow-up

This is a 2D prototype using scripted room/biome screens, simple enemies and a single three-slot active-attack bar. The procedural loop selects among the existing overworld areas; it is not yet a full tile-based dungeon generator with a persistent room graph, branching door map, larger itemization or long-form campaign. Android export templates/SDK and a target-device touch pass are not included or verified. Next useful work: richer room layouts and modifiers, enemy telegraphs/status effects, more attack variety, explicit risk/reward upgrades, and on-device testing.
