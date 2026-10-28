# Greenhollow implementation roadmap

## Included in this build
1. Godot 4.7 project foundation and Android-friendly GL Compatibility renderer.
2. Four original class spritesheets (4 frames × 8 directions), class portraits, skill icons and improved tile/prop/title artwork.
3. Connected six-screen overworld with reciprocal edge transitions.
4. Touch joystick, touch actions, keyboard testing controls and menus.
5. Wilderness encounter gating: enemies spawn in wilderness and only aggro after player attack; safe areas disengage.
6. Level/XP/skill point progression, class specials, cooldown/MP costs, weapon mastery, inventory, potions, shops, quest and save/load.

## Next polish pass
- Replace the custom Canvas-drawn map layout with authored TileMapLayer scenes and collision shapes.
- Add directional attack/dodge/hurt/death/interact animation sheets and effects.
- Add map-specific enemy tables, drops, encounter cooldowns, NPC schedules, interiors and more quest objectives.
- Add audio cues and a settings-backed audio bus.
- Run Godot 4.7.2 parser/import, gameplay smoke test, Android export and device profiling before calling the APK validated.
