# What's New in v2.0

This document explains how WXL UI Tracker evolved from the original `wxl-quest-marker` prototype into the framework it is today.

---

## The original prototype

The first version (v1.0–v1.2, published as `wxl-quest-marker`) was a single-purpose module: a **basic world quest marker** using a custom-made icon. It drew one D3D9 billboard quad at the selected quest's objective position, showed a gold distance text beneath it, and was configured with a couple of slash commands (`/qma`, `/qm`, `/qmc`).

It proved the core idea — that a WarcraftXL module could render a world-anchored quest marker through the game client's own engine — but it was a proof of concept: one module, one texture, one render path, minimal UI.

## What v2.0 is

v2.0 has been **extensively redesigned, refactored, and expanded** into a complete, modular, Retail-inspired navigation framework. It is no longer "a quest marker addon" — it is a tracking system built on top of the client engine.

### From one module to a framework

| v1.x | v2.0 |
|---|---|
| One client module | **Three independent WarcraftXL modules** (marker renderer, native circle renderer, options-tab host) |
| One custom texture | **Retail navigation assets** — the native `ingamenavigationui.blp` atlas |
| Slash-command config | **Full Interface Options panel** under a new "Custom" tab, with 16 CVar-driven feature toggles |
| Marker only | Marker + distance + **corpse navigation** + **quest-mob highlighting** + **tracker diamond** + **dropdown integration** |
| Server sent one packet stream | **Four protocol channels** (opcodes 100/200/300 + 0x051F selection switch), zone eligibility, kill-entry resolution |

### From "draw a quad" to engine-native rendering

The biggest architectural shift is *how* things render:

- **World marker** — still a D3D9 billboard, but now driven by the engine camera matrices at the world→UI render seam, with a ~100-state save/restore that only runs when something is visible.
- **Quest-mob highlight circles** — no longer a module-invented visual. They are the **engine's own selection circles**, drawn through the native `ProjectTex2d` render path by the `wxl-selcircle-poc` module (reverse-engineered and cross-validated across all.sym, binana, cmpgraph call graphs, and Ghidra).
- **Objective Tracker dropdown** — the dropdown now mirrors the Retail "M" map quest list, keeps the native numbered disc + yellow glyph on every button, and shows a **diamond indicator** next to the currently tracked quest's row.
- **Interface Options** — a third "Custom" tab built from native Blizzard templates (`PanelTemplates`, `UIDropDownMenuTemplate`), where any module can register panels via `TriAddCategory`.

### Server-side maturity

The server livescript grew from a coordinate sender into a real quest system: kill objectives resolve through `RequiredNpcOrGo1-4`, `ItemDrop1-4`, *and* `RequiredItemId1-6` → loot tables; zone eligibility is computed from a complete AreaTable → root-zone map; quest coordinates resolve RequiredNpcOrGo → POI → quest giver.

## Summary

- **Redesigned** — modular architecture, engine-first rendering, Retail-inspired UX.
- **Refactored** — release-prepared hot paths, dirty-state caching, no per-frame allocations.
- **Expanded** — from one marker to a full navigation experience: highlighting, corpse navigation, dropdown integration, and complete settings UI.

The project kept its name's spirit — it is still about the quest marker — but v2.0 is a different beast: **WXL UI Tracker**.
