# WXL UI Tracker — v2.0

> 🎉 **This is the milestone release.** WXL UI Tracker v2.0 is out — a complete redesign of the original `wxl-quest-marker` prototype into a full Retail-inspired navigation framework for WoW 3.3.5a.

---

## Where this project started

WXL UI Tracker began life as `wxl-quest-marker` — a small proof of concept that asked a simple question: *can a WarcraftXL module project a world-anchored quest marker into the 3D world using the game client's own engine?* The answer was yes, and v1.0 shipped exactly that: one D3D9 billboard quad at the selected quest's objective, a gold distance text beneath it, and a couple of slash commands to configure it.

It was a marker. Nothing more.

## How much it has grown

Since then the project has grown from **one module and one texture** into a **three-module client framework with a real server-side quest system** — and, more importantly, it learned how to stop inventing visuals and start *borrowing the engine's*.

The biggest technical leap came from reverse-engineering the client's native selection-circle render path (`ProjectTex2d`, `RsPush/RsPop`, `SetCircleRenderStates` — cross-validated across all.sym, binana, cmpgraph call graphs, and Ghidra). That unlocked **engine-native quest-mob highlighting**: the selected quest's kill targets are now ringed with the client's *own* selection circles, drawn through the *same* native path the engine uses — no injected geometry, no state leaks.

## What v2.0 introduces

- 🧭 **Retail-style world navigation** — the world quest marker and live distance text now use the retail `ingamenavigationui.blp` atlas, projected through the engine camera at the world→UI render seam.
- 🎯 **Quest objective highlighting** — native selection circles on every kill/interaction creature of the tracked quest, driven by a dedicated kill-entry protocol.
- 💀 **Corpse navigation** — a marker and distance readout that point at your corpse.
- 📋 **Retail "M" map Quest Tracker behavior** — the Objective Tracker dropdown mirrors the world map quest list exactly: same eligibility, same ordering, completed quests included, shared-zone quests handled.
- 💎 **Tracked-quest indicator** — a diamond icon rendered inside the Objective Tracker dropdown, to the left of the currently tracked quest's row.
- ⚙️ **Full Interface Options integration** — a dedicated "Quest Tracker" panel under a new third "Custom" tab, with **16 feature toggles** (marker style/size, fade-close, show-through, animated, distance units, font size/outline, alpha, and more) — powered by a reusable `TriAddCategory` panel registry.
- 🗺️ **Zone-aware tracking** — the server decides quest eligibility from the player's current zone and streams only what matters.
- 🚀 **Performance as a feature** — dirty-state caching, per-frame early-outs, deterministic render-state save/restore only when something is visible, and a release-prepared hot path.

## Why this is a major release

Because v2.0 is not v1.x with more features — it is a **different architecture**. The project was redesigned, refactored, and expanded into a modular framework (`wxl-quest-marker` + `wxl-selcircle-poc` + `wxl-custom-interface`), renamed to **WXL UI Tracker** to reflect what it actually is, and rebuilt around the principle that drives everything now:

> **Client's own engine first. Everything else second.**

The full story of the redesign is in [WHATS_NEW.md](WHATS_NEW.md) and the complete change list is in [CHANGELOG.md](CHANGELOG.md).

---

## Highlights at a glance

| | v1.x | v2.0 |
|---|---|---|
| Client modules | 1 | 3 |
| Rendering | Custom icon quad | Retail atlas + engine-native selection circles |
| Settings | Slash commands | Interface Options "Custom" tab, 16 toggles |
| Navigation | Quest marker + distance | + corpse, + quest-mob rings, + dropdown diamond, + M-map mirror |
| Server | Coordinate sender | Full quest system (zone eligibility, kill/item-drop resolution) |

---

**Enjoy!** Screenshots and full setup instructions are in the [README](README.md).
