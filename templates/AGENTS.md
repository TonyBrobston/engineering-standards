# Working in this repository

Standards live in the `engineering-standards` skill
(github.com/TonyBrobston/engineering-standards). CI enforces them on every
pull request. This file only says how this repository runs them.

- Install: `npm ci`
- Check before opening or updating a PR: `npm run check`
- Unit tests: `npm test` (vitest, `tests/**/*.spec.ts`)
- Source lives in `src/`; tests in `tests/`. A change to `src/` ships with a
  failing-first test in `tests/`.
- Merge policy: `agents-merge`. Merge when CI is green and the assigned
  reviewer and QA have both recorded approval at the tested SHA.
