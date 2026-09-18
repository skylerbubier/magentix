# Artifact formats and host behaviors

Read the section for the artifact being optimized. Field names and limits change; when a host's docs are reachable, confirm against them before relying on a limit below.

## Contents
- Agent Skill (SKILL.md)
- Claude Code subagent
- Claude Code slash command
- CLAUDE.md / AGENTS.md / project memory
- IDE rules files (Cursor, Copilot, Windsurf)
- System prompt / API prompt template
- Cross-cutting: loading tiers and token budgets

---

## Agent Skill (SKILL.md)

Directory: `<skill-name>/SKILL.md` plus optional `scripts/`, `references/`, `assets/`.

Frontmatter:
- `name` — required; 1–64 chars; lowercase letters, digits, hyphens; no leading/trailing hyphen; must not contain `anthropic` or `claude`. Gerund form (`processing-pdfs`) is the recommended convention; noun or verb phrases are acceptable. Keep the existing name unless asked.
- `description` — required; ≤1024 chars; third person; must say **what** it does and **when** to use it. This is the only text visible before the skill loads, so it carries all triggering logic. Being explicit and even repetitive about trigger phrases is intentional, because models under-trigger skills; do not neutralize it.
- `compatibility` — optional; environment/tool requirements.
- Claude Code adds: `disable-model-invocation: true` (manual `/name` only), `user-invocable`, `allowed-tools`, `context: fork` (run in a subagent), `argument-hint`. Preserve any present.

Body:
- Keep under ~500 lines; some registries cap the whole file at 20 KB. Split beyond that.
- Loaded only when triggered, so it can carry more than a description, but every token still competes with the conversation.
- References one level deep from SKILL.md; reference files >100 lines get a table of contents.
- Say whether a script is to be **run** ("Run `scripts/x.py`") or **read** ("See `scripts/x.py` for the algorithm").
- Forward-slash paths only.
- MCP tools by fully qualified name: `Server:tool_name`.
- `$ARGUMENTS` / `$1` are substituted when invoked as a slash command; keep them.

## Claude Code subagent

Location: `.claude/agents/<name>.md` (project) or `~/.claude/agents/<name>.md` (user). Markdown body is the system prompt of an isolated context; it does **not** see the parent conversation.

Frontmatter fields to preserve: `name`, `description`, `tools` (allowlist; omitting inherits everything), `disallowedTools`, `model` (`sonnet`/`opus`/`haiku`/full id/`inherit`), `permissionMode`, `mcpServers`, `hooks`, `maxTurns`, `skills` (preloaded, full content injected), `initialPrompt`, `memory`, `effort`, `background`, `omitClaudeMd`, `isolation`.

Optimization notes:
- `description` drives delegation. "Use PROACTIVELY when…" style phrasing is a triggering device; keep it.
- Because the subagent starts cold, the body must state task, inputs it will receive, tools to use, and the **return format** — the parent only sees what comes back. A compact, structured return contract is usually the highest-value edit.
- Restricting `tools` is a safety and focus lever; do not widen it while "cleaning up".
- Anything in `skills:` is injected in full; a bloated skill there costs on every run.

## Claude Code slash command

Location: `.claude/commands/<name>.md`. Functionally merged with skills; a `.claude/skills/<name>/SKILL.md` with the same name takes precedence. Frontmatter: `description`, `allowed-tools`, `argument-hint`, `model`. Body supports `$ARGUMENTS`, `$1..$n`, `@file` references, and `!`command`` inline shell.

If the user is willing, suggest migrating a command to a skill directory (adds supporting files and auto-invocation); otherwise optimize in place.

## CLAUDE.md / AGENTS.md / project memory

Always loaded at session start, in every conversation, for every task. This is the most expensive tier per token.

Hierarchy: enterprise managed → user `~/.claude/CLAUDE.md` → project `./CLAUDE.md` → subdirectory `CLAUDE.md` (loaded when files there are touched). `CLAUDE.local.md` is per-user, git-ignored. `@path/to/file` imports inline another file. `.claude/rules/*.md` files are additional always-on rules (some support `paths:` globs to scope them).

What belongs here: build/test/lint commands, repo conventions the model cannot infer from code, architectural decisions, things the model repeatedly gets wrong. What does not: anything a linter enforces, general engineering advice, task-specific procedures (those are skills), long reference material (link it; the model can read files just-in-time).

Optimization notes:
- Every line should answer "would the agent do the wrong thing without this?" If no, cut.
- Move task-specific procedures into skills; move long facts into files referenced by path.
- Group by concern with short headers so the model can scan; avoid narrative.
- Scope rules to subdirectories or `paths:` globs when they only apply there.

## IDE rules files (Cursor, Copilot, Windsurf)

- **Cursor**: `.cursor/rules/*.mdc` with frontmatter `description`, `globs`, `alwaysApply`. `alwaysApply: true` is the always-loaded tier; scope with `globs` where possible.
- **GitHub Copilot**: `.github/copilot-instructions.md` (always on) and `.github/instructions/*.instructions.md` with `applyTo:` glob frontmatter (scoped). Agent definitions in `.github/agents/*.agent.md`. Copilot prompt files `*.prompt.md` are the slash-command analogue.
- **Windsurf**: `.windsurf/rules/*.md` with activation mode (always / glob / model-decided / manual).
- Cross-tool: `AGENTS.md` at repo root is read by several agents; treat like CLAUDE.md.

Same tiering logic: always-on files get the strictest budget; scoped files can carry more.

## System prompt / API prompt template

No frontmatter. Structure with a few clearly delimited sections (Markdown headers or XML tags such as `<instructions>`, `<tool_guidance>`, `<output_format>`); exact tag names matter less than consistency. Order: role and goal → hard constraints → tool guidance → output format → examples. Put anything the model must remember across a long task near the top; models attend less reliably to the middle of long contexts.

Template variables (`{{var}}`, `{var}`, `$VAR`) are literals; preserve exactly, including casing.

For prompts used with several models, aim for wording that the smallest model follows; test on that one.

---

## Cross-cutting: loading tiers and token budgets

| Tier | Examples | Budget stance |
|---|---|---|
| Always in context | CLAUDE.md, rules with `alwaysApply`, skill `description`s, system prompts | Minimal. Every token is paid on every turn of every task. |
| Loaded on trigger | SKILL.md body, subagent body, slash command body | Moderate. Must be complete enough to run the task cold. |
| Loaded on demand | `references/*.md`, `assets/`, scripts read as reference | Generous. Zero cost until read; optimize for findability (TOC, descriptive filenames). |
| Executed, not loaded | `scripts/*` that are run | Only the output costs tokens. Prefer scripts for deterministic work. |

When a unit of content sits in a higher tier than it needs, moving it down is usually the largest single saving available.
