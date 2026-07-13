# improve-loop

An agent skill for running a bounded codebase-improvement program in one
user-facing task.

```text
scout -> select -> parallel plan -> critique -> isolated execute -> review
                                                               -> serial integrate
                                                               -> land | reject | stop
```

Unlike a fixed audit backlog, `improve-loop` plans only the next dependency-safe
wave, integrates accepted slices serially, and re-ranks the remaining candidates
from new implementation evidence.

## What it provides

- Scout, Guided, and bounded Auto modes
- evidence-backed candidate selection
- read-only plan authors and cross-family critics
- isolated Codex executor worktrees
- file, owner, dependency, and shared-resource overlap checks
- host-owned commits and serial stage integration
- optional minimal state for cross-session resume

The skill never implies push, deploy, or publication authority.

## Requirements

- Git with linked worktree support
- an authenticated Codex CLI for executor lanes
- an authenticated Claude CLI when Claude is the pinned cross-family opponent
- the managed `improve` skill for broad scouting
- the managed `improve-codebase-architecture` skill for architecture scouting
- a guarded Codex CLI adapter that satisfies the contract in
  `references/parallel-execution.md`

Exact model and effort pins are part of the safety contract. A lane stops
instead of silently substituting an unavailable executor or critic.

## Install

Clone the repository and copy the skill into your Codex skill directory:

```bash
git clone https://gitlab.sparta.business/skipstery/improve-loop.git
mkdir -p "${CODEX_HOME:-$HOME/.codex}/skills"
cp -R improve-loop/skills/improve-loop "${CODEX_HOME:-$HOME/.codex}/skills/improve-loop"
```

Restart Codex so it discovers the new skill.

## Use

Invoke `$improve-loop` without arguments to scout and rank candidates. Select
candidate numbers to enter Guided mode, or explicitly request Auto with a slice,
time, or finish-line bound.

## License

MIT
