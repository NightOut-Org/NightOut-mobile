# 001 — Merge client + admin into one pub workspace

- **Status**: DONE
- **Owner**: Win + agent: Claude Code (session 2026-10-16)
- **Commit**: —
- **Priority**: HIGH

## Problem

The client app (`NightOut-Org/NightOut-mobile`) and the Backoffice app
(`NightOut-Org/NightOut-admin-mobile`) were separate repos copied from one template. After one
commit each they had already diverged: the client used the template's Coral/Azure palette, the
admin used Midnight Gold with hand-copied hex values. The rule is "mobile follows web; web wins
on conflict", and nothing enforced it.

Decisions from the owner: the admin app is for **NightOut Backoffice** (web `apps/admin`, not the
`/merchant` pages); both apps live in this repo; the team lead deletes the admin repo later.

## What was done

- Pub workspace: `apps/client` (git mv of the old root), `apps/admin` (copied from the admin
  repo), `packages/nightout_core`.
- `nightout_core` holds the theme (`NightOutColors`, `nightOutTheme`, `NightOutText`,
  `NightOutMotion`, `NightOutRadius`, `NightOutTier`, `context.colors`), `NightOutThemeMode`,
  `Env`, `LoadWidget`.
- `tool/gen_tokens.mjs` generates `packages/nightout_core/lib/src/theme/tokens.g.dart` from web
  `packages/ui/src/tokens.ts` + `theme.css`. `--check` exits 1 on drift.
- `tool/check_raw_colors.sh` fails on `Color(0x…)` in `apps/*/lib`.
- Deleted from the client: template `style/`, `button.dart`, `modal.bottom.dart`, `load.widget.dart`,
  and the API models (they modelled `error_code`/`error_desc`, not the NightOut envelope).
- Client `ContentLayout` replaced by the admin one (no coloured header band). Visual change.
- Flutter pinned `>=3.41.9 <3.44.0` in root `pubspec.yaml`: `phosphor_flutter` 2.1.0 (latest)
  extends `IconData`, which is `final` from Flutter 3.44. Upstream fixes are unmerged PRs
  (#62, #63, #66 on phosphor-icons/flutter).
- Rules: root `AGENTS.md`, `apps/client/AGENTS.md`, `apps/admin/AGENTS.md`, `CLAUDE.md`
  (`@AGENTS.md`) in each. Handoff docs in `docs/nightout/` with links fixed to
  `NightOut-Org/NightOut`. `.gitignore` covers `.env*`.

## Verification (done, Flutter 3.41.9)

- `flutter analyze` → no issues. Tests pass: core 3, client 1, admin 1 (dark → light switch).
- Core test fails when `onSurfaceVariant` is dropped from the scheme (the bug in the old theme doc).
- `gen_tokens --check` passes on the real web repo and fails on a copy with one hex changed.
- 44 generated colours compared with the admin's old hand-copied values: 0 mismatches.
- Both apps launched on the iPhone 16 Pro simulator with `.env.dev`: Midnight Gold dark.

## Remaining

- [x] Teammate commits or stashes their own work in this repo first (every file moves). (Confirmed by Win 2026-10-16: no other work in the tree.)
- [x] Commit as one commit, or two (code, then docs/tools/plans). A three-way split by app does
      not build: the root pubspec lists all members and both apps import core.
      Suggested message: `chore(workspace): merge client and admin apps into one pub workspace`
- [ ] Push; team lead archives/deletes `NightOut-Org/NightOut-admin-mobile`.

## Progress notes

- The uncommitted overwrite of the old root `README.md` (it held the handoff README) was
  discarded with `git restore`; the content lives in `docs/nightout/README.md`.
- First iOS build integrated CocoaPods into `apps/client/ios` and created `Podfile.lock` in both
  apps. Kept, matching what the admin repo already tracked.
