# Paperclip changes

Apply in this order. Steps 1–3 are in the UI; step 4 is a paste per agent.

## 1. Import the four skills from this repo

Skills → Add from GitHub, one per directory, tracking `main`:

| Skill | Path in this repo | Attach to |
| --- | --- | --- |
| engineering-standards | `skills/engineering-standards` | Mike, Paul, Molly, Sue, Terry, Carl, Rick, Betty, Tracy |
| delivery-workflow | `paperclip/skills/delivery-workflow` | everyone |
| writing-for-tony | `paperclip/skills/writing-for-tony` | everyone |
| paperclip-fork-policy | `paperclip/skills/paperclip-fork-policy` | everyone |

Keep `ai-capacity-handoff`, `push-notification`, `grill-me`, and
`agent-browser` as they are.

## 2. Fix adapter and runtime config

| Agent | Change | Why |
| --- | --- | --- |
| Terry the Tech Guy | heartbeat `enabled: false`, `intervalSec: 0` | wakes every 5 minutes unprompted |
| Middle Manager Mike | heartbeat `enabled: false` unless a routine needs it | same |
| Project Pusher Paul | `modelReasoningEffort: medium` (was `low`) | the lead decomposes work; QA gets more reasoning than him today |
| Backoffice Barb | `canCreateAgents: false` | ops coordinator should not hire |
| Script Kitty Sue, Terry | keep `canCreateSkills`, drop `canCreateAgents` | engineers do not hire |

`dangerouslyBypassApprovalsAndSandbox: true` on the Codex agents is acceptable
only because branch protection becomes the guardrail (see `../README.md`,
"Branch protection").

## 3. Fix each project

- `PROJECT.md` for Inventory Plugin and Onboarding are empty. Give each one
  line of purpose.
- Add a `merge_policy` line to each project description so the lead does not
  have to search issues for standing authorizations:
  - Inventory Plugin: `agents-merge` (BRO-196 already grants this for
    `paperclip-plugin-inventory` and `brobston-creations-inventory-config`)
  - Delivery Hygiene: per repository; `tbro-server` and `tbro-home-assistant`
    have been `agents-merge` by issue (BRO-69, BRO-108, BRO-262); `paperclip`,
    `load-shed`, `chrome-extension`, `documentation` stay `tony-reviews`.
- Each repository's `AGENTS.md` carries the same line; the repository wins
  if they disagree.

## 4. Replace each agent's instructions

Paste `paperclip/agents/<slug>/AGENTS.md` over the agent's current
instructions. Each is 10–15 lines; everything shared now comes from skills.

What this removes, and why:

| Removed | Reason |
| --- | --- |
| "Code Review Before QA" (Mike, Terry, Barb, Casey) | routes to Reviewer Reed and QA Quinn, who do not exist |
| "Shared Review, QA, and Operator Workflow" and "Two-team delivery workflow" | merged into `delivery-workflow`, with the team table corrected: Terry is Codex and reports to Molly, Sue is Claude and reports to Paul, matching the org chart |
| Tracy "return failures through Molly to Sue" | Molly leads Terry |
| Paul "coordinate Terry, Carl, Betty" and Molly "coordinate Sue, Rick, Tracy" | swapped engineers; corrected |
| Writing Style, Lead With The Problem, Write Less | merged into `writing-for-tony` with duplicates removed |
| Execution Contract, Pull Requests And The Done Gate | merged into `delivery-workflow` |
| Do Not Modify The Paperclip Repo | moved to `paperclip-fork-policy`, unchanged |

Rick's `SECURITY.md` stays as it is.

## 5. Routines

No changes. `daily-ready-for-you` and `gmail-triage` are the only scheduled
work; the merge-upstream routine is webhook-only.
