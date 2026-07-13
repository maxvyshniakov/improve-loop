# Cross-family opponent review

Use opponents as read-only critics, never as executors. Record the plan and diff
review outcome per selected lane.

## Choose the model family

- On a **Codex host**, choose **Claude** as the opponent.
- On a **Claude host**, choose **Codex** as the opponent.
- On another host, choose a genuinely different available model family.

When Claude is the opponent, use exact `claude-fable-5` at `high` effort. Do
not lower effort, fall back to Opus or Sonnet, or accept an alias without exact
model evidence. Stop the lane and report the unavailable pin instead of
silently treating another Claude model as equivalent.

Do not silently substitute a same-family reviewer. If the alternative model is
unavailable in a sequential fallback, continue with self-review and repository
gates and report that it was unavailable. If the user explicitly requires an
opponent in a sequential fallback, stop. In a
parallel wave, the pinned critics are part of the accepted scheduler contract:
stop that lane and report the unavailable pin.

## Keep the lane genuinely small

The current host prepares the review packet from evidence it already inspected:
the exact plan or diff, relevant repository facts, done criteria, and available
verification receipt. Start one fresh read-only opponent model process per
artifact. Do not dispatch an auxiliary researcher from the reviewer lane or let
one reviewer silently review several unrelated lanes in a blended context.

Give the opponent direct read-only repository access when the host can enforce
it. For Claude Code, allow `Read`, `Glob`, and `Grep`, plus narrowly permitted
read-only commands in this order: `git diff`, `git show`, `git status`, and
`git log`. Deny `Edit`, `Write`, arbitrary Bash, network, browser, MCP, plugins,
and subagents. Run against the isolated worktree for the active slice. The
evidence packet supplements this inspection; it is not a substitute for reading
the cited code and diff. If read-only shell restrictions cannot be enforced,
omit Bash and include the exact diff in the packet instead.

Before the first Claude critic in a wave, run
`scripts/preflight-claude-opponent.sh` in the target worktree. Accept only a
receipt proving exact Fable 5 `high`, a successful random Read canary, and the
current Git object ID through the allowed `git status` command. Rerun after any
relevant CLI, model, effort, permission, or worktree change. The preflight is a
capability check, not a review, and does not replace the plan or diff critic.

Do not invoke the full `improve-claude` or `improve-codex` pipeline from this
lane. A direct critic adapter may be reused only when it starts exactly the one
chosen opponent and cannot edit the repository. If the available adapter would
silently add another model process, treat that adapter as unavailable for the
bounded loop.

## Decide whether the extra critique earns its cost

Use this risk rubric only for a sequential fallback. Parallel waves already
budget both review surfaces for every selected lane. In sequential work, use an
opponent when repository evidence shows at least one material risk:

- security, auth, permissions, or secrets;
- money, pricing, orders, stock, or another business invariant;
- database migration, backfill, or plausible data loss;
- concurrency, transactions, idempotency, or distributed jobs;
- a public contract, shared API, or package interface with multiple consumers;
- an ownership move across three or more modules or another high blast radius;
- weak proof, or a bug that previously escaped green tests.

Skip it for a mechanical rename or move, a small local refactor protected by
characterization tests, docs or configuration only, and style-only changes.
When uncertain, judge expected defect-finding value against latency and cost;
do not call an opponent merely because one is available.

## Place reviews where they have leverage

- Choose **plan critique** when semantic ambiguity, business meaning, migration
  strategy, or seam ownership is the main risk.
- Choose **diff review** when the plan is clear but implementation details,
  failure paths, or incomplete proof are the main risk.

In a sequential fallback, make at most one opponent call by default: plan
critique **or** diff review, chosen by the risk. In a parallel wave, give every
lane one plan critique before dispatch and one diff review after implementation.
This includes a one-lane dependency wave inside an otherwise parallel program:
it still gets both the plan critique and diff review. Sequential fallback means
an ordinary non-wave one-slice run, not a temporarily serialized wave.
Use a fresh reviewer context for each artifact and keep at most two heavy
reviewer processes concurrent. Allow at most one reviewer-driven revision round
per artifact by default. Return out-of-scope findings to the candidate queue
instead of expanding the active lane.
