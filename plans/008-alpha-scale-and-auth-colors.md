# 008 — Opacity scale and auth-screen colours in nightout_core

- **Status**: DONE
- **Owner**: agent: Claude Code (theme session, started 2026-10-16)
- **Commit**: 48ef5f9
- **Priority**: MEDIUM
- **Estimated scope**: `packages/nightout_core` theme, one line in `apps/admin`, docs

## Problem

Apps may not write `Color(0x…)` (`tool/check_raw_colors.sh`), but screens still need colours that
`NightOutColors` does not have:

- **Tints of a token.** The web writes `border-purple/45`, `bg-white/15`, `bg-black/55`. Mobile
  screens repeat this as `colors.x.withValues(alpha: 0.12)` with a magic number
  (`apps/admin/lib/screen/login/login.page.dart`).
- **Colours that belong to one feature.** The web auth modal (`apps/frontend/src/styles/index.css`,
  `.auth-glass`, `.auth-modal …`) has its own glass card, field fill, focus purple `#8B4FE0` and
  gold-gradient button with label `#1A1206`. None of these are in `tokens.ts`.

## Target

- `NightOutAlpha`: a named opacity scale in `tokens.dart`, used as
  `colors.purple.withValues(alpha: NightOutAlpha.medium)`.
- `AuthColors`: a `ThemeExtension` in core with the web auth-modal values, registered by
  `nightOutTheme()` and read with `context.authColors`. Lives in core, not an app, because both apps
  have login screens and apps may not hold hex colours.
- Rule written down in `AGENTS.md` and `docs/nightout/THEME.md`: page-specific colour = token +
  `NightOutAlpha`, or a feature extension in core.

## Files claimed (other agents: do not edit until Status is DONE)

`packages/nightout_core/`: `lib/nightout_core.dart`, `lib/src/theme/tokens.dart`,
`lib/src/theme/theme.dart`, `lib/src/theme/auth_colors.dart` (new),
`test/auth_colors_test.dart` (new).
`apps/admin/lib/screen/login/login.page.dart` (one line: the error-box tint).
`AGENTS.md` (theme section), `docs/nightout/THEME.md`, `plans/008`, one row in `plans/README.md`.

## Done when

- [x] `NightOutAlpha` and `AuthColors` exported from `nightout_core`
- [x] `nightOutTheme()` registers `AuthColors` for both brightnesses; test covers it
- [x] admin login error box uses `NightOutAlpha` instead of `0.12`
- [x] rule documented in `AGENTS.md` + `THEME.md`
- [x] all checks in root `AGENTS.md` "ก่อนบอกว่าเสร็จ" pass

## Progress notes

- `AuthColors` is defined but no screen uses it yet. The admin login (plan 007, ported as-is) only
  needed the error-box tint. Use it when the client login / register screens are built (plan 005).
- The web auth modal has no light variant, so `AuthColors.light` is the same object as `dark`.
