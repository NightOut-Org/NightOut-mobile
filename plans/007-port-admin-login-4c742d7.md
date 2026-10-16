# 007 — Port admin login, TOTP MFA and dashboard from NightOut-admin-mobile 4c742d7

- **Status**: IN PROGRESS
- **Owner**: agent: Claude Code (admin port, started 2026-10-16)
- **Commit**: —
- **Priority**: HIGH
- **Estimated scope**: `apps/admin` only

## Problem

siripol.w committed login + TOTP MFA + dashboard + a 5-tab home to the old
`NightOut-Org/NightOut-admin-mobile` repo (`4c742d7`, 2026-10-16 13:43) after its first commit was
copied into `apps/admin` (plan 001). None of it is in this repo.

## Target

Owner decision (2026-10-16): copy the teammate's work **as it is**. Change only what plans 001 and
003 broke (theme moved to `nightout_core`, `Env` in core, theme mode in core, router path, splash
status bar, test). No redesign and no bug fixes; known issues are listed below for plan 004.

## Files claimed (other agents: do not edit until Status is DONE)

`apps/admin/`: `lib/app.dart`, `lib/app.router.dart` (moved from `lib/router/`), `lib/config.dart`,
`lib/models/auth/*`, `lib/modules/**`, `lib/screen/**`, `lib/utils/*`, `test/widget_test.dart`,
`pubspec.yaml`, `analysis_options.yaml`, `ios/RunnerTests/RunnerTests.swift`.
Root `pubspec.lock`. `plans/007`, one row in `plans/README.md`.

## Steps

1. Copy files from `4c742d7` verbatim.
2. Adapt imports and names to core (`NightOutText`, `NightOutText.display`, `Colors.*`, core
   `LoadWidget`, `NightOutThemeModeMenu`, `Env`).
3. Merge the teammate's splash and test changes into the 003 versions.
4. Run the check list in root `AGENTS.md`; run the admin app on the simulator.

## Done when

- [ ] All teammate features present in `apps/admin` (login, enroll/verify, restore, 5-tab home,
      dashboard, account, sign-out).
- [ ] `flutter analyze`, all tests, `gen_tokens --check`, `check_raw_colors.sh` pass.
- [ ] Admin runs on the simulator: splash → login, theme switch works.

## Known issues (copied as-is, not fixed here — for plan 004)

1. Dashboard calls `/api/admin/dashboard`; `API_BASE_URL` already ends in `/api` → `/api/api/…`.
   The parser expects `{total, unit, items}`; the API returns the 7-key `admin_dashboard` row
   (web `apps/admin/src/modules/dashboard/page.tsx`) → shows 0 and no rows.
2. `log()` in `auth.service.dart` prints access tokens and the TOTP secret to the debug console.
3. Session is a raw access token in SharedPreferences with no refresh → relaunch after ~1 h goes
   back to login.
4. Login differs from web `apps/admin/src/modules/login/page.tsx`: 3 steps vs 2; no unenroll of
   unverified TOTP factors before enrolling (a second enroll may fail); no Thai error mapping;
   "ใช้รหัสอื่น" instead of web's "ใช้บัญชีอื่น" (sign out); no `MFA_REQUIRED` handling.
5. Root `AGENTS.md` conflicts: HTTP client and auth live in the app (rule: core, via
   `supabase_flutter`); `utils/password.rules.dart` and `utils/util.dart` duplicate the client's
   copies (rule: no copying between apps); 120-column formatter only in admin.
6. `ios/RunnerTests/RunnerTests.swift` deleted as the teammate did, but `project.pbxproj` still
   references it (the Runner target is unaffected).
7. The 5 tabs (หน้าแรก / รายงาน / ร้าน / แจ้งเตือน / บัญชี) are the teammate's, not web's
   `apps/admin/src/configs/menu.tsx`; 3 are placeholders. Kept by owner decision.

## Progress notes

—
