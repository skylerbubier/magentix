#!/bin/sh
# Example PreToolUse hook (matcher: Bash) — the "deny" half of the pattern in
# ../README.md. Refuses a shell command that names a well-known secret file.
#
# Contract (see "Hooks: the exit-code contract" in ../README.md):
#   exit 0  no objection
#   exit 2  block the call; stderr is fed back to the model as the reason
#
# This is illustrative. It inspects only the raw command text, so it fails
# closed for the exact shapes it matches and for nothing else — a command that
# reaches the same file through a variable, a glob, or a wrapper script walks
# straight past it. That limit is the point the README makes about tool-level
# automation; do not read this hook as a security control.

input=$(cat)

# Pull tool_input.command out of the hook payload. jq is the honest way; the
# grep fallback keeps the example runnable without it.
if command -v jq >/dev/null 2>&1; then
  cmd=$(printf '%s' "$input" | jq -r '.tool_input.command // empty')
else
  cmd=$(printf '%s' "$input" | grep -o '"command"[[:space:]]*:[[:space:]]*"[^"]*"' | head -n1 | sed 's/^"command"[[:space:]]*:[[:space:]]*"//; s/"$//')
fi

[ -z "$cmd" ] && exit 0

# Adapt this list to the project. Each pattern is a fixed string.
for needle in '.env' 'id_rsa' 'id_ed25519' '.npmrc' '.netrc' 'credentials.json' '.aws/credentials'; do
  case "$cmd" in
    *"$needle"*)
      echo "deny-secrets-read: command references '$needle'; read secrets through a tool the project allows, not the shell." >&2
      exit 2
      ;;
  esac
done

exit 0
