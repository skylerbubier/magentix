---
name: bind-harness
description: Use when mapping a profile's abstract slots onto a concrete agent tool, or migrating between tools — the only place a tool name or config path may appear. Triggers on "set up the harness binding", "migrate to a new agent tool", "switch from Claude Code to X".
argument-hint: "[user | project] [tool name] [existing bindings.yaml path, if not the default]"
---

Normative source: [User profile — harness binding](${CLAUDE_PLUGIN_ROOT}/profiles/user/03-harness-binding.md), [Project profile — harness binding](${CLAUDE_PLUGIN_ROOT}/profiles/project/04-harness-binding.md), `templates/bindings.yaml` for [user](${CLAUDE_PLUGIN_ROOT}/profiles/user/templates/bindings.yaml) and [project](${CLAUDE_PLUGIN_ROOT}/profiles/project/templates/bindings.yaml).

This skill fills or migrates `harness/bindings.yaml` — the **one bounded section**, at user or project scope, where an agent tool's name, config path, or product feature is permitted to appear anywhere in a profile collection. One worked mapping for Claude Code is at [references/claude-code-slots.md](references/claude-code-slots.md); any other harness gets its own such mapping, built the same way.

## Procedure

1. **Determine scope.** User scope (`profiles/user/03-harness-binding.md`) describes one person's tooling — mostly `personal` slots, `role: primary | secondary | occasional`, `can_enforce` almost always `false`. Project scope (`profiles/project/04-harness-binding.md`) describes one project's tooling — mostly `shared` slots, `adoption: required | supported | tolerated`, and one `personal_overlay` slot as the sole exception.

2. **Fill the `harnesses[]` entry** on the appropriate schema:
   - User: `id`, `tool`, `role`, `slots.{always_loaded, on_demand, presentation, agent_state}`, `capabilities.{reads_personal_context, supports_on_demand_reference, supports_presentation_config, can_enforce}`, `precedence`.
   - Project: `id`, `tool`, `adoption`, `slots.{project_context, on_demand, automation, personal_overlay, agent_state}`, `capabilities.{reads_project_context, supports_on_demand_reference, supports_automation, automation_fails_closed, automation_bypassable}`, `precedence`.

3. **Assess every capability pessimistically.** The question is never "does the tool have a feature that looks like this" — it is "does it actually enforce, or only request?" At user scope, `can_enforce: true` would be unusual and must name a real mechanism to be believed. At project scope, `automation_fails_closed: true` requires the same, and `automation_bypassable` must name the real bypass — tool-level automation (a hook) is usually deny-only at best and routinely bypassable (a write through a shell redirect is not a tool call, and it will not be seen by a hook scoped to tool calls). Where something must actually hold, it routes through a pipeline or platform capability instead — see [inventory-capabilities](../inventory-capabilities/SKILL.md) — not through this binding.

4. **Honor `scope: personal | shared` absolutely.**
   - No individually-authored content ever materializes into a slot marked `shared` — that is how a personal preference silently becomes a colleague's rule.
   - If a tool's only always-loaded slot (user scope) or project-context slot is `shared`, the correct record is "this tool has no personal slot" — not "use it anyway."
   - At project scope, `personal_overlay` is the one slot where per-person artifacts may be written, and it is uncommitted by construction. No such slot means personal artifacts have no home in this project, which is a fact to record, not a problem to route around by writing into a shared file.

5. **Verify `agent_state` is writable at any point in a task**, including under whatever other write restrictions a practice imposes. A binding whose agent-state path can be denied produces an agent that cannot hand off work across a session boundary — this is a defect to fix immediately, not a tolerable gap.

6. **At project scope, reconcile `owned_by_practice`** on every shared slot against the project's `practices.yaml`. Leaving a slot `unclaimed` when two practices write it is exactly the collision the cross-project `INDEX.yaml` reports — see [survey-project-profile](../survey-project-profile/SKILL.md).

7. **Execute migration between tools** as four steps, touching no criterion and no fact:
   1. Add the new harness entry, with its slots, capabilities, and (project scope) `adoption`.
   2. Regenerate every artifact for the new harness — every criterion or fact renders into the new shape.
   3. Verify each generated artifact actually loads where the binding claims it will. An artifact in a location the tool does not read is stored, not adopted, and this failure is silent — check it directly, do not assume.
   4. Retire the old harness entry (`retired: [{id, retired_on, artifacts_removed}]`) and remove its artifacts. A retired tool's context file left behind keeps being loaded by anyone still running that tool, and it will be stale.

## Do not

- Do not let a tool name, config path, or product feature appear in any criterion or fact. That discipline exists only because it is confined here — if you find yourself wanting to write one anywhere else, stop.
- Do not materialize personally-authored content into a slot marked `shared`.
- Do not claim `can_enforce: true` (user) or `automation_fails_closed: true` (project) without naming a real, specific mechanism — and its bypass.
- Do not treat tool-level hooks or automation as equivalent to a pipeline or platform capability. Record what they actually are; route anything that must truly hold through the capability inventory instead.
- Do not read, edit, or re-confirm a criterion or fact as part of a migration. If a migration seems to require that, something tool-specific leaked upstream into the collection, and that is the bug to fix, not the migration to complete anyway.
- Do not leave a retired harness's artifacts in place. Remove them as the last migration step, not "eventually."
- Do not write documentation about the tool itself into this file. Record only the paths and capabilities this profile depends on; point at the tool's own docs for everything else.

## How to know you did it right

- Every slot the profile actually uses has a filled entry — no slot left implicitly assumed.
- Every `true` capability names the mechanism that makes it true; every `false` is a plain, unembarrassed `false`.
- Every `shared` slot at project scope has an `owned_by_practice` value, not a blank.
- `agent_state` was actually tested as writable, not assumed.
- A migration ends with the old harness entry retired and its artifacts gone from disk — not merely superseded in the binding while old files linger.
- Grepping the rest of the collection (criteria, facts, spec entries) for the tool's own name turns up nothing outside this file.
