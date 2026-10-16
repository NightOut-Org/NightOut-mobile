# Plans

Work tracking for the NightOut mobile workspace. Each plan is self-contained: a person or an
agent can pick one up cold, without the conversation that produced it.

| # | Plan | Priority | Status |
|---|---|---|---|
| 001 | [Merge client + admin into one pub workspace](001-workspace-restructure.md) | HIGH | DONE |
| 002 | [Choose the web branch that tokens follow](002-token-source-branch.md) | MEDIUM | BLOCKED (owner decision) |
| 003 | [Close app-wide theme gaps vs THEME.md](003-theme-foundation-gaps.md) | HIGH | DONE |
| 004 | [API client + Supabase auth in nightout_core](004-api-client-and-auth.md) | HIGH | TODO |
| 005 | [Theme components built with their first screen](005-theme-components-backlog.md) | LOW | BACKLOG |
| 006 | [Cleanup outside the app code](006-cleanup.md) | LOW | TODO |
| 007 | [Port admin login + MFA + dashboard from 4c742d7](007-port-admin-login-4c742d7.md) | HIGH | DONE |
| 008 | [Opacity scale + auth-screen colours in core](008-alpha-scale-and-auth-colors.md) | MEDIUM | DONE |
| 009 | [Shared gold gradient title widget](009-gradient-title-widget.md) | MEDIUM | IN PROGRESS |

## Recommended order

1. **001** — committed.
2. **003** and **004** — independent of each other; can run in parallel.
3. **002** — whenever the owner answers; a one-line README change.
4. **005** — item by item, inside the feature work that first needs each component.
5. **006** — any time.

## Dependencies

- Everything depends on 001 being committed.
- 004's admin login (MFA) needs 003's theme-mode work only if the login screen shows the theme
  switch; otherwise independent.

## How to use this folder

- Starting a plan: set its **Status** to `IN PROGRESS` and **Owner** to your name (or
  "agent: <tool>"), both in the plan file and in the table above.
- Finishing: set `DONE`, fill **Commit**, and tick the "Done when" boxes. If you stop halfway,
  write what is left under **Progress notes** in the plan.
- New work: add the next number (`007-short-slug.md`) using the same headings, and a row here.
- Statuses: `TODO` · `IN PROGRESS` · `BLOCKED (reason)` · `BACKLOG` · `DONE`.
- Toolchain for every plan: Flutter 3.41.x (see root `README.md`), and the rules in root
  `AGENTS.md` plus `apps/<app>/AGENTS.md`.
