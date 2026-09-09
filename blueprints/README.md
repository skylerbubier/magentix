*[Magentix](../README.md) › Blueprints*

# Blueprints

A **blueprint** is a normative best-practice document: a proposal for how some
kind of work should be done, written in general terms, by an author who owes
nothing to this repo's machinery. In Magentix's model a blueprint is **read,
never written** — the loop that adopts it derives a structured reading from it
and stores that reading in its own workspace, but the blueprint itself is
never modified to fit. That is what lets Magentix adopt a third-party
best-practice document that has never heard of Magentix, including one
written before Magentix existed.

A blueprint alone does nothing. It is paired with a **profile** — the
situated, evolving truth about one person or one project — by the
**adoption engine**, which compiles the two into a working **practice**:
real files, at real paths, with a manifest and a review trigger. See
[`../adoption/README.md`](../adoption/README.md) for that loop in full; this
section only holds the blueprints themselves.

## The two blueprints shipped here

| Blueprint | Governs | Natural profile pairing | Minimum viable subset |
|---|---|---|---|
| [Agent Context Kit](agent-context-kit/README.md) | The preference layer: how an agent should work with one person — who they are, how they want to be worked with, what recurring work exists, and a running continuity log | A [user profile](../profiles/user/README.md) | All four documents — the blueprint states no smaller subset; it is already the minimum |
| [AI-SDLC](ai-sdlc/README.md) | A spec-driven delivery pipeline: a frozen specification plane, a diffed build plane, and the scripts and hooks that keep them from drifting apart | A [project profile](../profiles/project/README.md) | The six-artifact spec tree in [`ai-sdlc/spec-recipe.md`](ai-sdlc/spec-recipe.md#minimum-viable-spec), plus spec validation in CI |

Adopt the Agent Context Kit when the thing that needs stabilizing is the
*relationship* between one person and an agent — verbosity, trust, what gets
asked versus assumed — regardless of what project is in front of the agent.
Adopt the AI-SDLC when the thing that needs stabilizing is a *delivery
pipeline* for a project or a team, where "the agent quietly moved the
goalposts" is an actual failure mode worth engineering against. The two are
not mutually exclusive: a person working on a project that has adopted the
AI-SDLC still has their own Agent Context Kit for how they, personally, want
to be worked with.

## Blueprints are harness-agnostic

Neither blueprint in this section names a tool, a config file, or a product
feature. That is deliberate, not an oversight: a blueprint states what should
be true, and where a fact about tooling would otherwise leak in, it is left as
an open slot for the profile to fill instead. Tool names are quarantined to
exactly one place per profile — the harness binding — so that switching agent
tooling is a matter of editing that one section and regenerating, never of
re-reading or re-writing a blueprint:

- [`../profiles/user/03-harness-binding.md`](../profiles/user/03-harness-binding.md)
- [`../profiles/project/04-harness-binding.md`](../profiles/project/04-harness-binding.md)

A blueprint proposal that mentions a specific product by name has leaked a
profile-level concern upstream, and that is a defect in the blueprint, not a
detail to route around during adoption.

## Contributing a new blueprint

A blueprint does not need to know Magentix exists, follow a naming
convention, or carry any special front-matter — the contract in
[`../adoption/02-blueprint-contract.md`](../adoption/02-blueprint-contract.md)
is one-sided precisely so that any best-practice document can be adopted
as-is. What matters is whether the loop can derive a structured **reading**
from it into the schema at
[`../adoption/templates/blueprint-reading.yaml`](../adoption/templates/blueprint-reading.yaml).
A document is blueprint-shaped to the extent it yields:

- **Named elements** — the artifacts, checks, steps, roles, or cadences it
  proposes should exist, each with its own rationale, authorship, and
  enforcement nature (`asserted` or `enforced`, with a named mechanism if
  the latter)
- **Invariants** — its own load-bearing rules, stated precisely enough to
  become a spec-validation assertion
- **An out-of-scope list** — its own anti-patterns, known limits, or "what
  this is not" section; often the strongest constraint in the document and
  the most frequently skipped when adopting it
- **Slots** — the places it deliberately leaves to the adopter, rather than
  deciding for them
- **An adoption order** — its own sequencing, if it states one, rather than
  one invented by whoever adopts it
- **A minimum viable subset** — the smallest starting point it names, so
  that adopting it whole, at once, is a choice rather than the default

A document can be thin, narrative, or contradictory and still resist nothing
— those are handled cases, not failures, per the "blueprints that resist"
table in the contract. What a document *cannot* do and still be adopted
cleanly is assume a specific tool, restate something a check already
enforces, or fail to say what it is even attempting to be true for
(`audience: individual | team | org`). Those are the failure modes that turn
a reading into a generic scaffold with a citation rather than a practice that
carries the blueprint's actual detail into real files.
