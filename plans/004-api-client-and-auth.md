# 004 — API client + Supabase auth in nightout_core

- **Status**: TODO
- **Owner**: —
- **Commit**: —
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

## Steps

1. Add `dio`, `supabase_flutter` (check a version that supports Flutter 3.41) to core; remove
   `dio` from the client pubspec if core re-exports what the client needs.
2. `ApiException` + `ApiClient` with an interceptor. Unit tests with a fake Dio adapter: ok
   envelope returns `data`; `no` envelope throws with `code`/`err_msg`; 401 with
   `unauthorizedCode` throws that code.
3. Supabase init in both `main.dart` (after `WidgetsFlutterBinding.ensureInitialized()`).
4. Client: email/password + Google + Facebook login screen per web `/login` (SITEMAP §2). Deep
   link setup. Note: Google/Facebook also need bundle id / package name + SHA-1 registered in
   their consoles (owner task).
5. Admin: email/password → role check (`/me/profile`) → TOTP enroll/verify → `aal2`, per web
   `apps/admin` login. 401 `MFA_REQUIRED` routes back to the code screen.
6. Smoke test against the deployed API with a **test account only** (data is real).

## Done when

- [ ] Core `ApiClient` + `ApiException` with tests for the three envelope cases.
- [ ] Client can log in with email/password on the simulator and call one authenticated endpoint.
- [ ] Admin can log in with MFA on the simulator and load `GET /admin/dashboard`.
- [ ] No `supabase.from()/rpc()/storage` anywhere (grep); no URL/key hard-coded.
- [ ] Root `AGENTS.md` "ยังไม่ได้สร้าง" note about the HTTP client removed.

## Progress notes

—
