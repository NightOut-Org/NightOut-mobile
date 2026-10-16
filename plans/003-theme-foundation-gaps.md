# 003 — Close app-wide theme gaps vs THEME.md

- **Status**: TODO
- **Owner**: —
- **Commit**: —
- **Priority**: HIGH
- **Estimated scope**: `packages/nightout_core` + small changes in both apps

## Problem

All values from `docs/nightout/THEME.md` are in `nightout_core`, but four app-wide rules are not
applied yet:

1. **Font fallback.** THEME.md: IBM Plex Sans Thai → Noto Sans Thai → system.
   `NightOutText.sans` and the text theme set only IBM Plex Sans Thai.
2. **Reduced motion.** AGENTS.md / THEME.md: respect `MediaQuery.disableAnimations`; when on,
   use a 150 ms fade or switch instantly. Nothing checks it; `LoadWidget` always spins.
3. **Theme choice in the client.** Users pick DARK / LIGHT / SYSTEM, stored under
   `nightout-theme`. The admin does this (`apps/admin/lib/main.dart` reads `SharedPreferences`,
   `apps/admin/lib/providers/main.provider.dart` writes it). The client is hard-coded to
   `ThemeMode.dark` in `apps/client/lib/app.dart`.
4. **Selected menu style.** THEME.md: selected menu = gold text + gold underline; normal =
   `muted`. Core's `navigationBarTheme` uses gold label/icon on a purple pill indicator
   (`colors.purple.withValues(alpha: 0.16)`), inherited from the admin scaffold, unverified.

## Target

1. `NightOutText.sans` and `nightOutTheme` text styles carry
   `fontFamilyFallback: [GoogleFonts.notoSansThai().fontFamily!]` (check `google_fonts` 8.x
   exposes it; otherwise bundle Noto Sans Thai as an asset in core).
2. A core helper, e.g. `extension on BuildContext { bool get reduceMotion =>
   MediaQuery.disableAnimationsOf(this); }`, and `LoadWidget` shows a static ring (no rotation)
   when it is true. AGENTS.md tells new animations to use it.
3. Theme-mode persistence moves into core: a Riverpod notifier (or plain class) that loads from
   and saves to `SharedPreferences` under `nightOutThemeStorageKey`. Both apps use it; delete the
   admin-local copy. `shared_preferences` becomes a core dependency. The client gets a way to
   change it (where the web puts it: navbar theme button / profile — check web first).
4. Find the web's mobile bottom nav and selected-tab style (start at
   `apps/frontend/src/layouts/main.tsx` in the web repo) and make `navigationBarTheme` match. If
   the web has no underline on mobile, update THEME.md instead of the code.

## Steps

1. Font fallback in core; screenshot a Thai + English string on the simulator.
2. `reduceMotion` helper + `LoadWidget`; widget test: with `MediaQuery(data: …disableAnimations:
   true)` the spinner has no `RotationTransition` running (assert observable output, not privates).
3. Move theme-mode state into core; migrate admin; wire client; test persists across a restart
   (`SharedPreferences.setMockInitialValues`).
4. Web nav check, then theme or doc change.
5. Run the full check list in root `AGENTS.md`.

## Done when

- [ ] Thai text renders with fallback configured (screenshot in PR).
- [ ] Reduced motion stops the spinner; test covers it.
- [ ] Client and admin both read/write `nightout-theme` through core; no copy in apps.
- [ ] Selected nav style matches the web (or THEME.md corrected), with the web file cited.
- [ ] `flutter analyze`, all tests, `gen_tokens --check`, `check_raw_colors.sh` pass.

## Progress notes

—
