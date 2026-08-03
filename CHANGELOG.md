# Changelog

All notable changes to **WXL UI Tracker** are documented here.

The format is based on [Keep a Changelog](https://keepachangelog.com/), and this project adheres to [Semantic Versioning](https://semver.org/).

## [v2.0] — 2026-08-03

### Added

- **Modular architecture** — the project was restructured into three independent WarcraftXL client modules:
  - `wxl-quest-marker` — world marker, distance text, corpse marker, tracker diamond, dropdown mirror.
  - `wxl-selcircle-poc` — engine-native selection circles on the selected quest's kill/interaction creatures.
  - `wxl-custom-interface` — third "Custom" tab in Interface Options with `TriAddCategory(frame)` panel registration.
- **Retail navigation assets** — native `Interface/navigation/ingamenavigationui.blp` atlas replacing the custom prototype texture.
- **Retail "M" map Quest Tracker behavior** — the Objective Tracker dropdown mirrors the world map (M) quest list exactly: same eligibility, same ordering, completed quests included.
- **Zone-aware tracking** — server-side zone eligibility from `quest_poi.WorldMapAreaId` vs. the player's current zone; ineligible quests hide the marker and never auto-track over an explicit choice.
- **Shared-zone handling** — border/shared-zone quests stay listed in the dropdown even when not renderable from the current zone.
- **Corpse navigation** — dedicated corpse marker + distance via opcode 300, not blocked by the zone-transition packet lockout.
- **Quest objective highlighting** — native selection circles drawn on every matching kill/interaction creature via the engine's `ProjectTex2d` path.
- **Kill quest objective rings** — `RequiredNpcOrGo1-4` resolution server-side; native circles on all matching mobs, even with no unit selected.
- **Item-drop objective rings** — indirect kill resolution through `ItemDrop1-4` **and** `RequiredItemId1-6` → `creature_loot_template`.
- **Objective Tracker dropdown integration** — dropdown buttons keep the native numbered disc + yellow glyph regardless of selection (`WX_ForceWatchPoiFace`).
- **Current tracked quest indicator** — diamond icon rendered to the left of the selected quest's row inside the Objective Tracker dropdown beneath the minimap.
- **Interface Options integration** — dedicated "Quest Tracker" panel under the second "Custom" tab.
- **Custom packet protocol** — opcode 100 (marker data), opcode 200 (kill entries), opcode 300 (corpse), sub-opcode 103 (kill-entry request), 0x051F (client quest-selection switch).

### Changed

- **Project rename** — `wxl-quest-marker` → **`wxl-ui-tracker`**. The repository now represents the full tracking framework rather than the original proof-of-concept module.
- **Rendering approach** — the quest-marker renderer moved from a standalone custom icon to the Retail navigation atlas; quest-mob highlighting moved from module-invented geometry to the engine's own selection-circle render path (`RsPush → SetCircleRenderStates → ProjectTex2d → RsPop`).
- **Config UX** — slash commands (`/qma`, `/qm`, `/qmc`) replaced by the Interface Options panel (kept functional where applicable).
- **Server coordinate resolution** — expanded from a single resolution chain to `RequiredNpcOrGo → POI → quest giver`, with separate kill/zone/coordinate logic paths.

### Improved

- **Performance** — per-frame early-outs, dirty-state caching (selection epoch, zone epoch, login-batch sentinel), deduped opcode-103 kill requests, `QuestMapUpdateAllQuests` throttled to 0.5 s, one-time texture loads, deterministic ~100-state save/restore only when a marker is visible.
- **Rendering stability** — render-state capture/restore guarantees the module never leaks D3D9 state into the UI pass; linear-filtered diamond quad avoids BLP mipmap aliasing at small sizes.
- **Login/zone-change flow** — 500 ms batch sentinel prevents marker flicker during login; zone-change refresh is deterministic and never overrides an explicit quest choice.
- **Dropdown correctness** — `linkButton.index` mapped through `GetQuestIndexForWatch()`; auto-highlight via `QuestPOI_SelectButtonByQuestId` (idempotent, exact to a player click).

### Fixed

- **Selection-mirror accuracy** — the tracker now mirrors Blizzard's selection registers (quest log, watchframe, dropdown) instead of guessing the tracked quest.
- **Zone eligibility races** — `selEpoch`/`zoneEpoch` tracking distinguishes a fresh selection from a stale one across zone changes and teleports.
- **Watch-list vs M-list mismatch** — auto-watch of M-listed quests so the dropdown shows exactly the same quests as the world map.
- **Item-drop conventions** — both `ItemDrop1-4` and `RequiredItemId1-6` loot paths now resolve, covering quests that declare drops either way.
