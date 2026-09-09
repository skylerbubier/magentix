---
name: capture-correction
description: Use when the person corrects the agent — "no, I meant", "stop doing X", "remember that I prefer", "you did that wrong again" — to decide whether it's durable and, if so, log or promote it. Skips one-off, task-specific instructions.
---

Normative source: [User profile — collection (promotion)](${CLAUDE_PLUGIN_ROOT}/profiles/user/02-collection.md), [criterion format (`source: corrected`)](${CLAUDE_PLUGIN_ROOT}/profiles/user/01-criterion-format.md), [Working log template](${CLAUDE_PLUGIN_ROOT}/blueprints/agent-context-kit/templates/04-working-log.md).

This skill decides whether a correction belongs in the session's working log (first occurrence) or should be promoted to a durable `UC-NNNN` criterion with `source: corrected` (recurrence), and records it in exactly the one place that is right for it.

## Procedure

1. **Filter first: is this durable, or one-off?** A correction about how the agent should behave or what it should know going forward is a candidate. An instruction scoped to the current task only ("for this file, use tabs") is not — do nothing further.

2. **Check for prior occurrences** before writing anything: the working log's corrections table, and the user profile (via [elicit-user-profile](../elicit-user-profile/SKILL.md)) for an existing criterion this might already be recorded as, superseded by, or in conflict with.

3. **First occurrence → log it, do not promote.** Add one row to the working log's corrections table: what went wrong, what to do instead, the date. That is the whole action. A first correction is a moment, not yet a pattern.

4. **Recurrence → promote.** The source documents give this trigger at two points, and both matter: the collection doc calls the *second* occurrence "a pattern" — the point at which it should be promoted — while the working-log template calls a *third* appearance in the log itself the hard signal that it is now overdue. Treat the second recurrence as the point to act, and treat a correction still sitting in the log at a third occurrence as a defect to fix immediately, not a normal state.

5. **When promoting**, write a new criterion via [elicit-user-profile](../elicit-user-profile/SKILL.md): `source: corrected`, `evidence` stating what happened (required — without it a correction is indistinguishable from an opinion), and whichever `category` the fact actually is — often `correction`, but a correction about interaction style, delegated authority, or context is that category instead. `category` describes the kind of fact, not which document it came from.

6. **If the correction contradicts an existing active criterion, supersede — never edit in place.** The old criterion is kept, marked `status: superseded`, with the new one's `supersedes` pointing back and the correction as its evidence.

7. **Remove or promote the entry out of the working log** once it has become a criterion. A promotion landing somewhere else — a team convention, something a check should catch — is also a good outcome; either way, it leaves the log rather than accumulating there.

8. **Regenerate `INDEX.yaml`** after any promotion, per [elicit-user-profile](../elicit-user-profile/SKILL.md).

## Do not

- Do not fire on a one-off, task-specific instruction. If nothing about it would still be true in a different task, it is not a candidate.
- Do not promote on the first occurrence. Log it first; promotion is what recurrence earns.
- Do not edit an existing criterion in place to reflect a correction. Supersede it, with the correction as the new fact's evidence.
- Do not promote without a real one-line `evidence` — required for `source: corrected`.
- Do not let a correction sit in the working log past a second occurrence unaddressed, and never past a third.
- Do not let the working log become an uncurated second instructions file. Durable material is promoted out and deleted from the log; it does not accumulate in place.
- Do not restate, in the log or in a new criterion, something a mechanism, a team convention, or another document already owns. Point at it instead.

## How to know you did it right

- A first-time correction produces exactly one working-log row, and nothing else changes.
- A recurring correction produces a new criterion with `source: corrected` and a genuine `evidence` line, or a supersession of the criterion it contradicts — never both a lingering log row and a new criterion for the same fact.
- No criterion exists anywhere in the collection for a correction that was actually scoped to one task.
- The working log's corrections table shrinks over time as entries get promoted out, rather than growing without bound.
