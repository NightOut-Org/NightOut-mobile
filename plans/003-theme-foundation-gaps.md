# 003 — Close app-wide theme gaps vs THEME.md

- **Status**: IN PROGRESS
- **Owner**: agent: Claude Code (theme session, started 2026-10-16)
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


## Files claimed (other agents: do not edit until Status is DONE)

The theme session owns these files while this plan is IN PROGRESS. If you need a change in one of
them, write it under **Progress notes** below instead of editing the file.

- `packages/nightout_core/`: `lib/src/theme/*`
  (`tokens.g.dart` stays generator-owned), new `lib/src/motion.dart`, `lib/src/widgets/*`, `test/theme_test.dart` + new `test/theme_*_test.dart` / `test/load_widget_test.dart`
- `apps/admin/`: `lib/app.dart`, `lib/providers/main.provider.dart`,
  `lib/screen/home/home.page.dart`, `test/widget_test.dart`
- `apps/client/`: `lib/app.dart`, `lib/screen/home/home.page.dart`,
  `test/widget_test.dart`, plus client screens fixed for light mode (listed here when touched)
- `docs/nightout/THEME.md`, root `AGENTS.md` (theme rules section only), `plans/003`, one new row in `plans/005`

Shared, small edits only (re-read the file right before editing, add lines, do not reorder):
`packages/nightout_core/pubspec.yaml` (this plan adds `flutter_riverpod`, `shared_preferences`),
`packages/nightout_core/lib/nightout_core.dart` (this plan adds export lines), `plans/README.md`,
`apps/*/lib/main.dart` (this plan only adds the theme-mode load + `ProviderScope` override; plan 004
may add Supabase init there).

Free for other work: everything else, including API/auth (plan 004) in new files under
`packages/nightout_core/lib/src/` other than `theme/`, `widgets/`, `motion.dart`, and the
client/admin `pubspec.yaml` files.

Scope added after reading the web:
- Nav style follows web `apps/frontend/src/ui/components/navbar.tsx` `BottomIsland`: solid gold
  pill for the selected item, not a gold underline. THEME.md gets corrected.
- Display font fallback Playfair Display → Georgia.
- Theme switch animation: 300 ms easeOut fade, instant when reduced motion is on.
- Shared `NightOutThemeModeMenu` in core, used by both apps' home app bar.

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
