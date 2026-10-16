# 002 — Choose the web branch that tokens follow

- **Status**: BLOCKED (owner decision)
- **Owner**: —
- **Commit**: —
- **Priority**: MEDIUM
- **Estimated scope**: README only

## Problem

`node tool/gen_tokens.mjs --check` compares `tokens.g.dart` with whatever branch the local web
repo (`NightOut-Org/NightOut`) has checked out. The web repo uses `demo` for development and
`main` for deploys. Two teammates on different branches can get different results, and a token
change on `demo` could reach the apps before it ships on the website.

## Decision needed

Which branch is the source of truth for mobile theme tokens: `main` (what users see on the web)
or `demo` (latest work)?

## Steps once decided

1. Add the branch to the "ธีมจากเว็บ" section of root `README.md` and to `docs/nightout/THEME.md`
   ("run the generator with the web repo on `<branch>`").
2. Optional: make `tool/gen_tokens.mjs` print the web repo's current branch and warn when it
   differs (`git -C $WEB rev-parse --abbrev-ref HEAD`).

## Done when

- [ ] README and THEME.md name the branch.
- [ ] (optional) generator warns on the wrong branch.
