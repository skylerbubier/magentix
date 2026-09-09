*[Magentix](../../README.md) › [Blueprints](../README.md) › AI-SDLC*

# AI-SDLC

The AI-SDLC blueprint is a two-phase, spec-driven delivery pipeline built on
two invariants: the **mutability inversion** — while intent is uncertain the
specification is mutable and the code is read-only, and the moment intent is
settled that inverts, so there is never a window where both are editable —
and **every hop between planes is a script, not a model**, so the chain from
intent to code is a compilation pipeline with a typed, diffable intermediate
representation rather than prose a model re-lowers differently each time. The
shape that follows is Phase 1 **DEFINE** (explore intent, edit the spec, one
human gate) → **FREEZE** (a script snapshots the spec and generates a
diff) → Phase 2 **BUILD** (plan against the diff, implement within a
declared write-set, triage blockers by set arithmetic) → Phase 3 **PROMOTE**
(merge makes target the new current, and the cycle can run again).

## In this blueprint

- [`overview.md`](overview.md) — the two invariants, the phase flow, what's deterministic versus judged, adoption order, and known limits
- [`subsystems.md`](subsystems.md) — the full reference: 21 subsystems (S1–S21), who owns each, what it reads/writes, and what enforces it
- [`spec-recipe.md`](spec-recipe.md) — the docs-as-code artifact inventory: seven tiers, formats, diff tools, and the minimum viable spec

## Minimum viable spec

Do not build all seven tiers of the spec recipe before starting. Per
[`spec-recipe.md`](spec-recipe.md#minimum-viable-spec), a team can run this
design with six artifacts:

1. `principles/architecture.md`
2. `decisions/` with front-matter (even starting with three ADRs)
3. `contracts/http/` — or whichever interface format the solution exposes
4. `contracts/db/` migrations
5. `behavior/{domain}/*.feature`
6. `operations/flags.yaml`

`overview.md`'s own [adoption order](overview.md#adoption-order) agrees: the
spec tree and spec validation in CI are steps 1 and 2, and steps 1–4 (adding
the freeze, manifest, and hooks) are "a working system on their own" —
pilot on one service, one team, three or four changes, before going further.

## Profile pairing

This blueprint pairs with a **project profile**
([`../../profiles/project/README.md`](../../profiles/project/README.md)):
the project's tooling, gates, and capability inventory are what determine
whether an element the blueprint calls `enforced` can actually be enforced
here, or must be demoted to `asserted` on the record.

## When this is too much

The overview is explicit about its own limits, and they are the honest
answer to "do we need all of this":

- **Not everything is diffable.** UX judgment, architectural taste, and "is
  this the right product decision" have no grammar and stay in the
  conversation plane and the human gate — this design doesn't pretend
  otherwise.
- **A frozen spec guarantees the code matches the spec, not that the spec is
  right.** Bad specs still produce bad software, just faster; watch the
  Class C rate as the early warning.
- **A single human gate becomes the bottleneck if intake outruns it** —
  relevant the moment any automated source can open a change.
- **Cross-change concurrency is out of scope.** Two changes freezing
  overlapping spec artifacts will conflict at promotion; teams running many
  parallel changes need more than the simple one-active-change-per-artifact
  rule this design states.
- **There is no maintain stage.** The design stops at promotion; feeding
  production findings back into intake is a deliberate next increment, not
  part of the core.

Per the adoption order, the full design is not a single decision — steps 1–4
are a working system on their own, and steps 5–8 (plan traceability, blocker
triage, promotion, and the review/telemetry refinements) are worth adding
only once that smaller system has run for real changes. A team that only
needs steps 1–2 (a validated spec tree in CI) has still adopted something
real, not a partial failure to adopt the rest.
