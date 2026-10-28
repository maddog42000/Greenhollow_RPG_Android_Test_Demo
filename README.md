# Greenhollow RPG • Android Demo Project

**Target editor:** Godot 4.7.2 stable, standard build  
**Renderer:** GL Compatibility for broad Android support  
**Direction:** original hybrid pixel-art, three-quarter top-down, 8-direction movement  
**Status:** source project; not a compiled APK

## What's in this build
- Title screen, four playable classes, save/load, pause and settings.
- Connected overworld screens: Greenhollow Village, Whisperwood Forest, Northwatch Trail, Old Road, Mossy Crossing and Sunken Ruins.
- Cardinal exits start a risky expedition; completed rooms roll for a random route home or send the player deeper into a random biome.
- Virtual joystick and touch action buttons; keyboard/mouse test controls (WASD/arrows, Space attack, Q special, E interact, 1–3 active attacks, Escape pause).
- Room clears are required before leaving. Enemy health/damage and room counts scale with expedition depth.
- Enemies drop glowing XP shards; nearby shards magnet toward the player. Collect XP to trigger a three-choice level-up, then select a new attack or rank-up.
- The field journal records best expedition depth plus successful returns and failed runs, encouraging another attempt after a risky loss.
- Class signature abilities, MP cost/cooldown, weapon mastery, health potions, gold, expedition loot and inventory.
- Elder quest, gathering nodes, chest, village merchants, standard respawn and hardcore death flow.
- Original generated fantasy atlas, extracted detailed tree/rock/campfire/well/market/building/ruin props, upgraded class sprites, portraits and skill icons. Third-party CC0 asset references are documented separately; no external pack is falsely claimed as bundled.
- JSON data files for classes, enemies, items, skills, quests, balance and asset manifest.

## Character art and animation
The supplied RGBA atlas contains four populated frames per class in both the movement and attack strips. Runtime rendering uses only those verified regions; the older 4×8 per-class files are incomplete transparent placeholders and are not used for the visible actor animation. This avoids selecting a blank cell and making the player or villagers disappear. The generated sprite art is original prototype art, not final hand-polished commercial art.

## Controls
- Desktop: WASD/arrows to move, Space to basic attack, Q to use the unlocked class special, E to interact, 1–3 to use equipped attacks, Escape to pause. Click UI cards/buttons with the mouse.
- Android: drag the lower-left joystick; tap Attack, Special, Interact or one of the three center hotbar slots. Use the right-side menu for Save, Pause, Skills and Bag.
- Walk through an edge opening to use a cardinal exit. In an expedition, clear every enemy first. Each crossing has an independent chance to find a homeward route; if missed, the run gains depth and the next biome/room is randomized.

## Class specials
- Warrior: Whirlwind
- Ranger: Volley
- Mage: Arcane Burst
- Rogue: Shadow Strike

Reach level 2, then spend a skill point in Skills to unlock the class special. Special moves cost 15 MP and have a cooldown. The skill names and icon assets are included.

## Quick demo
1. Extract the ZIP and open `project.godot` in Godot 4.7.2 stable (or newer Godot 4.x).
2. Press **F6** to run the main scene, or press **F5** to launch the project.
3. Choose a class, then enter Greenhollow. Walk with **WASD** or arrows; use **E** near the Elder, villagers, workshop or gathering points.
4. Leave through a cardinal edge to begin a run. Clear the room with **Space** or a learned attack; enemies drop collectible XP shards. Crossing an exit rolls for a way home. A failed roll raises depth and picks a new room. Loot is not banked until you make it home; normal death loses unbanked haul and uncollected shards but keeps XP/levels already earned.
5. Collect shards to fill the XP bar. Every level pauses for three choices. Tap/click a card or press **1**, **2** or **3**; the chosen attack appears in the lower-center hotbar. Large XP drops can queue multiple picks, and duplicate offers improve an attack's rank.
6. Back at the village, speak with the Herbalist or Blacksmith: buy a 35-HP potion for 12 gold; craft one with 2 Forest Herbs + 1 Oak Wood; build a permanent Waystone with 4 Rough Ore + 3 Oak Wood for +8 percentage points of homeward chance.
7. Use Save; learned attacks, Waystone and in-progress expedition depth/haul are persisted and can be resumed.

The project is a source demo, not an exported APK. Android export still requires matching Godot export templates and Android SDK/JDK setup.

## Android export
Use matching Godot 4.7.2 export templates and configure the Android SDK/JDK under Editor Settings. Create/select an Android export preset and export a debug APK. Export templates and Android SDK are not bundled in this ZIP.

## Expedition loop and risk
Each village departure starts at depth 0. The first room follows the chosen exit; after each room is cleared, any cardinal exit rolls independently for a way home. Base chance is 20%, falls by 0.6 percentage points per depth to a 6% floor, and the Waystone adds 8 points. A failed roll advances depth and sends the player to a random different biome; deeper rooms add enemies and scale their HP/damage. Enemies block exits until defeated.

XP gems appear at enemy defeat locations and pull toward the player inside a short magnet radius. Only collected XP advances the persistent level bar; a room transition leaves any unclaimed gems behind, and death loses them. Every level pauses combat for three random attack picks; each pick adds an attack to an open hotbar slot or raises the rank of a learned attack. XP, levels and chosen upgrades remain after a failed run. The field journal tracks personal-best depth, banked returns and falls. Enemy gold and 30%-chance material drops remain unbanked expedition haul until a return home; a normal defeat discards that haul. Saving mid-run preserves the expedition and any uncollected shards.

## Active attacks and home workshop
Level-ups offer three distinct random options from Whirlwind (area), Volley (up to three targets), Arcane Burst (wide area) and Shadow Strike (single-target burst). New abilities fill up to three attack slots; once full, choices are upgrades to equipped attacks. Every attack has a rank, MP cost and cooldown, and appears as a tappable hotbar button. The four class signature moves remain a separate Skills-screen unlock.

At the village workshop, buy a Small Health Potion for 12 gold (+35 HP), craft one from 2 Forest Herbs + 1 Oak Wood, or build the Waystone from 4 Rough Ore + 3 Oak Wood. Resource recipes are intentionally gathered from the existing village nodes.

## Validation
Godot 4.7.2 stable headless import/startup and regression tests were run. The project tests verify visible movement/attack frames for all four classes, three unique level-up offers, clickable offer/hotbar hit regions, attack damage/MP/cooldown, random return success/failure, room-clear gating, banking vs. death loss, workshop recipes, Waystone bonus, save/resume and existing villager/inventory flows. This does not certify Android export; test touch controls and export on a target device/editor before release.
Run the commands in the **Included regression tests** section below from the project directory.

## Artwork provenance
See `assets/original_art_pass/ART_NOTES.md` for the generated original art, extraction notes, honest animation limitations, and researched optional CC0 reference packs.

## Village art pass
The village now has a warm flagstone plaza, low decorative fence sections, flowerbeds and lanterns. These are visual details only; they do not add collision or change gameplay paths.

Day/night now cycles every four minutes of active play; it pauses while menus or pause screens are open. Lantern halos brighten toward dusk and night.

## Village villagers
Mira and Tomas walk short looping paths along the village road. Approach either one until the nearby prompt shows their name, then press **E** or tap **INTERACT** to hear a short line. NPCs currently use simple visual pathing without collision/avoidance.

## Villager fetch tasks
Mira requests 2 Forest Herbs for 15 gold; Tomas requests 2 Oak Wood for 20 gold. Accept their tasks in conversation, gather the materials from the village nodes, then return and choose **DELIVER ITEMS**. Items are consumed on successful turn-in; completed task state is saved. Keyboard confirmation uses **E**, **Enter** or **Space**; touch players can tap the task button.

## Bag and quest journal
Open **BAG** from the game HUD to see gold, carried resource/potion counts, Elder quest progress, and Mira/Tomas fetch-task status. The health-potion action remains available from this screen.

## Sprite-sheet art and UI pass
The user-provided pixel-art sheet is retained unchanged at `assets/user_art/greenhollow_sprite_sheet_source.png`; the RGBA atlas beside it removes the bright-magenta key and is referenced by atlas coordinates in the game. Pixel-art trees, flowers, fences, stream details, village houses, stumps and spirit/slime visuals are integrated into the six overworld areas. Green spirits bob and pulse in the wilds; slime enemies squash and bounce. The player and moving villagers use the visible four-frame character strips from the supplied sheet; the attack strip supplies a distinct attack pose.

The overworld HUD now has a larger class/health/mana/XP/gold card and a field journal with best-run stats, current depth/home odds, haul and XP shards on the ground. Glowing, bobbing XP gems magnet toward the player nearby. Level-ups pause for three hoverable/tappable choice cards; each level earned gives one pick, and any queued picks must be completed before play resumes. Chosen attacks appear in the lower-center hotbar and use their corresponding supplied icons in animated combat bursts.

`--progression-demo` previews a run with a nearby XP shard, while `--choices-demo` opens the level-up cards. Other optional previews include `--levelup-demo`, `--expedition-demo`, `--workshop-demo`, `--skills-demo --class-mage`, `--skillfx-demo --class-mage`, `--forest-demo` and `--walk-demo --class-mage`; normal startup is unchanged.

## Included regression tests
Run from the project directory with Godot 4.7.2: `godot --headless --path . --script tests/progression_pickup_smoke_test.gd`, `godot --headless --path . --script tests/art_ui_smoke_test.gd`, `godot --headless --path . --script tests/expedition_smoke_test.gd`, `godot --headless --path . --script tests/villager_smoke_test.gd`, and `godot --headless --path . --script tests/inventory_smoke_test.gd`.


## Phase 04 — Survivors roguelite update

- **Automatic combat:** character-class attacks automatically target nearby enemies; Space and the on-screen Attack button remain optional fallback controls. Enemies arrive in escalating, bounded wave batches.
- **Milestones:** Wave 5 has an elite milestone; Wave 10 is a distinct boss milestone with countdown and fight HUD warnings. The HUD shows wave state and remaining/queued enemies.
- **Three-card progression:** every level pauses and offers exactly three distinct randomized choices from a 33-card catalog. Cards include passive stats, class abilities, and epic build trade-offs; the screen displays rarity, rank, description and effect summary. Large XP pickups queue one choice per level gained.
- **Risk/reward:** periodic wave checkpoints may reveal a homeward route. Return Home banks gold and supplies and ends the run; Press On keeps the haul unbanked and advances to harder waves. Death loses unbanked loot and ground XP but retains collected character progression.
- **Persistence:** save/load retains build ranks, mastery, wave checkpoint, expedition depth, home intermission and unbanked haul. Village, class sprites, quests, touch joystick and workshop remain in place.

Use Godot 4.7.2 stable or newer. Optional review launch arguments include `--choices-demo`, `--progression-demo`, `--expedition-demo`, and `--workshop-demo`. Controls: WASD/arrows move, Space fallback attack, Q special, E interact, 1–3 hotbar; at the home-route choice, R returns and C/Enter/Space continues. Touch uses the virtual joystick and tappable buttons/cards.

**Phase 04 verification:** headless import and startup plus `art_ui_smoke_test`, `expedition_smoke_test`, `villager_smoke_test`, `inventory_smoke_test`, `progression_pickup_smoke_test`, `upgrade_catalog_smoke_test`, and `wave_director_smoke_test` all passed. This remains a source demo, not an APK or Android-device certification.

See `../PHASE_04_SURVIVORS_ROGUELITE.md` for the full overview and future suggestions. The current gameplay capture and overview still need to be reviewed against the final export package.
