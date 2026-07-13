# Minimal persistent loop state

Use durable state only when the improvement run must continue across user
tasks. Resolve the plan root from repository instructions or its existing plan
layout. If the repository defines neither, default to `docs/plans`. New runs
keep one file:

```text
<plan-root>/<program-slug>/LOOP.md
```

Use this shape:

```markdown
# <Program name>

Direction: <observable product or architecture outcome>
Mode: guided | auto
Bound: <maximum slices, time, or explicit finish line>
State: ACTIVE | PAUSED | COMPLETED
Stage: improve-loop/<program-slug>
Target: stage | dev | <explicit local branch>
Current wave: none | <wave number and frozen base>
Contract revision: <repo commit or skill blob SHA pinned for the current wave>
Resume point: none | <one concrete next action>

## Active lanes

- <NNN slug> — PLAN | CRITIQUE | EXECUTE | DIFF REVIEW | ACCEPT | INTEGRATE

## Candidate queue

- READY — <candidate, evidence, expected payoff>
- WAITING DECISION — <candidate and exact question>

## Results

- <slice> — LANDED | REJECTED — <commit or reason> — <proof>
```

Keep up to three active executor lanes and one integration lane. Create detailed
numbered plans only for the selected wave, next to `LOOP.md`. Do not pre-write
the remaining queue as plans. The host alone updates this file.

Pin `Contract revision` when a wave starts. If the user changes the skill or
review policy mid-run, new lanes use the new revision. A running lane may retain
the old revision only when the change cannot affect its model, permissions,
safety, acceptance, or proof; otherwise stop and relaunch or re-review it.

After an integrated lane, update only:

- its `LANDED` or `REJECTED` result;
- the candidate ordering changed by its evidence;
- `Current wave`, `Active lanes`, and `Resume point`;
- `State` when the bound is exhausted or the program stops.

Do not require separate learning, usage, retrospective, model-lineage,
acceptance-receipt, or capacity-ledger files. Record a durable ADR, canon rule,
or domain term only when the implementation actually establishes one.

Do not retain compatibility validators, capacity ledgers, usage summaries, or
multi-file state for an old program. When the user resumes an old outcome,
reconcile the live repository and create `LOOP.md` only if durable continuation
is still useful. Keep rejected historical evidence on its retained branch or in
`docs/archive/`, never as an active backlog under `docs/plans/`.
