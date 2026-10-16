# 009 — Shared gold gradient title widget

- **Status**: IN PROGRESS
- **Owner**: agent: Claude Code (theme session, started 2026-10-16)
- **Commit**: —
- **Priority**: MEDIUM
- **Estimated scope**: one widget in `packages/nightout_core`, three call sites in the apps

## Problem

The gold gradient heading (`ShaderMask` `titleFrom` → `titleTo` on `NightOutText.display`) is
hand-rolled in three screens: admin login, admin splash, client splash. Each one sets the text to
`Colors.white`, because `ShaderMask`'s default `BlendMode.modulate` multiplies the gradient by the
text colour. That is a raw colour in app code, copied three times. Plan 005 row "Gold gradient
heading widget".

## Target

`GradientTitle` in `nightout_core` with `BlendMode.srcIn`: the gradient replaces the text colour,
so no white is needed. Sizes are named (`GradientTitleSize.page` = theme `headlineMedium`, 30;
`.hero` = 36, the admin login). The three screens call it; no `Colors.white` left in apps.

## Files claimed (other agents: do not edit until Status is DONE)

`packages/nightout_core/`: `lib/nightout_core.dart`, `lib/src/widgets/gradient_title.dart` (new),
`test/gradient_title_test.dart` (new).
`apps/admin/lib/screen/login/login.page.dart` (title block only),
`apps/admin/lib/screen/splash.screen.dart`, `apps/client/lib/screen/splash.screen.dart`.
`plans/009`, `plans/005` (one row), one row in `plans/README.md`.

## Done when

- [ ] `GradientTitle` exported from `nightout_core`, with a test
- [ ] the three screens use it; `grep -rn "Colors.white" apps/*/lib` prints nothing
- [ ] all checks in root `AGENTS.md` "ก่อนบอกว่าเสร็จ" pass

## Progress notes

—
