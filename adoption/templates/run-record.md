*[Magentix](../../README.md) › [Adoption engine](../README.md)*

# Run Record — {practice-id}

What belongs to **this run**. Facts belong to the profile, not here.

The division is strict, because getting it wrong is what makes a second adoption as expensive as the first:

| Belongs to the profile | Belongs here |
|---|---|
| The fact, its rationale, its scope | Which fact ids this run added or changed |
| A correction and its evidence | That a default was taken rather than chosen |
| A retirement and its reason | An open question, and what would resolve it |
| A capability verified or demoted | A conflict, and what the decision is between |

---

## Profile changes made this run

Every fact this run touched, and how. The profile holds the content; this is the audit trail.

| Fact id | Move | What it covers | Why |
|---|---|---|---|
| | `add` / `confirm` / `supersede` / `retire` | | |

## Verified against the environment

Facts re-checked rather than asked about. This table is the measure of whether the survey did its job.

| Fact id | How it was verified | Result |
|---|---|---|
| | | `confirmed` / `superseded` |

## Defaults taken

No preference was expressed and a default was applied. **Kept separate from choices on purpose** — the approver reads these harder, and re-entry revisits them cheaply.

| Slot | Default applied | Source of the default | Fact id written |
|---|---|---|---|

## Open questions

| Question | Blocking | What would resolve it | Status |
|---|---|---|---|

Blocking questions must all be closed before the gate. Non-blocking ones become deferrals with a revisit trigger.

## Conflicts

**Blocks the gate until resolved.** Never averaged — a midpoint between two real positions is a third position nobody holds.

| Element or facts | The incompatibility | What the decision is between | Resolution |
|---|---|---|---|

## Divergences from the blueprint

Recorded here for the gate, and **written to the profile** as durable facts — the reason for departing from a blueprint outlives this run, and the next revision of that blueprint needs to know about it.

| Element | Blueprint's position | What we do instead | Why | Fact id |
|---|---|---|---|---|

## Questions asked

| | |
|---|---|
| Questions asked of a person | `<n>` |
| Facts settled from the profile | `<n>` |
| Facts settled by verification | `<n>` |

A rising question count across runs against the same profile means the survey is not doing its job. A second adoption against a mature profile should ask almost nothing.
