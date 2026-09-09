---
kind: agent-context
owner: <you / team>
applies_to: <project: name>
last_reviewed: <YYYY-MM-DD>
---

*[Magentix](../../../README.md) › [Blueprints](../../README.md) › [Agent Context Kit](../README.md) › Workflow Index*

# Workflow Index

<!-- This is a ROUTER, not a manual. Each row should be short enough to
scan in a few seconds; if a workflow needs real detail (step-by-step
procedure, schema, examples), put that in its own file under a
`workflows/` or `skills/` folder and link to it. The agent loads that
detail only when the row's trigger condition is actually met.

Do not use this file to restate things a linter, type system, or style
config already enforces — that's context spent on something the tooling
already guarantees. -->

## Active workflows

<!-- The "Authority" column records where the say-so lives for a workflow
that has its own gates or checks: a named approver, a pipeline check, an
owning team. Filling it in is what keeps this file a router instead of a
second rulebook — the agent learns *that* a gate exists and where to look,
without this file trying to describe or, worse, restate the rule. Leave it
blank for workflows with no gate of their own. -->

| Workflow | When to use it | What it does | Authority | Detail |
|---|---|---|---|---|
| | | | | `workflows/....md` |
| | | | | `workflows/....md` |
| | | | | `workflows/....md` |

## Explicitly out of scope here

<!-- Things people are tempted to add but shouldn't: -->

- General coding conventions → enforced by linter/formatter config, not this file
- Anything a script, hook, or pipeline check already enforces → point at the enforcement; never restate its rules, because the copy here will be the stale one
- Rules a defined process already owns → a row saying the process exists and where it is documented; not a summary of its steps
- One-off tasks → don't need a permanent row; just do them
- Anything that hasn't recurred at least twice → not a workflow yet

## Adding a workflow

<!-- A short note-to-self on the bar for "this deserves a row": has it come
up more than once, does it have a non-obvious trigger or procedure, would a
new agent (or new teammate) benefit from a pointer to it?

One more test before adding: is this row a pointer, or is it starting to
become the documentation? If the row is growing paragraphs, the detail file
is the place for them. -->
