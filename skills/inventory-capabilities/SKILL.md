---
name: inventory-capabilities
description: Use when deciding whether a control actually fails closed or is merely a convention — building the capability inventory and gap list by attempting the violation and recording the denial. Triggers on "does this actually block merges", "is this a real gate or just a request".
argument-hint: "[project-id] [mechanism to test, if scoping to one]"
---

Normative source: [Project profile — capability inventory](${CLAUDE_PLUGIN_ROOT}/profiles/project/03-capability-inventory.md), [`templates/capability.yaml`](${CLAUDE_PLUGIN_ROOT}/profiles/project/templates/capability.yaml).

This skill produces or updates `capability`-category facts (`PF-NNNN`) under `{project-id}/facts/capability/`, plus the collection's **gap list** — the sharpest distinction in the whole system: a **capability** fails closed on its own; a **convention** is something people are asked to honor; **instrumentation** runs and reports but does not block. Getting this wrong in the optimistic direction produces a practice that believes it holds a control it does not hold, which is worse than knowing it holds none.

## Procedure

1. **Enumerate candidate mechanisms** from the project survey: required status checks, branch protection rules, pre-commit/local hooks, schema validators in the pipeline, required reviews from named owners, environments that refuse unsigned artifacts.

2. **Classify each with one test: name what happens when somebody violates it.**
   - "The build goes red and merge is blocked" → **capability**.
   - "Someone would notice in review" → **convention**. Record it as a `convention` pointer fact instead (see [survey-project-profile](../survey-project-profile/SKILL.md)), not here.
   - "It runs and produces findings, but nothing requires acting on them" → **instrumentation**. Record as such, not as a capability.
   - A control with an available bypass (admin override, a skip flag, a force push, a shell redirect around a tool-level hook) enforces against accident, not against pressure. Record the bypass explicitly — it is not disqualifying on its own, but an unrecorded bypass is the single most misleading thing this inventory can contain.

3. **Verify by violating it — on a non-production target, on a throwaway branch, and never by disabling the control itself.** Reading configuration confirms a mechanism *exists*. Attempting the exact violation and being denied confirms it *works*. Only the second earns `fails_closed: true`.

4. **Where a violation test cannot be run safely, downgrade the fact to `asserted` and say so.** Do not claim `observed` for a capability that was never actually tested by violation — that is confirming existence and labeling it as confirming function.

5. **Record the full entry** on the [schema](${CLAUDE_PLUGIN_ROOT}/profiles/project/templates/capability.yaml): `statement` (what cannot happen), `detail.mechanism` (the concrete thing — a named check, a protection rule, a hook), `detail.layer` (`local | pipeline | platform | process` — layers differ in trustworthiness; a local hook is routable-around, a platform control is strongest), `detail.fails_closed`, `detail.bypass` (how, and by whom, or literally `none`), `detail.scope`, `detail.covers`, `detail.does_not_cover` (as important as `covers` — the gap a rule on tool-mediated writes leaves for a shell redirect, stated explicitly), `verification.method: observed`, `verification.how` (the violation attempted), `verification.last_result` (what happened), `authority` (who can disable or change it).

6. **Produce a gap-list entry** for every capability a blueprint or practice wanted but this project cannot provide: `want`, `why_unavailable` (`no mechanism | mechanism exists but not enabled | outside our authority`), `nearest_available` (the weaker thing that does exist, or none), `authority`, `requested` (date, if asked for). This list accumulates for free — every demotion from enforced to asserted during an adoption run is a gap entry — and it is worth more than the inventory itself, because the inventory describes the present and the gap list describes what to build.

7. **Keep the one-month interval.** `capability` facts drift in the dangerous direction — checks get disabled to unblock a release and not re-enabled, protection rules get relaxed for a migration, a required check gets renamed and silently stops being required — and none of that announces itself. Re-verification is cheap when `verification.how` names a violation attempt: run it, confirm the denial, stamp the date. Where re-testing is not cheap, that is itself a finding: a control nobody can easily test is a control nobody can easily trust.

## Do not

- Do not count a check that runs but does not block as a capability. That is instrumentation.
- Do not count a control with an unrecorded bypass as `fails_closed: true`. "None" is a strong claim — justify it.
- Do not confirm a capability by reading its configuration and call that `observed` with `fails_closed: true`. Only a violation attempt earns that.
- Do not run a violation test against a production target, on a real branch, or by disabling the control itself. If a safe violation test is not possible, downgrade to `asserted` and say so.
- Do not treat a planned, configured-but-disabled, or aspirational control as a capability. It is a gap entry.
- Do not record a capability with no named `authority` — that is a note, not a grant, but it must name someone.
- Do not turn this into a security assessment. The question is narrow: which mechanisms can a generated practice actually rely on to hold.
- Do not throw away a demotion. Every demotion from enforced to asserted is a gap entry — record it rather than letting the information evaporate into a run's notes.

## How to know you did it right

- Every entry with `fails_closed: true` names a real violation in `verification.how` and a real denial in `verification.last_result` — not a description of configuration.
- Every `bypass` field is filled in, even when the answer is "none" — never left blank.
- `does_not_cover` is populated wherever `covers` is, not treated as optional.
- Anything not safely testable by violation is `asserted`, never `observed`.
- The gap list names `want`, `why_unavailable`, `nearest_available`, and `authority` for every capability this project cannot provide.
- `last_verified` on every capability fact is within one month, or is flagged stale rather than silently trusted.
