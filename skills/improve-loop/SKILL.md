---
name: improve-loop
description: Run a bounded improvement program with parallel read-only planning, isolated Codex executor waves, independent opponent review, and serial host integration. Use when the user explicitly invokes improve-loop, asks to autonomously implement selected codebase improvements, or wants plans executed without manually opening separate sessions. Keep canonical improve and improve-codebase-architecture available as independent scout skills.
---

# Improve Loop

Turn a selected improvement direction into a short sequence of landed or
rejected vertical slices. Keep the user in one task; do not make them dispatch
plans to separate sessions.

## Start Here

Treat these canonical managed skills as independent dependencies:

- The managed skill `improve` owns broad audits and handoff plans;
- The managed skill `improve-codebase-architecture` owns architecture
  candidate discovery and its optional interactive design flow.

Resolve each dependency through the active skill catalog. Do not assume a
repository-specific skill directory or installation path. If a required scout
is unavailable, report that dependency instead of copying or silently
installing another implementation.

Direct invocation of either dependency keeps its upstream behavior. Do not
copy, adapt, or edit those vendor skills from this skill.

Load a dependency only for the scout work it owns. Do not inherit its entire
interactive workflow: in particular, do not require grilling in improve-loop.
Grill only when the user explicitly asks for it.

Read [references/universal-workflow.md](references/universal-workflow.md) for
the cycle, [references/selection.md](references/selection.md) for candidate
ranking, [references/parallel-execution.md](references/parallel-execution.md)
for planning/executor waves, [references/opponent-review.md](references/opponent-review.md)
for the cross-family critics, and
[references/program-contract.md](references/program-contract.md) only when
durable cross-session state is useful.

## Model assignment

| Agent type | Claude host | Codex host |
|---|---|---|
| Plan author | Exact host Claude model + host effort | Exact host Codex model + host effort |
| Executor | `gpt-5.6-sol`, `medium` | `gpt-5.6-sol`, `medium` |
| Plan critic | `gpt-5.6-sol`, `xhigh`, read-only | `claude-fable-5`, `high`, read-only |
| Diff critic | `gpt-5.6-sol`, `xhigh`, read-only | `claude-fable-5`, `high`, read-only |
| Integration judge | Host Claude model | Host Codex model |

Pin every spawned model and effort explicitly. Do not silently substitute a
different model or inherit user defaults. If the exact planner host model is not
spawnable, let the host write that plan directly. If an executor or critic pin
is unavailable, stop that lane and report it.

Before the first Claude critic in a wave, resolve this skill's installed
directory and run its bundled preflight:

```bash
<improve-loop-dir>/scripts/preflight-claude-opponent.sh <worktree>
```

Accept only its exact `READY model=claude-fable-5 effort=high read=ok git=ok`
receipt. Rerun it after a Claude CLI, model, effort, permission, or worktree
change. Launch the plan and diff critics with the same model, effort, and
read-only tool policy proven by the preflight; stop the lane on any mismatch.

## Workflow

### 1. Choose the mode and bound

- **Without arguments, always choose Scout.** Inspect the live repository,
  relevant docs, and current plans; independently rank 5–10 candidates; show
  the compact candidate map below; then stop for selection. Do not write plans
  or implement anything before the user chooses candidates.
- **Scout**: show a candidate map and stop. Use canonical `improve` for broad
  discovery or canonical `improve-codebase-architecture` for architecture.
- **Guided**: ask for approval before each selected slice.
- **Auto**: continue without per-slice approval inside the user's stated bound.
  If no bound is stated, default to at most three completed or rejected slices.
  When Auto explicitly selects N candidates and says to run them all, treat that
  selection as bound N unless the user stated a smaller numeric or time bound.

Only explicit `auto` authorizes fast-forwarding reviewed work into local
`dev`, but Auto does not itself select `dev` as the target. Record `Target: dev`
only when the invocation or user explicitly chooses that local integration;
otherwise retain the dedicated stage branch. Neither mode authorizes push or
deploy. An explicitly named local branch is also a valid target, but it uses the
same green-proof and clean-target checks as `dev`.

### 2. Present candidates, not a frozen backlog

Rank the strongest evidence-backed candidates before presenting them. Show
5–10 when that many have positive value; never invent filler to reach the
minimum. Keep scoring internal unless the user asks for it. Use this exact
compact shape, with keycap number emojis through `🔟`:

```markdown
1️⃣ **<Название>**
**– Why:** <короткая evidence-backed причина>
**– If done:** <конкретный payoff>

---

2️⃣ **<Название>**
**– Why:** <короткая evidence-backed причина>
**– If done:** <конкретный payoff>
```

Put a horizontal divider (`---`) on its own line between every candidate so
adjacent proposals cannot visually merge. Do not put a divider before the
first candidate or after the last one.

End the map with: `Какие номера брать в работу в loop?`

Accept numbers and ranges. After selection, enter Guided mode unless the user
explicitly requested Auto. Do not write full plans for the whole backlog. Write
just-in-time plans only for the next dependency-safe wave. Scout itself never
calls an opponent.

### 3. Plan and run a wave

Maintain one serial integration lane and up to three active executor lanes.
Use two writer lanes by default when two candidates are genuinely independent;
use a third only after the overlap check proves it safe. Fall back to one lane
when dependencies or shared owners make parallel work false economy.

For each wave:

1. Reconcile current code and prior evidence, then freeze the stage base.
2. Build a preliminary dependency and likely file/owner/resource overlap matrix
   before plan dispatch.
3. Dispatch read-only plan authors for eligible candidates; the host persists
   and reconciles their output rather than letting planners edit program state.
4. Send each plan through an independent cross-family critique, revise it, and
   finalize the overlap matrix from the exact accepted scopes.
5. Dispatch each approved plan to its own isolated worktree using the fixed
   Codex-medium executor contract in `parallel-execution.md`.
6. As a lane finishes, run focused proof, independent diff review, and the
   host's complete-diff acceptance pass.
7. Let only the host commit accepted work and integrate it into the stage lane
   serially. Rebase later lanes onto the current stage and repeat affected proof
   before acceptance.

Reviewer findings outside the selected scope go to the candidate queue; they
do not expand the current lane. Normal RED/GREEN iterations do not count as
reviewer revisions.

### 4. Land, reject, or stop

- **Land** after the done criteria and relevant gate pass. Integrate only
  according to the selected stage/local-dev policy.
- **Reject** when the hypothesis is false, safe proof is unavailable, or the
  required fix exceeds the slice boundary. Preserve the reason and continue
  only if another positive-value candidate remains inside the budget.
- **Stop** for a real product decision, unsafe integration state, exhausted
  user bound, or no positive-value candidate.

After each integrated lane, report the actual source result and proof briefly.
Use the progress receipt from `universal-workflow.md` so the user always sees
completed count, bound, result, commit, proof, integration state, and next work.
After the wave, re-rank from implementation evidence before selecting again.
When the program stops or completes, finish with the short whole-run summary
defined there.

### 5. Persist only useful state

Use the program contract when the work must resume across tasks. Record the
candidate queue, current slice, result, resume point, and the contract revision
for the current wave. Do not require model lineage, token ledgers, hand-built
acceptance receipts, continuity sessions, or multi-review ceremony.

## Guardrails

- Keep `improve-loop`, its gates, and agent workflow stable during a run by
  default. If the user explicitly asks to change `improve-loop` or its reviewer
  policy mid-run, treat that request as authorization for immediate workflow
  maintenance: record the product-slice resume point, make the narrow change in
  a separate meta commit, run the workflow gates, and resume. Never cite this
  stability default as a reason to defer or refuse the explicit request.
- Pin every active wave to its recorded contract revision. New lanes use the
  updated revision immediately. Running lanes may finish on their pinned
  revision only when the change cannot affect their model, permissions, safety,
  acceptance, or proof; otherwise stop and relaunch or re-review them.
- Do not require grilling. Do not manufacture parallelism when dependency,
  ownership, migration, browser, or shared-runtime evidence says to serialize.
- Do not turn a reviewer suggestion into automatic scope expansion.
- Do not start the next executor wave before every lane in the current wave is
  landed, rejected, or explicitly blocked.
- Do not push, deploy, or publish without explicit authorization.
- Preserve unrelated work and never use destructive Git cleanup.

## Verification

When changing this skill or its scheduler contract:

1. Run the active `skill-creator` validator against the resolved
   `<improve-loop-dir>`; never hardcode a user home or installation path.
2. Run `bash -n <improve-loop-dir>/scripts/preflight-claude-opponent.sh` and
   the target repository's focused workflow tests.
3. Run the target repository's agent-workflow or edit gate when its
   instructions define one. Repository-specific gates remain repository
   policy, not part of this portable skill.
