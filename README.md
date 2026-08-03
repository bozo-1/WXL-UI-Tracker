# WXL UI Tracker

**Retail-inspired quest navigation for WoW 3.3.5a** — a modular tracking framework built on **WarcraftXL** (client) and **TSWoW** (server).

WXL UI Tracker turns the classic 3.3.5a Objective Tracker into a modern, Retail-inspired navigation experience: an in-world 3D quest marker at the objective's real world position, a live distance readout, native selection circles on quest mobs, corpse navigation, a tracked-quest indicator inside the Objective Tracker dropdown, and full Interface Options control — all rendered through the game client's own engine.

> **v2.0** is a complete redesign of the original `wxl-quest-marker` prototype into a multi-module tracking framework. See [WHATS_NEW.md](WHATS_NEW.md), [CHANGELOG.md](CHANGELOG.md), and [RELEASE_NOTES.md](RELEASE_NOTES.md).

---

## Goals

- **Engine-first rendering** — every visual is drawn through the client's own engine (native selection-circle path, engine camera matrices, native UI templates). No external overlays, no injection into unrelated render passes.
- **Retail-quality navigation** — the marker, distance text, map mirroring, and dropdown behavior should feel like modern World of Warcraft, not an addon hack.
- **Server-authoritative state** — quest coordinates and zone eligibility are resolved server-side (quest_template, quest_poi, loot tables) and streamed to the client over custom packets. The client renders; it never guesses.
- **Zero-friction setup** — drop-in client modules, one livescript, one datascript, a handful of assets.
- **Performance as a feature** — per-frame work is minimized: dirty-state caching, early-outs, one-time texture loading, and state save/restore only when something is actually visible.

---

## Architecture

```
                          TSWoW (server)
┌──────────────────────────────────────────────────────────────┐
│ livescripts.ts                                                │
│   • Kill-entry resolution (RequiredNpcOrGo / ItemDrop /       │
│     RequiredItemId → creature_loot_template)                 │
│   • Zone eligibility (AreaTable → root-zone map)             │
│   • Coordinate resolution (RequiredNpcOrGo → POI → quest     │
│     giver)                                                   │
│   • Custom packet streams: 100 (markers) / 200 (kill        │
│     entries) / 300 (corpse) + 0x051F selection switch       │
└──────────────┬───────────────────────────────────────────────┘
               │ custom packets (opcode 100/200/300)
               ▼
                      WarcraftXL (client, 3.3.5a)
┌──────────────────────────────────────────────────────────────┐
│ wxl-quest-marker      wxl-selcircle-poc    wxl-custom-interface
│ ┌──────────────────┐  ┌─────────────────┐  ┌────────────────┐
│ │ Lua state machine│  │ ProjectTex2d    │  │ "Custom" tab   │
│ │ (selection, zone,│  │ hook → native   │  │ TriAddCategory │
│ │  dropdown mirror)│  │ selection       │  │ panel registry │
│ │                  │  │ circles on quest│  └────────────────┘
│ │ D3D9 world marker│  │ mobs            │
│ │ + distance text  │  └─────────────────┘
│ │ + tracker diamond│
│ └──────────────────┘
│   OnWorldRenderEnd seam (world→UI boundary), engine camera
│   matrices, minimal state churn, NDC projection storage
└──────────────────────────────────────────────────────────────┘
               │
               ▼
              FrameXML (client file edits — client/framexml/)
   WatchFrame.lua   QuestPOI.lua   QuestTrackerOptions.lua/xml
   (dropdown mirror, (keep disc +   (Interface Options panel
    auto-watch,      yellow number   + dropdown customisations:
    diamond anchor)  on selection)   style/size/units/font)
```

**Execution flow (per frame):**

```
Server streams quest state (event-driven, not per-frame)
        ↓
Client Lua cache (selection, marker data, zone epoch)
        ↓
OnWorldRenderEnd fires once per frame (world→UI boundary)
        ↓
QuestMarker: early-outs (no quest → skip) → dirty-state cache
        ↓
Visible marker? → capture ~100 D3D9 states → set world transform
        ↓
Draw quad (IngameNavigationUI atlas) → restore states
        ↓
SelCirclePoc: RsPush → SetCircleRenderStates → ProjectTex2d →
native circles on quest mobs → RsPop (engine-balanced window)
```

The marker draws *only* at the world→UI seam, *only* when a marker exists, and restores every D3D9 state it touches — so it can never leak render state into the UI pass.

---

## Installation

### 1. Client — WarcraftXL modules

Copy each module folder into your `wxl-core/scripts/` directory:

```
wxl-core/scripts/
├── wxl-quest-marker/        ← in-world marker + distance + diamond
├── wxl-selcircle-poc/       ← native quest-mob selection circles
└── wxl-custom-interface/    ← "Custom" Interface Options tab
```

The wxl-core build system auto-discovers `scripts/*/src/*.cpp`. Rebuild `WarcraftXL.dll` and deploy it to the client directory.

> Module registration names (`wxl-quest-marker`, `wxl-selcircle-poc`, `wxl-custom-interface`) are the load-bearing build identities and must not be renamed.

### 2. Client — FrameXML edits (`client/framexml/`)

These files are the canonical `luaxml_source` edits. Copy them into your TSWoW dataset's `luaxml_source/Interface/FrameXML/`:

```
FrameXML.toc                ← registers QuestTrackerOptions.xml
QuestTrackerOptions.lua     ← Interface Options panel + dropdowns
QuestTrackerOptions.xml     ← panel layout (UIDropDownMenuTemplate)
WatchFrame.lua              ← dropdown mirrors M list, auto-watch, diamond anchor
QuestPOI.lua                ← keep disc + yellow number regardless of selection
```

They propagate automatically to the client on the next build (source → working copy → client).

### 3. Server — TSWoW scripts

Copy the server scripts into your TSWoW module:

```
server/livescripts.ts       ← full tracker protocol (100/200/300, 0x051F)
server/datascripts.ts       ← data injection + demo creature
```

Rebuild your TSWoW project to compile TypeScript → Lua.

### 4. Assets (`assets/`)

Deploy the textures into the client patch archive:

```
Textures/highlightcircle/unitselecttexture-quest.blp    ← marker/circle texture
Interface/navigation/ingamenavigationui.blp          ← retail navigation UI atlas
```

### 5. Custom Interface Options

The "Quest Tracker" panel appears under the second **Custom** tab of Interface Options (`wxl-custom-interface` provides the tab; `wxl-quest-marker` registers the panel via `TriAddCategory`).

---

## Requirements

| Component | Requirement |
|---|---|
| Game | World of Warcraft **3.3.5a** (build 12340) |
| Client framework | **WarcraftXL** (wxl-core) — `wxl::runtime`, `wxl::game::gx`, `wxl::game::camera`, module auto-discovery |
| Server framework | **TSWoW** — `QueryWorld`, `CreateCustomPacket`, `events.WorldPacket`, `std.LUAXML` |
| Renderer | Direct3D **9** |
| Build | wxl-core toolchain (MSVC, x86) for the DLL; tswow-scripts for server + FrameXML |

---

## Project structure

```
wxl-ui-tracker/
├── README.md                 ← this file
├── WHATS_NEW.md              ← v2.0 evolution story
├── CHANGELOG.md              ← v2.0 changelog (Added/Changed/Improved/Fixed)
├── RELEASE_NOTES.md          ← GitHub milestone release notes
├── LICENSE
├── client/
│   ├── scripts/
│   │   ├── wxl-quest-marker/       ← world marker + distance text + tracker diamond
│   │   │   └── src/ QuestMarker.{cpp,hpp} TextureLoader.{cpp,hpp}
│   │   ├── wxl-selcircle-poc/      ← native selection circles for quest mobs
│   │   │   └── src/ SelCirclePoc.{cpp,hpp}
│   │   └── wxl-custom-interface/   ← "Custom" Interface Options tab + TriAddCategory
│   │       └── src/ CustomInterface.{cpp,hpp}
│   └── framexml/                  ← client file edits (the dropdown customisations)
│       ├── FrameXML.toc
│       ├── QuestTrackerOptions.lua / .xml
│       ├── WatchFrame.lua
│       └── QuestPOI.lua
├── server/
│   ├── livescripts.ts             ← tracker protocol (opcodes 100/200/300, 0x051F)
│   └── datascripts.ts             ← data injection
├── assets/
│   ├── textures/questmarker/unitselecttexture-quest.blp
│   └── textures/navigation/ingamenavigationui.blp
└── docs/
    ├── QUESTMARKER.md             ← quest-marker system architecture
    └── CUSTOMINTERFACE.md         ← custom Interface Options tab system
```

---

## Media
<table align="center" width="100%">
  <tr>
    <td width="50%" align="center">
      <img src="https://github.com/user-attachments/assets/64ffdf4b-3414-48f5-a7d8-49ede24b3b67" width="100%">
    </td>
    <td width="50%" align="center">
      <img src="https://github.com/user-attachments/assets/75c6a758-5d34-4f07-adef-54e9c3324bbe" width="100%">
    </td>
  </tr>
  <tr>
    <td width="50%" align="center">
      <img src="https://github.com/user-attachments/assets/f9af177d-a997-4705-88a9-c51455aa844d" width="100%">
    </td>
    <td width="50%" align="center">
      <img src="https://github.com/user-attachments/assets/63ec48a6-58fa-4753-ab2e-47bff0c2a18f" width="100%">
    </td>
  </tr>
  <tr>
    <td width="50%" align="center">
      <img src="https://github.com/user-attachments/assets/d47a2e80-8793-413a-9261-0f450f36b7c1" width="100%">
    </td>
    <td width="50%" align="center">
      <img src="https://github.com/user-attachments/assets/11054bbd-090e-4d0c-bd39-e3b3b534fb5b" width="100%">
    </td>
  </tr>
</table>
<p align="center">
  <img src="https://github.com/user-attachments/assets/6a7374ee-a8ad-4b31-9d1a-2088dc9d8ddb"
       alt="WXL UI Tracker Demo"
       width="80%">
</p>


## Features

Documented from the current implementation — every item below exists in the code today.

### Navigation

- **Retail-style world quest marker** — a 3D world-anchored marker at the selected quest's objective position, projected through the engine camera each frame and drawn at the world→UI seam.
- **Live distance text** — a gold distance readout rendered beneath the marker, clamped to screen edges when the objective is off-screen or behind the camera.
- **Distance formatting & units** — automatic yd/km formatting with **Meters / Yards / Auto** unit selection (CVar `wxTrackerDistUnits`).
- **Retail navigation assets** — the marker and diamond use the native `Interface/navigation/ingamenavigationui.blp` atlas (retail UI texture).

### Tracking

- **Quest tracking improvements** — the tracked quest follows Blizzard's own selection registers (quest log, tracker, watchframe), with login-batch handling, zone-change refresh, and a 500 ms batch sentinel that prevents flicker.
- **Zone-aware tracking** — the server computes zone eligibility from `quest_poi` `WorldMapAreaId` vs. the player's current zone (Retail-like); ineligible quests hide the marker and never auto-track over an explicit choice.
- **Retail "M" map Quest Tracker behavior** — the Objective Tracker dropdown mirrors the world map (M) quest list exactly: same eligibility, same ordering, completed quests included.
- **Shared-zone handling** — border/shared-zone quests stay listed in the dropdown even when not renderable from the current zone.
- **Objective Tracker dropdown integration** — dropdown buttons keep the native numbered disc and yellow glyph regardless of selection state (`WX_ForceWatchPoiFace` in `QuestPOI.lua`).
- **Current tracked quest indicator** — a small diamond icon (the tracked-quest marker) is rendered to the left of the selected quest's row inside the Objective Tracker dropdown beneath the minimap, via the module's own D3D path (`SetTrackerDiamond`).
- **Auto-track** — auto-select the first M-list tracked quest on login/zone change (CVar `wxTrackerAutoTrack`).

### Objective highlighting

- **Quest objective highlighting** — the selected quest's kill/interaction creatures are highlighted with **native selection circles** (the engine's own circle texture and draw path), driven by the opcode-200 kill-entry stream.
- **Kill quest objective rings** — kill-count objectives resolve their mob entries server-side (`RequiredNpcOrGo1-4`) and draw native circles on every matching creature, even with no unit selected.
- **Item-drop objective rings** — indirect kill objectives resolve through `ItemDrop1-4` **and** `RequiredItemId1-6` → `creature_loot_template`, covering both item-drop conventions.

### Corpse navigation

- **Corpse marker** — when dead, a marker points at your corpse with distance (opcode 300 stream). Not blocked by the zone-transition packet lockout.

### Interface Options

- **Interface Options integration** — a dedicated "Quest Tracker" panel under the third **Custom** tab (provided by `wxl-custom-interface`, registered via `TriAddCategory`).
- **Feature toggles** (CVar-driven, live-applied):
  - Enable / disable the whole system (`wxTrackerEnabled`)
  - Auto-track (`wxTrackerAutoTrack`), show completed (`wxTrackerShowCompleted`)
  - Show marker (`wxTrackerShowMarker`), marker style **Arrow / Diamond / Circle / Custom** (`wxTrackerMarkerStyle`)
  - Marker size **Small / Medium / Large** (`wxTrackerMarkerSize`)
  - Fade when close (`wxTrackerFadeClose` + `wxTrackerFadeDist`), show through geometry (`wxTrackerShowThrough`), animated (`wxTrackerAnimated`)
  - Show distance (`wxTrackerShowDistance`), units, font size (10–24), font outline, marker alpha (`wxTrackerAlpha`)

### Rendering & performance

- **Engine-rendered visuals** — world marker/diamond via D3D9 billboard quad with engine camera matrices; quest-mob circles via the native `ProjectTex2d` selection-circle path; dropdown/diamond anchors from live UI geometry (scale-independent NDC math).
- **Rendering improvements** — deterministic render-state save/restore (~100 states) that only runs when something is visible; linear-filtered diamond quad avoids BLP mipmap aliasing at small sizes.
- **Performance optimizations** — per-frame early-outs, dirty-state caching (selection epoch, zone epoch, batch sentinel), deduped opcode-103 kill requests, `QuestMapUpdateAllQuests` throttled to 0.5 s, one-time texture loads, and a release-prepared hot path.

### Architecture

- **Modular architecture** — three independent WarcraftXL modules with single responsibilities (marker renderer, native circle renderer, options-tab host), one server livescript, and a small set of client file edits.
- **Custom Interface Options / Features panel** — any module can register a panel under the "Custom" tab via `TriAddCategory(frame)`.

---

## Credits

- **WarcraftXL** — client framework, RE infrastructure, and the offset database that made engine-native rendering possible.
- **TSWoW** — server framework (custom packets, world queries, LUAXML pipeline).
- **Blizzard Entertainment** — World of Warcraft, the retail navigation atlas, and FrameXML templates used/extended by this project.
- **3.3.5a modding community** — RE resources (all.sym, binana, cmpgraph call graphs) used to map the selection-circle render path.

---

## License

See [LICENSE](LICENSE). WarcraftXL, TSWoW, and World of Warcraft assets remain property of their respective owners; this project's code is licensed as stated in the LICENSE file.
