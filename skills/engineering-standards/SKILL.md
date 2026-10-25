---
name: engineering-standards
description: Code standards for every Brobston repository. Read before writing, reviewing, or testing code.
---

# Engineering Standards

These rules apply to every repository and every language. CI enforces the
mechanical ones; the reviewer enforces the rest. A PR that breaks a rule is
REQUEST CHANGES, not APPROVE WITH COMMENTS.

## Test first

- Write the failing test before the code that makes it pass. Commit the test
  first (`red`), then the implementation (`green`), then any cleanup
  (`refactor`). The commit history is the proof.
- Every behaviour change ships with a test that fails without it. CI checks
  this by running the PR's tests against the base branch's source and
  expecting failure.
- Name tests as sentences describing behaviour:
  `charging_resumes_when_pedal_drops_below_threshold`, not `test_pedal_2`.
- Test through public behaviour. Do not reach into private state to assert.
- If a behaviour cannot be unit-tested on a laptop, the code is in the wrong
  file. Separate the logic from the hardware, network, or framework adapter.
- Pure refactors that change no behaviour may skip new tests. Label the PR
  `refactor` and say so in the description; the reviewer confirms the claim.

## No comments

Code explains itself. If you want to write a comment explaining what a block
does, extract the block into a function whose name says the same thing.

Allowed, one line each: a fact the code cannot express (a hardware quirk, a
non-obvious external constraint, a link to a spec or issue), and tool
directives (`eslint-disable`, `@ts-expect-error`, `noqa`, `type:`). CI fails
on anything else.

## Names

- Full words. `percent` not `pct`, `threshold` not `thr`, `preferences` not
  `prefs`. Exceptions: acronyms from a real spec or API (CAN, OBD, UUID, BLE,
  HTTP), names a library forces on you, and unit suffixes such as `Ms`.
- A function name says what it does; a variable name says what it holds.
  `isChargingAllowed()`, `remainingHoldMs`, `ordersAwaitingReply`.
- Booleans read as questions: `isConnected`, `hasPendingWrites`.
- No type or scope prefixes: `orders`, not `orderList` or `arrOrders`.
- Keep identifiers under a readable length but never shorter than three
  characters, except loop indices in a one-line range.

## Functions and structure

- Small functions, one level of abstraction each. If a function needs a
  section heading, split it.
- Every `if` / `else` / `for` / `while` body gets braces and its own lines,
  including one-line guards. No ternaries as statements, no comma operator.
- No flags. A boolean that other code keeps in sync is a second copy of a
  truth that already exists; derive the answer from stored values when asked.
  Same for boolean parameters: return the value from a named function instead
  of branching on a flag inside the caller.
- No dead code, no commented-out code, no `TODO`. File an issue instead.
- Fail loudly. Do not swallow errors; do not return a default that hides a
  failure.

## Pull requests

- One concern per PR. Scope creep is REQUEST CHANGES.
- The description opens with the problem in one or two sentences, then links
  the tests that prove the fix.
- CI must be green before review starts. Do not ask a reviewer to read a red
  PR.
- Run the repository's `check` script before opening or updating a PR. Each
  repository's `AGENTS.md` names it.

## Reviewer checklist

Reviewers verify, in this order, and name the rule in each finding:

1. A test exists that fails without the change (read the `red` commit).
2. No comments beyond the allowed kinds.
3. Names say what things do or hold; no abbreviations.
4. No flags, no shorthand control flow, no dead code.
5. One concern, correct, handles edge cases, fails loudly.
