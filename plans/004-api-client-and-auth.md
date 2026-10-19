# 004 — API client + Supabase auth in nightout_core

- **Status**: DONE
- **Owner**: agent: Claude Code (API + auth, started 2026-10-16)
- **Commit**: 1346dc0, 721f2e1, 02cf4cf, 61b818f, fac9a4b, e611b06
- **Priority**: HIGH
- **Estimated scope**: new code in `packages/nightout_core`, login screens in both apps

## Problem

Neither app can talk to the backend yet. Root `AGENTS.md` already fixes the shape: one Dio client
in core, NestJS only, `supabase_flutter` for `supabase.auth.*` only. The client app has `dio` in
its pubspec but no client; no app depends on `supabase_flutter` yet.

## Facts from the web repo (`NightOut-Org/NightOut`)

- Envelope on every endpoint: `{ status: 'ok' | 'no', status_code, data, code, err_msg }`.
  Web's `packages/utils/src/rest.ts` (class `Rest`, `ApiError`) unwraps `data` and throws
  `ApiError(status_code, code, err_msg)` when `status != 'ok'`. Mirror that, don't invent.
- `Rest.configure({ unauthorizedCode })`: the Backoffice sets `MFA_REQUIRED`, so a 401 means
  "verify the 6-digit code again", not "log out".
- Error codes per domain: `packages/contracts/src/<domain>.ts` (`<DOMAIN>_ERRORS`).
- Backoffice MFA (web `apps/admin/src/modules/login/page.tsx`, `services/adminAuth.tsx`):
  `supabase.auth.mfa.listFactors()` → if none verified, `enroll` a TOTP factor (unenroll
  unverified leftovers first) → `challengeAndVerify({ factorId, code })` → check
  `getAuthenticatorAssuranceLevel()` is `aal2`. Role comes from `GET /me/profile`.
- Customer auth: email + password, Google, Facebook. `redirectTo: Env.authRedirectUrl`
  (`nightout://auth-callback`) on `signInWithOAuth` and `resetPasswordForEmail`.

## Target

```
packages/nightout_core/lib/src/api/
  api_client.dart      Dio + interceptor: Bearer token from Supabase session, unwrap envelope
  api_exception.dart   ApiException(statusCode, code, errMsg)
packages/nightout_core/lib/src/auth/
  supabase.dart        Supabase.initialize(url: Env.supabaseUrl, anonKey: Env.supabaseAnonKey)
```

- `ApiClient(baseUrl: Env.apiBaseUrl, unauthorizedCode: …)`: admin passes `'MFA_REQUIRED'`.
- Models: `json_serializable` with `fieldRename: FieldRename.snake`, generated from
  `packages/contracts` or the Swagger spec (https://night-out-demo.vercel.app/api/docs).
- Deep link scheme `nightout` registered in `apps/client` iOS `Info.plist` (`CFBundleURLTypes`)
  and Android `AndroidManifest.xml` (`intent-filter`). Ask the repo owner to add the URL to
  Supabase → Authentication → URL Configuration → Redirect URLs.

## Files claimed (other agents: do not edit until Status is DONE)

`packages/nightout_core/`: `pubspec.yaml`, `lib/nightout_core.dart`, new `lib/src/api/**`,
`lib/src/auth/**`, new tests under `test/`. `apps/admin/`: `pubspec.yaml`, `lib/**` (except
`lib/screen/home/` tab placeholders beyond the dashboard and account), `test/**`. `apps/client/`:
`pubspec.yaml`, `lib/main.dart`, `lib/router/`, `lib/screen/{login,home,splash.screen.dart}`, new
`lib/modules/**` auth files, `test/**`. Root `pubspec.lock`, `AGENTS.md` (HTTP client note only),
`docs/nightout/README.md` (auth/API sections), `plans/004`, `plans/011`, rows in `plans/README.md`,
Known issues of `plans/007`.

## Steps

1. Add `dio`, `supabase_flutter` (check a version that supports Flutter 3.41) to core; remove
   `dio` from the client pubspec if core re-exports what the client needs.
2. `ApiException` + `ApiClient` with an interceptor. Unit tests with a fake Dio adapter: ok
   envelope returns `data`; `no` envelope throws with `code`/`err_msg`; 401 with
   `unauthorizedCode` throws that code.
3. Supabase init in both `main.dart` (after `WidgetsFlutterBinding.ensureInitialized()`).
4. Client: email/password login screen per web `/login` (SITEMAP §2,
   `apps/frontend/src/ui/components/authLoginForm.tsx`). Owner decision 2026-10-16: email/password
   only here; Google/Facebook, the `nightout` deep link, forgot password and `/signup/social` are
   plan 011.
5. Admin: email/password → role check (`/me/profile`) → TOTP enroll/verify → `aal2`, per web
   `apps/admin` login. 401 `MFA_REQUIRED` routes back to the code screen. Keep plan 010's behavior
   (stale TOTP factors unenrolled before enroll, no sign-out on enroll/code errors) and port
   `test/auth_mfa_test.dart` to the new seam.
6. Smoke test against the deployed API with a **test account only** (data is real).

## Done when

- [x] Core `ApiClient` + `ApiException` with tests for the three envelope cases.
- [x] Client can log in with email/password on the simulator and call one authenticated endpoint.
- [ ] Admin can log in with MFA on the simulator and load `GET /admin/dashboard`. **Waived by owner
      2026-10-19**: the only admin test account has no TOTP factor, and enrolling one on a shared real
      account was declined. Covered by 18 controller tests on fakes; run it live once an admin
      account with a known TOTP secret exists.
- [x] No `supabase.from()/rpc()/storage` anywhere (grep); no URL/key hard-coded.
- [x] Root `AGENTS.md` "ยังไม่ได้สร้าง" note about the HTTP client removed.

## Progress notes

2026-10-16: plan 007 copied the teammate's admin login (`4c742d7`) as-is, with its own HTTP client
and hand-written Supabase REST calls in `apps/admin/lib/modules/` + `lib/utils/http.dart`. Step 5
now means replacing that code with core `ApiClient` + `supabase_flutter`, and fixing the known
issues listed in `plans/007-port-admin-login-4c742d7.md`.

2026-10-16, agent: Claude Code (paused mid live test, owner asked to pause):
- Committed on main: `1346dc0` core ApiClient/ApiException/MyProfile/Supabase init, `721f2e1` client
  email/password login, `02cf4cf` admin login + MFA + dashboard on core (fixes 007 known issues 1-5),
  `61b818f` single core entrypoint, `fac9a4b` Env defaults from `6094016` removed (owner decision:
  values only via `--dart-define-from-file=../../.env.dev`), guard + test restored.
- Checks on main: analyze clean; core 34, client 14, admin 19 tests pass; gen_tokens and raw colours pass.
- Simulator: client builds and shows the login card. Live login not yet confirmed.
- Left to do: (1) live client login with the account in `<NightOut root>/docs/creds/app_password.txt`
  (one account; check its role). An integration test for this lives outside the repo; re-add it under
  `apps/client/integration_test/` with `integration_test` (sdk) in dev_dependencies, pass creds with
  `--dart-define`, never commit it. (2) live admin login + TOTP + dashboard (needs an admin account; if
  the creds account is not backoffice, ask the owner). (3) close 004, update plan 007 known issues,
  plan 005 note: gold button / error banner / field exist in both apps with different looks.
- Open with the owner: `.env.dev` is still tracked in git since `52a9ad7` (rule says never commit it).

2026-10-19, agent: Claude Code (closing):
- Live client test on the iPhone 16 simulator against the deployed API with the account in
  `docs/creds` (role ADMIN, so client login works with it too): wrong password shows
  'อีเมลหรือรหัสผ่านไม่ถูกต้อง'; real password signs in, `GET /me/profile` 200, home shows name, role
  label and email; a fresh `flutter run` launch restores the stored session and opens home (200 again).
- Driven with a throwaway integration test (not committed). `flutter test` uninstalls the app after
  the run, so a relaunch check needs `flutter drive --keep-app-running` then `flutter run`.
- Admin live MFA test waived (see Done when). Teammate's `ad3ea59` added debug-only request logging
  (method, path, status) to `ApiClient`; consistent with the no-headers/body/token rule.
- Follow-ups: plan 011 (social login, deep link, password reset); plan 005 gold button row (client
  uses the `AuthColors` gradient, admin uses flat `gold`; pick one before moving it to core).

