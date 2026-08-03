# Assets

All textures required by WXL UI Tracker. Deploy them into the WoW client's patch archive (e.g. `Data/patch-A.MPQ/`).

| File | Deploy path | Used by |
|---|---|---|
| `textures/navigation/ingamenavigationui.blp` | `Interface/navigation/ingamenavigationui.blp` | Retail navigation UI atlas — the world quest marker and the Objective Tracker diamond both sample this atlas |
| `textures/highlightcircle/unitselecttexture-quest.blp` | `Textures/questmarker/unitselecttexture-quest.blp` | Quest-mob selection-circle texture (native circle drawn on the selected quest's kill/interaction creatures) |

If the navigation atlas BLP is missing, the marker module falls back to a procedural texture so the system still works.
