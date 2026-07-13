# Parallel planning and execution

Use a wave only when independent work can finish faster than the added review
and integration cost. Keep all user-facing coordination in the host task.

## Fixed roles

- **Host orchestrator:** owns candidate selection, plan reconciliation, program
  state, acceptance, commits, integration, and final gates.
- **Plan author:** runs read-only against the frozen stage base. Use the same
  model and effort as the host when that spawn target is available. The host
  persists the plan; the author never edits `docs/plans` or source.
- **Executor:** always use `gpt-5.6-sol` through Codex CLI at `medium` effort,
  independent of the host model and family. Never inherit the host model,
  effort, or user default as an executor pin. Upgrade the table in `SKILL.md`
  deliberately when the executor pin changes.
- **Opponent:** follow `opponent-review.md`. On a Codex host, use a fresh Claude
  Fable 5 `high` critic for the plan and another fresh Fable 5 `high` critic for
  the diff.

Do not use built-in subagents for writer lanes unless the platform can pin the
required model and effort and provide a genuinely isolated worktree. Shared-cwd
subagents are not executor isolation. Use a guarded Codex CLI adapter that can
bind the executor to its linked worktree, pin model and effort, prevent writes
to the main checkout and Git integration, disable unrelated tools, and retain
the exact diff and proof for host review. An installed `improve-codex` runner
may provide this seam, but do not inherit its end-to-end ownership rules. If no
available adapter satisfies this contract, stop the affected lane and report
the missing capability. Explicitly launch every writer with
`CODEX_MODEL=gpt-5.6-sol` and `CODEX_EFFORT=medium`; these overrides replace any
adapter defaults, and the improve-loop scheduler owns wave concurrency.

## Form a safe wave

1. Freeze one stage base commit for the wave.
2. Build a preliminary file/owner/resource matrix covering dependency edges, production
   owners, likely files, schema/migrations, package entrypoints, generated files,
   test databases, ports, browser use, release notes, and shared gates.
3. Use two writer lanes as the default when the matrix is disjoint. Admit a
   third lane only after proven disjoint ownership and resources. Never exceed
   three active executors.
4. Keep one schema/migration writer per wave. Also serialize work that shares a
   package public contract, generated index, browser stack, or real database.
5. Keep `LOOP.md`, numbered plan status, and integration commits host-owned.

If the candidates share a production owner or a proof environment, reduce the
wave to one lane. Parallelism is an optimization, not a completion criterion.

## Prepare lanes

- Create one branch and isolated linked worktree per executor from the frozen
  base. Never dispatch two executors into one worktree.
- Serialize dependency install commands and other shared-cache preparation
  across worktrees.
- Give database-dependent lanes separate disposable test databases/runtimes.
- Run a browser proof stack in one lane at a time with unique ports.
- Inline the accepted plan into the executor prompt. Forbid edits to program
  state and unrelated candidate files.

## Plan, critique, execute

1. Run `scripts/preflight-claude-opponent.sh` before the first plan critic in
   each wave. Rerun it before a diff critic if the Claude CLI, model, effort,
   permissions, or target worktree changed. Stop the affected lane unless the
   receipt proves exact Fable 5 `high`, repository Read, and read-only Git.
2. Launch eligible read-only plan authors in parallel.
3. As each plan arrives, reconcile it against live code and sibling plans,
   persist only the host-approved version, and finalize the matrix from its
   exact accepted scope.
4. Send the plan to its fresh cross-family critic. Revise once when confirmed
   findings change scope, proof, or failure handling.
5. Dispatch the accepted plan to its Codex-medium worktree executor. The
   executor owns TDD and focused iterative proof but cannot commit or integrate.
6. Monitor lanes independently. A blocked lane does not stop unrelated lanes.
7. On completion, send the exact uncommitted diff and proof to a fresh diff
   critic, adjudicate findings, and allow a bounded executor revision. Do not run
   `commit-worktree.sh` before this review; the host must commit only after final
   acceptance.
8. Read the complete final diff and rerun the acceptance proof as host.

## Accept and integrate serially

Only the orchestrator may commit accepted executor work. Integrate one lane at a
time into the stage branch. Before accepting any later lane, rebase it onto the
current stage, inspect the resulting diff, and rerun every affected focused
proof. If the rebase changes semantics or materially changes the diff, repeat
the diff review.

Run migration proof, browser verification, shared package gates, and the final
repository gate serially on the integrated stage. Start the next wave only when
every current lane is landed, rejected, or explicitly blocked.
