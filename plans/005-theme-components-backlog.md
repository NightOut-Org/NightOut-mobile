# 005 — Theme components built with their first screen

- **Status**: BACKLOG
- **Owner**: —
- **Priority**: LOW (each item becomes required when its screen is built)

## Why a backlog

These pieces from `docs/nightout/THEME.md` have values in `nightout_core` but no widget. Building
them before a screen needs them would mean guessing the API. Build each one inside the feature
that first uses it, put it in `nightout_core` if both apps can use it, and tick it here.

| Item | THEME.md rule | Values already in core | First likely screen |
|---|---|---|---|
| [ ] Gold gradient login button | `#FFD77A` → `#E8B64C`, text `#1A1206`, radius 12, height 46, glow `(0,8) blur 22 spread -8 rgba(232,182,76,.65)` | `goldHighlight`, `gold` (gradient, text colour and glow are in `AuthColors` since plan 008: `buttonFrom`, `buttonTo`, `buttonLabel`, `buttonShadow`) | client + admin login (plan 004): both now hand-roll it and differ (client = `AuthColors` gradient, admin = flat `gold`); pick one, then move to core |
| [x] Gold gradient heading widget (`GradientTitle`, plan 009) | `ShaderMask` `titleFrom` → `titleTo` on `NightOutText.display` | `titleFrom`, `titleTo` | already hand-rolled in both splash screens and admin home; extract on next use |
| [ ] Crowd status | dot **and** word: ว่าง / ใกล้เต็ม / เต็ม | `crowdAvailable`, `crowdAlmostFull`, `crowdFull` | client bar card / bar page |
| [ ] Star rating | filled `goldText`, empty `border`, 1–5 | `goldText`, `border` | client bar card |
| [ ] Icon weight on select | normal = Phosphor regular + `muted`; selected = fill + `goldText` | `muted`, `goldText` | bottom navigation |
| [ ] Bottom island nav | floating pill bar like web `BottomIsland` (`apps/frontend/src/ui/components/navbar.tsx`): selected item on a solid `gold` pill, `onGold` text + fill icon; others `muted` + regular; 11 px labels; spring 420/34 (instant under reduced motion) | `navigationBarTheme` colours, `context.reduceMotion` | first screen with tabs (client) |
| [ ] Card press / glow | press scale 0.98; dark glow = gold 1px ring + purple shadow | `NightOutMotion.pressedScale`, `glow` | first tappable card |
| [ ] Sheet motion | spring stiffness 380, damping 32 | `NightOutMotion.sheetStiffness/sheetDamping` | first bottom sheet |
| [ ] Tier badge | S/A/B/C colours (Backoffice charts only) | `NightOutTier` | admin `/ranking` |

All motion must respect reduced motion: check `context.reduceMotion` (plan 003).
