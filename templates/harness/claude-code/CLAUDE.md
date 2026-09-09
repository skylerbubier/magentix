---
kind: agent-context
owner: <who maintains this file>
applies_to: project: <project name>
last_reviewed: <YYYY-MM-DD>
---

<!--
  This is the Claude Code project_context slot
  (../../../profiles/project/04-harness-binding.md). It is SHARED: everyone
  who opens this repository with Claude Code loads it.

  Only the project-level, shared part of the Agent Context Kit
  (../../../blueprints/agent-context-kit/README.md) belongs in this file —
  roughly its 03-workflow-index.md. Personal preference and interaction
  style (01-principal.md, 02-interaction-protocol.md) is NOT shared context
  and must not be added here; it belongs in the personal overlay
  (.claude/settings.local.json, or the person's own
  ~/.claude/CLAUDE.md) instead. If this file is already the home for
  team-owned conventions, add the workflow index beside it as its own file
  and link to it rather than merging the two.
-->

# <Project name> — Agent Context

## What this project is

<!-- One or two identity facts, or a pointer to fuller docs. Do not restate
     a convention that is already stated elsewhere in the repo — point at
     it (see ../../../profiles/project/01-fact-format.md's rule that
     convention facts are pointers, never copies). -->

<one or two lines>

## How work gets done here

<!-- The collapsed form of 03-workflow-index.md: recurring workflows and
     where each one's full detail lives on demand. -->

| Workflow | When it applies | Detail |
|---|---|---|
| <workflow name> | <trigger> | [<path>](<path>) |

## Conventions and constraints

<!-- Pointers only. -->

- <topic>: see <path>

## On-demand reference

<!-- Deeper material the agent should load only when the task needs it. -->

- <topic> → `.claude/skills/<name>/SKILL.md`
- <topic> → <linked doc>

## Agent working state

<!-- Where the agent keeps its own continuity notes across sessions and
     compactions (the 04-working-log.md equivalent). This path must stay
     writable at every point in a task, including under whatever else this
     project's settings restrict — mark it excluded from any deny rule
     that would otherwise cover it. -->

Continuity log: `<path — e.g. .claude/state/working-log.md>`
