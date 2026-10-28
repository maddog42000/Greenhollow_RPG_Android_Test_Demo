# Greenhollow RPG — Phase 04: Survivors Roguelite

**Checkpoint:** Phase 04 — Survivors-style combat and progression  
**Engine:** Godot 4.7.2 stable · GL Compatibility  
**Package:** Source project; not an exported APK  
**Validation:** Seven headless regression suites passed; editor import and project startup clean.

## What changed

Greenhollow now combines its original village, four classes, sprite atlas, quests, gathering and mobile-friendly joystick with an escalating survivors-style expedition loop. Attacks fire automatically at the nearest target using class-specific melee or projectile behavior; Space and the ATTACK button remain optional PC/touch fallbacks. Enemy waves arrive in bounded batches, with scaling counts, health, damage and speed. Wave 5 adds an elite milestone and Wave 10 schedules a boss. The HUD reports wave number, living/queued enemy totals, countdowns, boss warnings, XP shards and unbanked haul.

Defeated enemies leave XP gems. Nearby gems magnet toward the hero; collecting enough XP pauses play and always presents three distinct, randomized upgrade cards. The 33-card catalog includes offense, defense, mobility, utility, class abilities and trade-off builds. Card names, rarity, rank, descriptions and effect summaries are shown. Chosen upgrades persist through the expedition, and queued levels each require a separate pick. Equipped abilities occupy up to three hotbar slots; passive choices continue to be available when the attack slots fill.

At wave checkpoints, a home-route opportunity may appear. Returning safely banks expedition gold and materials and ends the run in the peaceful village; pressing on keeps the haul at risk and starts a harder wave. Death discards unbanked loot and uncollected shards, but retains earned levels and selected upgrades. The village workshop still supports potion purchase/crafting and the Waystone. Save data resumes expedition depth, build, wave checkpoint and unbanked haul.

## Controls

- **Keyboard:** WASD/arrows to move, Space basic fallback attack, Q class special, E interact, 1–3 hotbar attacks, Escape pause. During a home-route choice, **R** returns home and **C/Enter/Space** continues.
- **Touch:** drag the lower-left virtual joystick; tap Attack, Special, Interact, hotbar and menu buttons. Upgrade cards can be tapped directly.

## Run and test

Open `Greenhollow_RPG_Android_Test_Demo/project.godot` with Godot 4.7.2 stable or newer. Choose any of the existing four classes and leave the village to begin the expedition. `--choices-demo`, `--progression-demo`, `--expedition-demo`, and `--workshop-demo` remain available for screenshots/inspection.

Seven tests cover sprite/UI behavior, expedition and save/load, villager tasks, inventory, XP pickup and queued choices, card catalog eligibility, and wave scheduling/milestones. Headless import and startup also completed without GDScript parse/shadowing errors. This is not Android-export certification; final touch/device and Android-template checks remain.

## Future suggestions

1. **Run-to-run meta progression:** banked relics, class unlocks and permanent village upgrades, separate from the current in-run build.
2. **Weapon evolution recipes:** combine a max-rank attack with a matching passive/card for a distinctive evolved weapon and visual/audio feedback.
3. **Boss phase design:** telegraphed arena attacks, health bar, stagger windows, guaranteed milestone reward and stronger boss-specific art.
4. **Enemy variety and synergies:** add support auras, summoners, shield units and biome-specific packs that reward different builds.
5. **Mobile usability pass:** device-scale typography, safe-area handling, touch-target audit, performance profiling and portrait/landscape decision.
6. **Balance telemetry:** record wave reached, damage sources, upgrade picks, return-vs-continue choice and death causes; tune curves against short and long sessions.
7. **More content:** additional village NPC quests, region events, elite modifiers and a compact bestiary/collection journal.

## Phase archive sequence

This is the next labeled archive after the existing Phase 01 Stability, Phase 02 Expedition and Phase 03 XP progression checkpoints. Earlier ZIPs are preserved unchanged. The Phase 04 project archive and demo video are delivered alongside this overview.
