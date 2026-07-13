#!/usr/bin/env bash
# Prove the exact Claude opponent and its read-only repository capabilities.
# Usage: preflight-claude-opponent.sh <worktree>
# Overrides: CLAUDE_BIN (default: claude), CLAUDE_PREFLIGHT_TIMEOUT (default: 180).
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "usage: preflight-claude-opponent.sh <worktree>" >&2
  exit 2
fi

worktree=$1
[[ -d "$worktree" ]] || { echo "worktree not found: $worktree" >&2; exit 2; }
git -C "$worktree" rev-parse --is-inside-work-tree >/dev/null 2>&1 \
  || { echo "not a Git worktree: $worktree" >&2; exit 2; }
worktree=$(cd "$worktree" && pwd -P)

claude_bin=${CLAUDE_BIN:-claude}
timeout_s=${CLAUDE_PREFLIGHT_TIMEOUT:-180}
if [[ "$claude_bin" == */* ]]; then
  [[ -x "$claude_bin" ]] || { echo "Claude executable is not runnable: $claude_bin" >&2; exit 2; }
else
  command -v "$claude_bin" >/dev/null \
    || { echo "Claude executable not found: $claude_bin" >&2; exit 2; }
fi

tmp_dir=$(mktemp -d "${TMPDIR:-/tmp}/improve-loop-fable-preflight.XXXXXX")
cleanup() {
  rm -rf "$tmp_dir"
}
trap cleanup EXIT INT TERM

canary=$(node -e 'process.stdout.write(require("node:crypto").randomUUID())')
canary_file="$tmp_dir/canary.txt"
printf '%s\n' "$canary" > "$canary_file"
expected_oid=$(git -C "$worktree" status --porcelain=v2 --branch \
  | sed -n 's/^# branch\.oid //p' | head -n 1)
[[ -n "$expected_oid" ]] || { echo "could not resolve worktree object id" >&2; exit 2; }

prompt=$(cat <<PROMPT
This is a read-only capability preflight, not a code review.
Use the Read tool to read the full contents of this file:
CANARY_FILE=$canary_file
Use the Bash tool to run exactly this command in the current worktree:
git status --porcelain=v2 --branch
Return exactly three lines and nothing else:
CANARY=<the exact file contents>
OID=<the value from the '# branch.oid' line>
READY
Do not infer either value and do not use any other command.
PROMPT
)

response_file="$tmp_dir/response.json"
timed_out_flag="$tmp_dir/timed-out"
allowed_tools='Read,Glob,Grep,Bash(git status *)'
denied_tools='Edit,Write,NotebookEdit,WebFetch,WebSearch,Task,Agent,Skill'

(
  cd "$worktree"
  CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1 \
  DISABLE_TELEMETRY=1 \
  DISABLE_ERROR_REPORTING=1 \
  "$claude_bin" --print --input-format text --output-format json \
    --model claude-fable-5 --effort high \
    --permission-mode dontAsk \
    --tools 'Read,Glob,Grep,Bash' \
    --allowedTools "$allowed_tools" \
    --disallowedTools "$denied_tools" \
    --safe-mode --no-chrome --disable-slash-commands \
    --strict-mcp-config --mcp-config '{"mcpServers":{}}' \
    --no-session-persistence --add-dir "$tmp_dir" \
    <<< "$prompt"
) > "$response_file" &
claude_pid=$!

node - "$claude_pid" "$timeout_s" "$timed_out_flag" <<'NODE' &
const fs = require("node:fs");
const [pidRaw, timeoutRaw, flag] = process.argv.slice(2);
const pid = Number(pidRaw);
const timeoutMs = Number(timeoutRaw) * 1000;
setTimeout(() => {
  fs.writeFileSync(flag, "");
  try { process.kill(pid, "SIGTERM"); } catch {}
  setTimeout(() => {
    try { process.kill(pid, "SIGKILL"); } catch {}
  }, 5_000);
}, timeoutMs);
NODE
watchdog_pid=$!

set +e
wait "$claude_pid"
status=$?
set -e
kill "$watchdog_pid" 2>/dev/null || true
wait "$watchdog_pid" 2>/dev/null || true
if [[ -f "$timed_out_flag" ]]; then
  echo "Claude opponent preflight timed out after ${timeout_s}s" >&2
  exit 124
fi
[[ $status -eq 0 ]] || exit "$status"

node - "$response_file" "$canary" "$expected_oid" <<'NODE'
const fs = require("node:fs");
const [responseFile, canary, expectedOid] = process.argv.slice(2);
const payload = JSON.parse(fs.readFileSync(responseFile, "utf8"));
const actualModels = Object.keys(payload.modelUsage ?? {});
if (!actualModels.includes("claude-fable-5") || actualModels.some((model) => model !== "claude-fable-5")) {
  throw new Error(
    `Claude opponent model mismatch: expected only claude-fable-5, got ${actualModels.join(", ") || "no model evidence"}`,
  );
}
if (typeof payload.result !== "string") {
  throw new Error("Claude opponent preflight returned no text result");
}
const expectedLines = [`CANARY=${canary}`, `OID=${expectedOid}`, "READY"];
const actualLines = payload.result.trim().split(/\r?\n/);
if (actualLines.length !== expectedLines.length || actualLines.some((line, index) => line !== expectedLines[index])) {
  throw new Error(
    `Claude opponent preflight capability mismatch: expected ${JSON.stringify(expectedLines)}, got ${JSON.stringify(actualLines)}`,
  );
}
NODE

printf 'READY model=claude-fable-5 effort=high read=ok git=ok oid=%s\n' "$expected_oid"
