# engineering-standards

One place for how code is written, reviewed, and merged across every Brobston
repository. Agents on any provider read the same rules; CI enforces the
mechanical ones.

| What | Where | Consumed by |
| --- | --- | --- |
| The standard, in prose | `skills/engineering-standards/SKILL.md` | Paperclip skill (tracks `main`); reviewers' checklist |
| ESLint config + `no-comments` rule | `eslint/` | `@tonybrobston/engineering-standards/eslint` |
| Vitest base config with coverage thresholds | `vitest/` | `@tonybrobston/engineering-standards/vitest` |
| Ruff config | `ruff.toml` | copied into Python repos |
| Python no-comments check | `scripts/check_no_comments.py` | reusable workflow |
| Test-first proof | `scripts/tests-must-fail-without-source.sh` | reusable workflow |
| Reusable CI workflow | `.github/workflows/standards.yml` | every repo's `ci.yml` |
| Per-repo pointer files | `templates/` | copied once per repo |
| Paperclip skills and slim agent files | `paperclip/` | see `paperclip/CHANGES.md` |

## Adding a repository (Node)

1. Copy `templates/AGENTS.md` and `templates/CLAUDE.md` to the repo root.
   Edit the commands, paths, and `merge_policy` line to match.
2. Copy `templates/ci.yml` to `.github/workflows/ci.yml`. Adjust
   `package-manager` and the commands.
3. Copy `templates/eslint.config.mjs` (or `eslint.config.next.mjs` for a
   Next.js app) and `templates/vitest.config.ts` (jest repos keep jest; set
   `coverageThreshold` to the values in `vitest/base.js`).
4. Merge `templates/package.json.snippet` into `package.json` and run
   `npm install`.
5. Run `npm run check`. Expect lint failures on existing comments and short
   names; fix them in one `refactor`-labelled PR before enabling branch
   protection.

## Adding a repository (Python)

1. Copy `templates/AGENTS.md` and `templates/CLAUDE.md`; edit commands and
   `merge_policy`.
2. Copy `templates/ci-python.yml` to `.github/workflows/ci.yml`.
3. Copy `ruff.toml` into the repo (or merge its `[lint]` section into
   `pyproject.toml`).
4. Run `ruff check . && python3 scripts/check_no_comments.py .` from a
   checkout of this repo, fix, then enable branch protection.

## Branch protection (per repository, Settings → Branches → main)

- Require a pull request before merging.
- Require status check `standards` to pass.
- Require branches to be up to date.
- `tony-reviews` repos only: require 1 approving review and add a
  `CODEOWNERS` file with `* @TonyBrobston`.
- Do not allow bypassing the above, including for administrators. The agents
  merge with Tony's token, so an admin bypass is an agent bypass.

## What the CI job checks

1. Lint (your `lint-command`): ESLint with the shared rules or ruff.
2. No comments in Python (the ESLint rule covers JS/TS, including TSX).
   The shared ESLint config requires the `typescript-eslint` peer for its TypeScript parser.
3. Tests (your `test-command`).
4. Coverage thresholds (your `coverage-command`, if set).
5. On pull requests: the PR's tests are run against the base branch's source
   and must fail. Source patterns and test paths are relative to `working-directory`;
   sibling projects do not count. Added, modified, renamed, and deleted source
   files are checked, then restored to the PR state. A source change without
   a test change fails. Add
   the `refactor` label to skip this check for behaviour-preserving changes;
   the reviewer confirms the label is honest.

## What CI cannot check

Abbreviated names longer than two characters (`pct`, `prefs`, `thr`),
whether a name says what the thing does, one level of abstraction per
function, and whether a `refactor` label is honest. Those are the reviewer's
job and are the first items on the checklist at the end of the skill.

## Testing this repo

```
npm install
npm test
```

Runs the ESLint rule tests, the Python checker self-test, and git fixtures
for root and nested projects, including deleted implementations.
