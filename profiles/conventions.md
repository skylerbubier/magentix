*[Magentix](../README.md) › [Profiles](README.md) › Conventions*

# Profile Conventions

The [user profile](user/README.md) and the [project profile](project/README.md) were designed
independently, for different subjects, and turned out structurally near-identical. This document
names the contract they already share once, so both collections can point at it instead of
restating it, and so a third collection can be built to the same contract rather than invented
from scratch.

Everything below is common to both collections today. Where they diverge, see **Deltas**.

## Atomic records

The unit of either collection is one record per file: one criterion, one fact. A record is never
split across files and a file never holds more than one record — that is what lets a single record
be dated, sourced, superseded, and retired independently of every other one.

Every record carries a `kind` discriminator in its governance header (`user-criterion` or
`project-fact`). `kind` is what keeps a collection's files inert to anything not looking for them,
and what lets a generator select correctly if these files ever sit alongside other metadata-bearing
documents.

## The governance header

Every record file opens with a small header, present in both collections:

- `kind` — the discriminator
- `owner` — a named person the record belongs to (the project profile also adds `project`, since
  its records are plural across projects)
- a confirmation/verification date — `last_confirmed` in the user profile, `last_verified` in the
  project profile

## Shared record fields

Beneath the header, both formats carry the same core fields:

| Field | Purpose |
|---|---|
| `id` | Stable identifier; the filename |
| `category` | What kind of record this is, for selection without reading everything |
| `statement` | The record's one fact, stated concretely enough to be checked |
| `rationale` | Why it is true, so a generator can act correctly on situations the statement does not literally name |
| `supersedes` | The id this record replaces, or null |
| `status` | `active \| superseded \| retired` |
| `retired_reason` | Required whenever `status` is `retired` |

## Lifecycle moves

Both collections change through the same shape of move, named slightly differently:

| Move | User profile | Project profile |
|---|---|---|
| A new record enters | Add | Add |
| An existing record is re-checked and still holds | Confirm | Verify |
| The fact changed | Supersede | Supersede |
| The fact stopped applying | Retire | Retire |

The project profile adds a fifth move, **re-verify**, because most of its records are observable —
an interval lapsing there means re-running the check, not asking a person.

The rule is identical either way: **nothing is edited in place except the date (and, at project
scope, the verified value), and nothing is ever deleted.** A superseded or retired record stays on
disk. That is what lets a generated artifact trace back to the exact record version that produced
it.

## Staleness and the generated index

Both collections age their categories at different rates and declare a **per-category interval**
rather than one interval for the whole collection.

Both also generate an `INDEX.yaml` that is **never hand-edited** — it is rebuilt from the records
and functions as a router, not a copy: it carries no `statement` and no `rationale`, only what a
generator needs to select a slice and load just those files. Both index shapes carry the same kinds
of content:

- routing metadata per record (id, category, and enough of the record's own fields to select on)
- a **stale list** — records whose confirmation/verification has lapsed past their category's
  interval
- a **conflicts/collisions list** — the user profile lists contradictory same-scope criteria; the
  project profile lists both fact conflicts and cross-practice path collisions
- the **intervals** table itself, so the index is self-describing

## The harness-binding pattern

Both collections confine all agent-tooling knowledge to exactly one file — `harness/bindings.yaml`
— rather than letting any record mention a tool.

That file, in both collections, holds:

- `slots` — the named places a tool reads from or writes to
- `capabilities` — what the tool actually supports at each slot
- `precedence` — how the tool resolves multiple context sources, in its own terms
- a `retired[]` list — harnesses no longer in use, kept rather than deleted, per the same
  never-delete rule as everything else

The hard rule this pattern exists to enforce is absolute in both collections: **no record anywhere
else names a tool, a config path, or a product feature.** Migrating tooling is an edit to this one
file plus a regeneration, and it touches no record.

## Deltas: what each collection adds

| User profile adds | Project profile adds |
|---|---|
| `rank` (priority category only) | `verification{method, how, last_result}` |
| `weight` (`default \| strong \| firm`) | `authority` (who can change the fact, vs. who owns it) |
| `stability` (`provisional \| calibrating \| stable`) | The capability/`fails_closed` extension to the `capability` category |
| `source` / `evidence` | Plurality across projects (a cross-project index, not one collection) |
| `scope` (`global \| domain \| task \| stakes`) | `practices.yaml` and path ownership across practices |
| — | `risk_tier` |

## The two category enums, verbatim

| User profile ([`01-criterion-format.md`](user/01-criterion-format.md)) | Project profile ([`01-fact-format.md`](project/01-fact-format.md)) |
|---|---|
| `identity` | `identity` |
| `priority` | `stack` |
| `authority` | `interface` |
| `interaction` | `capability` |
| `context` | `authority` |
| `non-goal` | `convention` |
| `correction` | `constraint` |
| `harness` | `cadence` |
| — | `harness` |

## Adding a third collection

A new collection — a team profile, say — conforms to this contract by supplying:

1. **A discriminating `kind`** unique to its records.
2. **A governance header** with an owner and a confirmation/verification date.
3. **The shared record fields** — `id`, `category`, `statement`, `rationale`, `supersedes`,
   `status`, and `retired_reason` where retired.
4. **Its own category enum**, sized to what a generator needs to select without reading everything.
5. **Its own move set**, built from add / confirm-or-verify / supersede / retire, with the same
   never-edit, never-delete rule.
6. **A generated, never-hand-edited `INDEX.yaml`** carrying routing metadata, a stale list, a
   conflicts list, and its category intervals.
7. **A single harness-binding file**, if the collection's records could ever be tempted to name a
   tool — with `slots`, `capabilities`, `precedence`, and a `retired[]` list, and the same absolute
   rule that no other record names a tool.

What it adds beyond that — its own deltas — is its own design, recorded in its own documents the
way the table above records these two.
