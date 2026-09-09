# Claude Code — a worked harness binding

This is one worked example of filling `harnesses[]` for a `harness/bindings.yaml` — user-scope or project-scope — against Claude Code specifically. Another harness (Cursor, Codex, a generic API integration) gets its own entry with its own real paths; nothing here generalizes across tools, which is the whole point of confining tool detail to the binding.

Fill values against what is actually installed and configured on this machine or in this repo — do not copy this file's paths as assumptions.

## Slot mapping

| Abstract slot | Claude Code concrete mapping | `scope` | Notes |
|---|---|---|---|
| **Always-loaded / project context** (personal) | `~/.claude/CLAUDE.md` | `personal` | User-level, always loaded. Safe home for user-profile-rendered criteria. |
| **Always-loaded / project context** (shared) | `./CLAUDE.md` at the project root | `shared` | Loaded for everyone working in the repo. This is the usual contention point across several adopted practices — record `owned_by_practice` in the project binding. No individually-authored criterion may render here. |
| **On-demand** | `.claude/skills/<name>/SKILL.md`, loaded when its `description` matches the task | `personal` or `shared`, matching where the skill directory lives | Progressive disclosure: the skill body plus its own `references/*.md`, loaded only when followed. |
| **Automation** | Hooks configured in `.claude/settings.json` (or `.claude/settings.local.json` for personal-only hooks), or a plugin's `hooks/hooks.json` | Usually `shared` for repo-committed settings/plugin hooks; `personal` for `settings.local.json` | See "What can actually fail closed" below — hooks are Claude Code's closest thing to enforcement, but the bypass is real and must be named. |
| **Personal overlay** | `.claude/settings.local.json` (conventionally git-ignored, per-user, uncommitted) | `personal`, `committed: false` | The one project-scope slot where per-person artifacts belong. If a project's Claude Code setup has no such file in use, personal artifacts have no home in that project — that is correct; do not write them into `CLAUDE.md` instead. |
| **Agent state** | A dedicated scratch/state path outside normal write restrictions — e.g. a scratchpad directory excluded from any path-based policy, or a working-log file per the [agent-context-kit](${CLAUDE_PLUGIN_ROOT}/blueprints/agent-context-kit/README.md) blueprint | `personal` (or per-thread) | Must be writable at every point in a task, including under whatever restrictions a practice's own automation imposes. If a hook or permission rule can deny a write to this path, that is a defect to fix, not a constraint to route around. |
| *(Not a profile slot, but part of the tool)* Subagent definitions | `.claude/agents/*.md` | `shared` (repo) or `personal` (`~/.claude/agents/`) | A named subagent's tool list is enforced by the SDK for that subagent's own calls — it cannot invoke a tool outside the list it was given. That is a real, narrow enforcement boundary, distinct from anything in `CLAUDE.md` or a skill body. |

## What can actually fail closed, and what cannot

**Cannot fail closed — asserted only:**
- `CLAUDE.md`, at either scope. Pure context, read and followed because the agent was asked to. Nothing checks whether it was honored.
- `.claude/skills/<name>/SKILL.md`. Loading is triggered by description match; following its instructions is voluntary.
- Anything in a plugin's non-hook files (agents, commands, other skills). Instructions, not gates.

**Can fail closed, within a real and nameable limit:**
- **Permission rules in `.claude/settings.json` / `settings.local.json`** (`allow` / `ask` / `deny` on tool calls). A `deny` rule blocks that specific tool call outright — no agent judgment involved. This is the nearest thing Claude Code itself has to an enforced control, and it is real for the surface it covers.
- **Hooks** (in settings, or a plugin's `hooks/hooks.json`). A `PreToolUse` hook that exits denying the call blocks that call. The bypass is equally real and must be named in `automation_bypassable`: a hook scoped to specific tools (e.g. `Edit`/`Write`) does not see the same change made through `Bash`; and anyone able to edit the settings or hook config can remove the hook itself. Record both.
- **A subagent's declared tool list.** The SDK will not let a subagent invoke a tool it was not granted. Narrow, but a genuine enforcement boundary for that subagent's own actions.

**Never fails closed here, no matter how it is configured:** anything requiring a human or another automated system to notice and act — a documented review step, a convention stated in `CLAUDE.md`, a skill that recommends a check. Where a project profile needs something that actually holds regardless of the agent's cooperation, that has to route through the project's own pipeline or platform capability — see [inventory-capabilities](../../inventory-capabilities/SKILL.md) — never through this binding. `can_enforce` (user scope) and `automation_fails_closed` (project scope) should read `false` unless the specific mechanism above is what is being claimed, and even then the bypass must be named.
