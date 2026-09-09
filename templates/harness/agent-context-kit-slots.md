*[Magentix](../../README.md) › Templates › [Harness](README.md) › Agent Context Kit Slots*

# Agent Context Kit — slot mapping

This table is **non-normative**. The [Agent Context Kit blueprint](../../blueprints/agent-context-kit/README.md)
itself names no tool — that is a hard rule, stated in
[`CONTRIBUTING.md`](../../CONTRIBUTING.md), [`docs/architecture.md`](../../docs/architecture.md), and
[`blueprints/README.md`](../../blueprints/README.md) — so it cannot state where its four documents land
for any specific tool. This file is the tool-specific detail that would otherwise leak into the
blueprint: a rough, illustrative mapping of the kit's four documents onto a few common tools' real
files.

A real adoption does not resolve placement from this table. It resolves placement through the
adopter's own harness binding —
[`../../profiles/user/03-harness-binding.md`](../../profiles/user/03-harness-binding.md) at personal
scope, [`../../profiles/project/04-harness-binding.md`](../../profiles/project/04-harness-binding.md)
at project scope — which records what a specific person's or project's tooling actually provides.
Where this table and a harness binding disagree, the binding wins; this table is a starting point for
filling one in, not a substitute for it.

## Rough mapping onto common setups

| Concept | Claude Code | Cursor | Codex | Generic / API |
|---|---|---|---|---|
| Global, always-loaded | `~/.claude/CLAUDE.md` | `.cursor/rules` (user-level) | `~/.codex/AGENTS.md` | System prompt, prepended |
| Project-level, shared | `./CLAUDE.md` | `.cursor/rules` (project) | `./AGENTS.md` | Injected per-session |
| Deep reference / workflow detail | agent-config dir (`.claude/skills/*/SKILL.md`) | linked rule files | linked docs | Retrieved on demand (RAG or tool call) |
| Agent-written state | auto-memory, or a state path always writable | — (build your own) | — (build your own) | A file/table the agent reads+writes via a tool |

## See also

- [`../../blueprints/agent-context-kit/README.md`](../../blueprints/agent-context-kit/README.md) — the
  blueprint these four documents belong to.
- [`../../profiles/user/03-harness-binding.md`](../../profiles/user/03-harness-binding.md) — the
  personal-scope harness binding that actually resolves this placement for one person.
- [`../../profiles/project/04-harness-binding.md`](../../profiles/project/04-harness-binding.md) — the
  project-scope harness binding that actually resolves this placement for one project.
