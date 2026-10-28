# Greenhollow original art pass

`greenhollow_original_atlas.png` and the extracted PNG props/characters in this folder were generated specifically for this Greenhollow prototype. The atlas is a source sheet, not a ready-to-use Godot TileSet. Magenta background pixels were made transparent and individual elements were cropped into PNGs.

The prototype walk sheets are derived from the generated class illustrations with direction mirroring and small frame offsets. They are usable placeholders for animation integration, but are **not** eight hand-drawn directional animation cycles. Replace them with genuine frame-by-frame animations during the next art pass.

## Researched optional reference packs (not bundled in this project)
- Kenney Roguelike/RPG Pack, CC0: https://kenney.nl/assets/roguelike-rpg-pack
- Kenney Scribble Dungeons, CC0: https://kenney-assets.itch.io/scribble-dungeons
- OpenGameArt RPG Tileset by russpuppy, CC0: https://opengameart.org/content/rpg-tileset

These links are references only. No third-party asset files are included from those pages, and their art has not been misrepresented as original Greenhollow art. Re-check each source's license before separately downloading or redistributing it.

## Integrated overworld art pass (2026-10-23)
- Added original 64x64 pixel-style grass, dirt, cobble, moss, and sand ground tiles in `assets/world/` and use them to distinguish village roads, woodland ground, travel roads, and ruins.
- Replaced several placeholder geometric village buildings with the extracted cottage/manor illustrations; added the market stall and well, varied oak/pine/autumn trees, a woodland campfire, and a ruin arch to the game renderer.
- These tiles are original programmatically assembled pixel-art textures, not third-party pack assets. The tree/building/prop illustrations were cropped from the project's generated original art atlas.
- Player sprite sheets remain derived mirrored/frame-offset sheets, not authentic frame-by-frame walk/idle/attack cycles. The project has not been runtime-tested in Godot in this environment because no Godot executable is installed; do not interpret archive checks as a successful game launch or Android APK build.
