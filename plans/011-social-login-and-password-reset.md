# 011 — Client social login, deep link and password reset

- **Status**: TODO
- **Owner**: —
- **Commit**: —
- **Priority**: MEDIUM
- **Estimated scope**: `apps/client` (login, new screens, iOS/Android config), small core additions

## Problem

Plan 004 gives the client app email/password login only (owner decision 2026-10-16). Web `/login`
also offers Google and Facebook, a forgot-password flow, and a first-time social signup page. None
of these exist on mobile.

## Facts from the web repo (`NightOut-Org/NightOut`)

- `apps/frontend/src/ui/components/authLoginForm.tsx`: `signInWithOAuth({ provider, options: {
  redirectTo, scopes: OAUTH_BIRTHDAY_SCOPE[provider] } })`. Scopes in `packages/utils/src/age.ts`:
  Google `https://www.googleapis.com/auth/user.birthday.read`, Facebook `user_birthday`. Note under
  the buttons: "สมัครด้วย Google / Facebook ต้องมีวันเกิดในบัญชีและอายุ 20 ปีขึ้นไป".
- `apps/frontend/src/services/auth.tsx`: after an OAuth login, `GET /me/profile` failing with
  `USER_NOT_FOUND` and an OAuth provider in `app_metadata.provider` means "no account yet"
  (`needsOAuthSignup`) → `/signup/social` (age 20+ check + terms).
- `authForgotForm.tsx`: email → `resetPasswordForEmail(redirectTo)` → result in the same box, resend /
  back to login. SITEMAP §2 rows `/forgot-password`, `/reset-password`.
- Mobile redirect URL: `Env.authRedirectUrl` (`nightout://auth-callback`).

## Steps

1. Register the `nightout` scheme: iOS `Info.plist` `CFBundleURLTypes`, Android
   `AndroidManifest.xml` `intent-filter` (`VIEW`, `DEFAULT`, `BROWSABLE`, scheme `nightout`, host
   `auth-callback`). `supabase_flutter` picks up the link itself.
2. Google + Facebook buttons on the login screen per `authLoginForm.tsx`, with the birthday scopes
   and `redirectTo: Env.authRedirectUrl`.
3. `USER_NOT_FOUND` after OAuth → social signup screen per web `/signup/social` (read that page
   first; age and terms rules come from `packages/contracts`).
4. Forgot password per `authForgotForm.tsx`; handle the `passwordRecovery` auth event with a
   set-new-password screen per web `/reset-password`.

## Owner tasks (outside the code)

- Supabase → Authentication → URL Configuration → Redirect URLs: add `nightout://auth-callback`.
- Google Cloud / Meta consoles: register bundle id `com.night.nightout`, package name
  `com.night.nightout` and its SHA-1.

## Done when

- [ ] Google and Facebook login work on the simulator with a test account and return to the app.
- [ ] A first-time social account reaches the signup screen; a too-young birthday is refused.
- [ ] Forgot password sends the email; the link opens the app on the new-password screen.

## Progress notes

—
