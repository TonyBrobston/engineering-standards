---
name: writing-for-tony
description: How to write every comment, plan, PR description, and brief. Read before posting anything Tony will read.
---

# Writing For Tony

Tony reads every doc, plan, comment, and issue you write. He is technical,
busy, and already knows the project. Write for one fast read, and aim for
about a quarter of what agents have been producing. He asked for this
directly.

## Lead with the problem

- Open with the problem in one or two sentences: what is broken or missing,
  who it affects, and what is different once it is fixed. Status, approach,
  and detail come after.
- State the problem, not your process. "Guests can't check out" is a problem.
  "I investigated the checkout flow" is activity.
- If you can't name the problem in a sentence, you don't understand the task
  yet. Say that and ask.
- This applies to every outward artifact: task comments, plan and spec
  documents, approval requests, PR descriptions, and briefs to other agents.

## Say it once, say it short

- Lead with the answer or decision. No preamble, no "this document is…".
- Say each fact once. Never restate a point in a summary, a "why," or a
  closing section.
- No justifying, hedging, or defending. State the decision; give a reason
  only if it isn't obvious, in one sentence.
- Say what you did, not how. No method narration, no audit trail, no "I
  re-derived this from scratch", no listing what you chose not to delegate.
- Final comment on a task: 150 words max. One sentence on what shipped or
  what is needed, then at most three bullets. No headings. The task comment
  is a receipt, not a report; detail lives in the PR or the plan document.
- No tables unless the table is the deliverable. Link the PR instead of
  describing the diff.
- A plan fits on one screen (~300 words). If it can't, split it into
  separate issues. Plan documents open with a summary short enough to
  approve from; everything else is appendix below it.
- Approval requests get the proposal and the decision needed, nothing else.
- One question at a time, in one "Confirm" list at the end, one line each.
  Do not pre-answer follow-ups he has not asked.
- Before posting, delete every sentence Tony wouldn't miss.

Bad: "A BOM keyed on an empty string matches every product and no product at
once. Worse, the failure is silent in the direction that costs money: a sale
finds no BOM, consumes nothing, and the ledger looks healthy."

Good: "No products have SKUs, so a SKU-keyed BOM would silently consume
nothing. Proposal: key on product ID or variant SKU."

Every task you hand to another agent carries this standard in its brief.
