---
name: delivery-workflow
description: How code moves from task to Done — teams, review and QA sequence, pull request rules, merge policy per repository, and task statuses. Read before starting, handing off, or closing any engineering task.
---

# Delivery Workflow

## Teams

| Team | Lead | Engineer | Reviewer (opposite provider) | QA |
| --- | --- | --- | --- | --- |
| A | Project Pusher Paul | Script Kitty Sue (Claude) | Code Cop Carl (Codex) | Bug Hunter Betty |
| B | Mission Manager Molly | Terry the Tech Guy (Codex) | Review Ranger Rick (Claude) | Test Case Tracy |

Both leads report delivery and real blockers to Middle Manager Mike. Routine
revisions do not go to Tony.

## Sequence

engineer → reviewer → QA → lead → Mike.

- The engineer opens the PR, records it as a `pull_request` work product on
  the issue the moment it is opened, and waits for CI to be green before
  requesting review.
- The reviewer reads the actual diff at the linked PR URL and exact commit
  SHA and records APPROVE, APPROVE WITH COMMENTS, or REQUEST CHANGES, naming
  the `engineering-standards` rule behind each finding. Never approve unread
  changes.
- APPROVE and APPROVE WITH COMMENTS allow QA; the lead assigns non-blocking
  follow-up without involving Tony. REQUEST CHANGES returns to the engineer.
- QA starts only after recorded reviewer approval at the tested SHA, and
  publishes an evidence-backed PASS or FAIL with tested scope. FAIL returns
  to the engineer through the lead.
- Changed code repeats review and QA at the new SHA. A recorded verdict
  stays valid for its unchanged SHA.
- Review and QA are ordinary assigned child tasks with the PR URL and SHA in
  the brief; block QA on its review with `blockedByIssueIds`. Never make a
  reviewer their own issue's review-stage participant.

## Merge policy

Each repository's `AGENTS.md` names its policy. If it names none, the policy
is `tony-reviews`.

- `agents-merge`: the lead merges when CI is green and the reviewer and QA
  have both recorded approval at the tested SHA. Tony tests after merge and
  files bugs as new issues.
- `tony-reviews`: after reviewer and QA approval, the lead saves a
  `request_confirmation` naming the PR and enters In Review. Tony merges.

An assignment, verdict, status, or silence never grants merge, production,
spending, or repository permissions beyond the repository's stated policy.

## Pull requests

- Every mention of a PR, branch, commit, preview, or issue carries its link
  inline: `[org/repo#123](https://github.com/org/repo/pull/123)`, never a
  bare `#123` or "the PR".
- The PR description opens with the problem and links the tests that prove
  the fix.
- Never set a delivery issue to `done` while its PR is open or scoped
  deployment or verification is pending. A bounded review or QA child task
  may complete after its verdict; that does not close delivery.

## Statuses

- **In Progress**: implementation, review, QA, and lead coordination. An
  assigned task, dependency wake, or scheduled continuation must always carry
  the next action. Do not let work sit; always leave a comment.
- **In Review**: exclusively a specific operator decision for Tony, with a
  saved human-only interaction naming the decision, recommendation,
  consequences, and next action. Never ask Tony merely to acknowledge an
  agent verdict.
- **Blocked**: only with a first-class blocker or a named unblock owner and
  action. An agent may set an `unblockDescriptor` only for itself.
- **Done**: scoped delivery, required approvals, merge, deployment, and
  verification are complete.

## Execution

- Start actionable work in the same heartbeat. Do not stop at a plan unless
  the issue asks for one.
- Create child issues directly when you know what needs doing. Use child
  issues for parallel or long delegated work instead of polling.
- For board input, create an issue-thread interaction (`suggest_tasks`,
  `ask_user_questions`, or `request_confirmation`) rather than asking in
  markdown. Before presenting a plan for confirmation: `PUT` the plan
  document, re-`GET` it to capture `latestRevisionId`, then create the
  `request_confirmation` bound to that revision, and wait for acceptance
  before creating implementation subtasks.
- When the deliverable is a file, upload it as an artifact work product and
  link it in the final comment; never rely on a workspace path alone.
- Record `pull_request`, `preview_url`, `runtime_service`, `commit`, and
  `branch` work products as they are produced.
- Respect budget, pause and cancel, approval gates, and company boundaries.
- At provider capacity limits, checkpoint through the `ai-capacity-handoff`
  skill. Never use a metered API key, create credentials, or switch provider
  automatically.
