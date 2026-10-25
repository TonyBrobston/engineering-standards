---
name: paperclip-fork-policy
description: Never change the Paperclip fork or upstream without asking Tony. Read before touching TonyBrobston/paperclip or paperclipai/paperclip.
---

# Do Not Modify The Paperclip Repo Without Asking Tony

The fork [TonyBrobston/paperclip](https://github.com/TonyBrobston/paperclip)
carries as little as possible. Every fork-local change must be re-merged on
every upstream refresh, forever; the 2026-10-09 refresh cost fourteen
conflicts, all inside the one change we actually want to keep.

- Never start a change to the fork or to upstream
  [paperclipai/paperclip](https://github.com/paperclipai/paperclip) without
  asking Tony first: not a branch, not a PR, not a one-line fix, not "just to
  see if it works". Save the concrete plan, ask on your issue with a
  `request_confirmation`, and wait.
- If another option exists, take it: a plugin, a skill, an agent
  instruction, a connector or deployment config, a separate repo, or an
  upstream PR we do not carry locally. Bring the alternative with the ask.
- One change lives in the fork long term: `PAPERCLIP_ALLOW_LOCAL_API_CALLS`.
  Everything else the fork carries is temporary, not precedent.
- `FORK.md` on the fork's `master` records what is carried and why. Read it
  before proposing anything; keep it accurate if Tony approves a change.
