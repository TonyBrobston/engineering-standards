# Plan: one set of engineering standards, enforced by CI, so agents can ship to Done without Tony

**Owner:** Middle Manager Mike. Delegate each task to whoever fits; take a task yourself only when you hold a permission the others lack. Where even you lack it, do the prep and raise one `request_confirmation` to Tony with the exact change.

## Problem

Agents on two providers get different instructions, the instructions have drifted (they route code to reviewers who do not exist), and nothing in any repository checks the standards Tony wrote in `load-shed/CLAUDE.md`. So Tony has to read every PR, which caps how much work can finish without him.

## Done

1. Every engineering agent reads the same standards from one GitHub-tracked skill.
2. On `agents-merge` repositories, a PR cannot merge unless CI proves: no comments, names and structure pass lint, tests pass, coverage holds, and the PR's tests fail without its source change.
3. `paperclip-plugin-inventory` has run two weeks of normal work under those gates with zero Tony interventions on code style or missing tests.
4. Tony's Review queue holds only the decisions listed under Confirm below.

## Source material

Attached: `engineering-standards.tar.gz`. It is the complete `TonyBrobston/engineering-standards` repository: the standard as a skill, shared ESLint/vitest/ruff config, a reusable CI workflow, per-repo pointer templates, four Paperclip skills, eleven slim agent instruction files, and `paperclip/CHANGES.md` with the exact config edits. `npm install && npm test` passes. Do not rewrite it; apply it.

## Rules for this plan

- No changes to `TonyBrobston/paperclip` or upstream. Everything here is a skill, a separate repo, or a repo-level file.
- Every task ends with evidence: a link to the merged PR, the exported file, or the CI run. A comment saying it is done is not evidence.
- Writing follows the `writing-for-tony` skill from the moment it is imported.

## Phase 0 — Repository exists (Team A, Sue)

| # | Task | Acceptance |
| --- | --- | --- |
| 0.1 | Create `TonyBrobston/engineering-standards` from the tarball; push `main`. If repo creation needs Tony, prepare the tarball-extracted tree in a workspace and ask once. | Repo public, `npm test` green in its own Actions run |
| 0.2 | Tag `v1.0.0`. | Tag exists |

## Phase 1 — Paperclip reads from the repo (Mike, permissions permitting)

Follow `paperclip/CHANGES.md` exactly.

| # | Task | Acceptance |
| --- | --- | --- |
| 1.1 | Import four skills from GitHub, tracking `main`: `skills/engineering-standards`, `paperclip/skills/delivery-workflow`, `paperclip/skills/writing-for-tony`, `paperclip/skills/paperclip-fork-policy`. | Four skills listed with GitHub source |
| 1.2 | Attach per the table in CHANGES.md step 1. | Each agent's skill list matches the table |
| 1.3 | Replace each agent's instructions with `paperclip/agents/<slug>/AGENTS.md`. Keep Rick's `SECURITY.md`. | Company export: no agent file exceeds 20 lines; no mention of Reed or Quinn anywhere |
| 1.4 | Config: Terry heartbeat off; Mike heartbeat off unless a routine needs it; Paul reasoning `medium`; Barb `canCreateAgents` off; Sue and Terry `canCreateAgents` off. | Export shows the values |
| 1.5 | Projects: one-line purpose for Inventory Plugin and Onboarding; `merge_policy` line on each project. | Export shows the lines |
| 1.6 | Re-export the company and attach the zip to this issue. | Zip attached; 1.3–1.5 verifiable from it |

## Phase 2 — Pilot: `paperclip-plugin-inventory` (Team A: Paul leads, Sue builds, Carl reviews, Betty QA)

| # | Task | Acceptance |
| --- | --- | --- |
| 2.1 | Add `AGENTS.md`, `CLAUDE.md`, `.github/workflows/ci.yml`, `eslint.config.mjs`, `vitest.config.ts` from `templates/`; merge the `package.json` snippet; `merge_policy: agents-merge`. Keep the existing database-test and `dist/` checks. | PR merged; `standards` job present in Actions |
| 2.2 | Cleanup PR labelled `refactor`: remove comments, fix names and braces until `npm run check` is green. No behaviour change. | CI green; Carl confirms the label is honest |
| 2.3 | Branch protection on `main`: require PR, require `standards` check, no admin bypass. Needs repo admin; if Mike's token lacks it, prepare the exact settings and ask Tony once. | Screenshot or API output of the rules |
| 2.4 | Prove the gate: open two throwaway PRs — one adds a comment, one changes `src/` with no test. Both must be rejected by CI, not by a reviewer. Close them. | Links to both failed runs |
| 2.5 | Two weeks of normal inventory work under the gates. Paul merges when CI, Carl, and Betty all say yes. Tony tests the deployed plugin and files bugs as new issues. | Mike's report in 3.1 |

## Phase 3 — Evaluate (Mike)

| # | Task | Acceptance |
| --- | --- | --- |
| 3.1 | Report, 150 words max: PRs merged, PRs CI rejected, PRs reviewer rejected, Tony interventions and what each was, time from task created to Done. Recommend go or fix. | Posted on this issue |

## Phase 4 — Roll out (after Tony's go)

One task per repository, alternating teams so both providers exercise the gates. Same steps as 2.1–2.4.

| Repository | Policy | Notes |
| --- | --- | --- |
| brobston-creations-inventory-config | agents-merge | already authorized, BRO-196 |
| paperclip-plugin-bigcommerce | agents-merge | keep the contract-sync job |
| paperclip-plugin-home-assistant | agents-merge | has no CI today; add `ci.yml` from template |
| tbro-server | agents-merge | shell scripts only; `test-command` is the existing `test-*.sh` scripts; skip eslint |
| tbro-home-assistant | agents-merge | YAML config; `test-command` is the existing config check; skip eslint |
| ha-codex-usage | agents-merge | Python template; already has ruff + pytest |
| load-shed | tony-reviews | web is jest at 95% already; firmware is Python template; add CODEOWNERS |
| chrome-extension | tony-reviews | jest; add CODEOWNERS |
| brobston-creations-website | tony-reviews | use `eslint.config.next.mjs`; add CODEOWNERS |
| documentation | tony-reviews | no code; `AGENTS.md` and `CLAUDE.md` only |
| paperclip fork | never | `paperclip-fork-policy` applies |

## Confirm (Tony)

1. Policy column above, especially `tbro-server` and `tbro-home-assistant` as `agents-merge`.
2. Who sets branch protection: Mike with the shared token, or Tony by hand.
3. Pin repos to `engineering-standards@main` (updates flow immediately) or to a tag (updates are a PR per repo).

## How future projects reach Done

Tony and Claude work a project out in chat; Claude writes a plan in this shape. Mike runs it. Every plan carries: the problem, a Done definition that names working software and where it is deployed, the repository and its `merge_policy`, the team, acceptance evidence per task, and a Confirm list of at most a few decisions. On `agents-merge` projects the plan goes to Done without Tony; he uses the software and files feedback as new tasks. On `tony-reviews` projects the only difference is that merges wait in his Review queue.
