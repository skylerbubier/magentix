#!/bin/sh
# Example PostToolUse hook (matcher: Edit|Write) — the "observe" half of the
# pattern in ../README.md. Appends one line per file change to an agent-state
# log and never blocks anything.
#
# Contract: exit 0 always. A PostToolUse hook runs after the tool has already
# acted, so blocking here changes nothing — this is instrumentation, not a gate,
# and it should be recorded as such in a capability inventory.
#
# The log lands under .claude/state/, the agent-state slot ../README.md
# designates. Make sure no permissions.deny rule covers that path, or the
# hook itself becomes the thing that fails.

input=$(cat)

if command -v jq >/dev/null 2>&1; then
  path=$(printf '%s' "$input" | jq -r '.tool_input.file_path // empty')
  tool=$(printf '%s' "$input" | jq -r '.tool_name // empty')
else
  path=$(printf '%s' "$input" | grep -o '"file_path"[[:space:]]*:[[:space:]]*"[^"]*"' | head -n1 | sed 's/^"file_path"[[:space:]]*:[[:space:]]*"//; s/"$//')
  tool=$(printf '%s' "$input" | grep -o '"tool_name"[[:space:]]*:[[:space:]]*"[^"]*"' | head -n1 | sed 's/^"tool_name"[[:space:]]*:[[:space:]]*"//; s/"$//')
fi

[ -z "$path" ] && exit 0

root=${CLAUDE_PROJECT_DIR:-.}
log="$root/.claude/state/file-changes.log"
mkdir -p "$(dirname "$log")" 2>/dev/null || exit 0
printf '%s\t%s\t%s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "${tool:-?}" "$path" >> "$log" 2>/dev/null

exit 0
