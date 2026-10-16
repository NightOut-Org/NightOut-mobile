# 010 — Port admin auth fixes from NightOut-admin-mobile 18f3329 + 591bd4a

- **Status**: IN PROGRESS
- **Owner**: agent: Claude Code (admin port, started 2026-10-16)
- **Commit**: —
- **Priority**: HIGH
- **Estimated scope**: `apps/admin` only

## Problem

After plan 007 copied `4c742d7`, siripol.w pushed two more commits to the old
`NightOut-Org/NightOut-admin-mobile` repo:
- `18f3329`: `[HTTP]` debug print of each request URL; log label rename in `auth.service.dart`.
- `591bd4a` "fix(auth): reuse verified TOTP and clear stale factors before enroll": `MfaPlan`,
  tolerant factor parsing, unenroll unverified TOTP factors before enrolling, double-submit guard,
  role label in the "not admin" message, `ลองใหม่` login button after an error, and
  `test/auth_mfa_test.dart`.

## Target

Same rule as 007 (owner decision): copy as-is, adapt only what plans 001/003/008/009 changed.

## Files claimed (other agents: do not edit until Status is DONE)

`apps/admin/`: `lib/models/auth/*`, `lib/modules/**`, `lib/utils/http.dart`,
`lib/screen/login/login.page.dart`, new `test/auth_mfa_test.dart`. `plans/010`, one row in
`plans/README.md`, the Known issues section of `plans/007`.

## Steps

1. Apply `git diff 4c742d7 591bd4a -- lib test` from the old repo as a patch under `apps/admin`.
2. Adapt only lines that differ on our side (`config.dart` import → `nightout_core`, `Config` env →
   `Env`); keep 008/009's `GradientTitle` and `NightOutAlpha.subtle` in the login page.
3. Run the check list in root `AGENTS.md`; run the admin app on the simulator.

## Done when

- [ ] Ported files equal the teammate's `591bd4a` versions except the adaptation lines.
- [ ] `flutter analyze`, all tests (incl. `auth_mfa_test.dart`), `gen_tokens --check`,
      `check_raw_colors.sh` pass.
- [ ] Admin runs on the simulator: splash → login.

## Progress notes

—
