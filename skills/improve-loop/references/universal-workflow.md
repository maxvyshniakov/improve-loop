# Bounded improvement cycle

## Modes

- **Bare invocation** (no arguments) always enters Scout.
- **Scout** discovers candidates and stops.
- **Guided** asks before each execution wave.
- **Auto** executes within a stated bound and may promote reviewed work to
  local `dev`; it never implies push or deploy.

## Cycle

Run the whole program in one user-facing task:

```text
scout -> select -> parallel plan -> critique -> isolated execute -> review
                                                               -> serial integrate
                                                               -> land | reject | stop
```

1. Reconcile the current branch, worktrees, relevant plans, and prior evidence.
2. In Scout, rank 5–10 positive-value candidates before presenting them. Stop before
   writing a plan or starting implementation, and ask which numbered candidates
   the user wants in the loop.
3. **Select** the next dependency-safe wave from the user's answer using a
   preliminary overlap matrix before any plan author is launched.
4. Freeze the base and launch parallel read-only plan authors only for that wave.
5. Critique and reconcile each plan, then finalize the file/owner/resource matrix
   after critique against the exact accepted scopes.
6. **Implement** independent plans in isolated worktrees using domain skills and TDD.
7. **Review** each finished lane against its plan and exact diff. Out-of-scope
   findings return to the candidate queue.
8. Rebase accepted later lanes onto the current stage, repeat affected proof,
   and integrate them serially through the host-owned integration lane.
9. **Land** or **reject** each lane, then re-rank, continue inside the bound, or **stop**.

## User interaction

On a bare invocation show only the ranked candidate map and the selection
question; do not pretend that a bound or candidate was already chosen. Before
a guided wave show its payoff, scopes, exclusions, overlap matrix, and proof.
During implementation send normal progress updates. After every integrated lane
show one compact receipt in this shape:

```text
5/8 LANDED | <slice> | commit <sha> | proof <checks> | integrated <target> | next <work>
```

Count both `LANDED` and `REJECTED` toward the selected bound. Never make the
user ask whether the selected plans are finished.

When the program completes, pauses, or stops, end with a short final summary of
the whole run, not only the last wave:

- **Product:** all landed source outcomes, grouped compactly;
- **Workflow:** workflow or skill changes kept separate from product work;
- **Verification:** focused tests, gates, critic verdicts, and browser proof;
- **Integration:** final branch/target and whether push or deploy happened;
- **Remaining:** rejected, blocked, or intentionally unselected work, or `none`.

Ask one recommended question only when code, canon, ADRs, and tests cannot
resolve a material product decision. Do not require grilling unless explicitly
requested.

## Review budget

Self-review and repository gates are mandatory. A sequential fallback uses the
risk-based opponent budget in `opponent-review.md`; a parallel wave gets one
plan critique and one diff review per lane. A reviewer may veto a plan or diff
but may not enlarge its scope. Findings unrelated to the declared result become
future candidates.

## Integration

Plain improve-loop uses a dedicated stage branch. Executor branches never
integrate themselves: the host commits accepted work and serially integrates it
into the stage. Explicit `auto` permits local `dev` promotion after green proof
and a clean-target check. Push and deploy always require separate authorization.

## Stop conditions

Stop when the user bound is exhausted, no candidate has positive value, a real
product decision is missing, the target is unsafe to integrate, or the current
hypothesis cannot be proven without scope expansion. Preserve a short resume
point when continuation would still be valuable.
