# 006 — Cleanup outside the app code

- **Status**: TODO
- **Owner**: —
- **Priority**: LOW

Items left over from plan 001. Most live outside this repo, on someone's machine or in GitHub.

- [ ] **Delete the old admin repo.** Team lead archives or deletes
      `NightOut-Org/NightOut-admin-mobile` after plan 001 is pushed.
- [ ] **One copy of the handoff docs.** The web team's `docs/flutter/` (handed over outside git)
      duplicates `docs/nightout/` here. Tell the web team that `docs/nightout/` is the copy to
      update, or that they should send changes as PRs to this repo.
- [ ] **Backend secrets out of shared folders.** A `.env` with backend secrets
      (`SUPABASE_SERVICE_ROLE_KEY`, `DATABASE_URL`, `QR_SIGNING_KEY`, LINE token) was passed
      around with the handoff. It must never enter this repo; keep it in a password manager.
      Only `.env.dev` (publishable key + URLs) belongs at this repo's root, and it is gitignored.
- [ ] **Lift the Flutter pin** once `phosphor_flutter` publishes a release that supports
      Flutter 3.44+ (watch phosphor-icons/flutter issues #61, #64). Then: update root
      `pubspec.yaml` `environment.flutter`, run all checks on the new Flutter, and update the
      README toolchain line. On 3.44+, `CupertinoPageTransitionsBuilder` in
      `packages/nightout_core/lib/src/theme/theme.dart` needs
      `import 'package:flutter/cupertino.dart';`.
- [ ] **CI** (optional): a GitHub Action running `flutter analyze`, the three test suites,
      `tool/check_raw_colors.sh`, and `gen_tokens --check` (needs the web repo checked out at the
      branch chosen in plan 002).
