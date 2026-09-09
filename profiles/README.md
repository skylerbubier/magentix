*[Magentix](../README.md) › Profiles*

# Profiles

A profile is the **situated fact** half of Magentix. Where a [blueprint](../blueprints/) states
what *should* be true — a best practice, portable across whoever adopts it — a profile states what
*is* true, for one specific person or one specific project. The [adoption engine](../adoption/)
compiles a blueprint against a profile to produce the actual artifacts an agent reads.

A profile is:

- **The source generated artifacts are rendered from** — never the artifact itself. Instructions,
  preference files, and checks get rebuilt from a profile whenever the practice generating them
  changes shape; the profile is what makes that re-derivation free of re-asking anyone anything.
- **Never the software's own spec.** A project profile describes the delivery context a project is
  worked through — its stack, its gates, what it can enforce — not what the software does. That
  belongs in the project's own spec artifacts.

## Two collections, one rule for where a fact goes

Magentix currently has two profile collections: a personal one and a project one. Both are covered
in depth in their own sections; [`conventions.md`](conventions.md) names the contract they share so
neither has to restate it and so a future collection can be built to the same shape.

The question that decides where a given fact belongs is simple: **is this durable about the person,
or durable about the delivery context?** A preference that would follow someone from project to
project belongs in their [user profile](user/README.md). A fact that stays true regardless of who
is working on the project belongs in its [project profile](project/README.md). Anything a team is
also bound by is never personal scope; anything about a specific piece of work is never durable
enough for a project profile.

## The two collections

| | Records | Owned by | Atomic unit / id prefix | Pairs with |
|---|---|---|---|---|
| **[User profile](user/README.md)** | What is true about one person: identity, priorities, delegated authority, interaction preferences, context, non-goals | That one person | A criterion — `UC-NNNN` | [`blueprints/agent-context-kit/`](../blueprints/agent-context-kit/) |
| **[Project profile](project/README.md)** | What is true about one project: identity, stack, interfaces, what it can actually enforce, authority, conventions, constraints, cadence | The project, with per-fact named owners | A fact — `PF-NNNN` | [`blueprints/ai-sdlc/`](../blueprints/ai-sdlc/) |

Both collections share the same underlying pattern — atomic records, a governance header, the same
four-or-five lifecycle moves, per-category staleness, a generated `INDEX.yaml` router, and a single
harness-binding file that confines all agent-tooling knowledge to one place. See
[`conventions.md`](conventions.md) for the shared contract, spelled out once.

## How a profile is consumed

Neither collection is read directly by an agent mid-task. The
[adoption engine](../adoption/05-profile-contract.md) reads whichever profile a run needs into a
normalized `profile-reading.yaml` in its own workspace — a format-agnostic shape that holds the
same kind of content regardless of which collection produced it, with evidence quality and
staleness normalized to a common vocabulary the loop can reason about.

That reading is not read-only in the way a blueprint reading is. Elicitation during a run can write
back to the profile it read — through exactly one channel, and always through the profile's own
moves (add, confirm-or-verify, supersede, retire), never as a rewrite. A run that reorganizes a
profile has taken ownership of a collection it does not own.

## Built incrementally, never in one sitting

Both collections make the same honest admission: nobody wants to be interviewed, and a first-sitting
attempt to fill either one produces confident answers to questions nobody actually thought about.
A profile is only worth having if it accumulates the way real work actually produces facts — mostly
from corrections and observations during real sessions, occasionally from a short, targeted
conversation about the handful of things that cannot be read or inferred. Treating either collection
as a form to fill in once is the most common way it ends up thin, wrong, or both.
