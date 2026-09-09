*[Magentix](../../README.md) › Templates › Harness*

# Harness Template Packs

A **harness template pack** is what a concrete agent tool needs in order to
receive Magentix's materialized artifacts — the real files, at real paths,
in the real format that tool actually reads. Everything under
`templates/harness/` is inert, copyable reference material. Nothing here is
active configuration for this repository; a pack is meant to be copied into
a project (or a person's own setup) and adapted there.

This is the other half of the harness layer. A profile's harness binding —
[`../../profiles/user/03-harness-binding.md`](../../profiles/user/03-harness-binding.md)
at personal scope,
[`../../profiles/project/04-harness-binding.md`](../../profiles/project/04-harness-binding.md)
at project scope — records *which* paths and slots a given tool actually has,
for one specific person or one specific project. A template pack is the
generic version of the same shape: a starting point for filling in a binding
for a tool nobody has bound yet, and the concrete template the adoption
engine materializes into once a binding exists.

## What's here

- [`claude-code/`](claude-code/README.md) — a full harness template pack for Claude Code.
- [`agent-context-kit-slots.md`](agent-context-kit-slots.md) — a non-normative mapping of the
  [agent-context-kit](../../blueprints/agent-context-kit/README.md) blueprint's four files onto
  several common tools' slots, kept out of the blueprint itself so the blueprint continues to name
  no tool.

## The abstract slots

Every harness binding, at either scope, resolves to some subset of the same
five slots. Not every tool fills every slot, and recording which ones it
lacks matters as much as filling the ones it has.

| Slot | Question it answers | Present at |
|---|---|---|
| **Project context** (project scope) / **always-loaded** (user scope) | What loads into every session, unconditionally? | Both scopes |
| **On-demand reference** | What loads only when the task actually needs it? | Both scopes |
| **Automation** | What does the tool run or gate on its own, and does that fail closed? | Project scope mainly — personal-scope automation is rare, and `can_enforce` is almost always `false` there |
| **Personal overlay** | Where do per-person artifacts live on a shared project, uncommitted? | Project scope, pointing back to the user profile |
| **Agent state** | Where can the agent write its own continuity notes, at any point in a task, including under whatever else is restricted? | Both scopes |

A template pack for a tool states, concretely, which real file or directory
fills each slot that tool actually supports — and says plainly when a slot
has no home in that tool, rather than improvising one. "This tool has no
personal slot" is a correct and useful answer; routing a preference into a
shared file anyway is the failure the binding formats exist to prevent.

## Fail-closed, honestly

The automation slot is the one place a template pack can mislead if it
isn't careful. A tool-level hook is usually deny-only at best, and it is
often bypassable — a shell redirect is not a mediated tool call, and no
path-based rule sees it. A template pack must say, for each piece of
automation it shows, whether it fails closed and exactly how it can be
routed around if not. See
[`claude-code/README.md`](claude-code/README.md) for a worked example of
drawing that line for one real tool.

## Contributing a pack for another tool

1. Create `templates/harness/<tool>/`.
2. Write a `README.md` there that maps the five slots above onto that
   tool's real files, states its context/settings precedence, and — the
   part most likely to get skipped — says plainly which of its mechanisms
   can fail closed and which cannot.
3. Include the actual template files (settings skeleton, context skeleton,
   an automation example if the tool has one) with obviously-placeholder
   values — never a working configuration lifted from one real project.
4. Cross-link back to
   [`../../profiles/user/03-harness-binding.md`](../../profiles/user/03-harness-binding.md)
   and
   [`../../profiles/project/04-harness-binding.md`](../../profiles/project/04-harness-binding.md)
   so someone binding that tool for the first time lands here.
5. Do not wire anything in the pack into this repository's own
   configuration. A template pack is reference material an adopter copies
   elsewhere; it is never active configuration for Magentix itself.
