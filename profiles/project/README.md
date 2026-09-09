*[Magentix](../../README.md) › [Profiles](../README.md) › Project profile*

# The Project Profile — Architecture

**Companion documents:** [01-fact-format.md](01-fact-format.md) (the unit) · [02-collection.md](02-collection.md) (many projects, many practices, path ownership) · [03-capability-inventory.md](03-capability-inventory.md) (what can actually be enforced here) · [04-harness-binding.md](04-harness-binding.md) (the one agent-specific seam) · [project-profile.excalidraw](../../docs/diagrams/project-profile.excalidraw) (the diagram)

**In this collection:**

- [01-fact-format.md](01-fact-format.md) — the schema for a single fact: fields, categories, and what a fact must never contain.
- [02-collection.md](02-collection.md) — layout, the cross-project index, verification intervals, the four moves plus re-verify, and path ownership.
- [03-capability-inventory.md](03-capability-inventory.md) — what counts as a capability, the advisory trap, and the gap list.
- [04-harness-binding.md](04-harness-binding.md) — the one file where agent tooling may be named.
- [templates/](templates/) — the scaffold to copy: `INDEX.yaml`, `bindings.yaml`, `fact.yaml`, `capability.yaml`, and `practices.yaml`.

---

## What this is

A durable, evolving collection of **what is true about one project** as a thing that work gets delivered through: what it is, what it is built on, what it exposes, who approves what, what its tooling can actually check, and what it is constrained by.

It is not a set of agent instructions, and it is not a specification of the software. It is the source that project-scoped agent artifacts are generated from.

## Plural by construction

A person works across several projects. A team almost always runs several delivery contexts at once — a service with a compliance gate and a scratch tool with none, a monolith mid-migration and the two services carved out of it.

So this collection is a set, not a document. One profile per project, an index across them, and each profile independently owned and independently stale-able. Any design that assumes one delivery context per team is describing a team with one project.

There is a second multiplicity underneath that one: **a single project commonly adopts more than one practice.** A delivery pipeline, a review standard, and an incident-response routine can all be live in the same repository, each generating its own artifacts. That is normal, and it is why this collection carries a practice registry and a path-ownership rule rather than assuming a project has one generated artifact set.

## Facts, not documents

The unit is a single **fact**: one true statement about the project, in its own file, with its own owner, its own date, and — where it is observable — a record of how it was last verified.

The reasoning is the same as for any profile: a blueprint change should re-render artifacts, never re-interview a team. But two things are different here, and they shape the format:

**Project facts are mostly observable.** A person's priorities can only be asked about. A project's test command, its CI checks, its CODEOWNERS reality, and its dependency set can all be read. So facts here carry a verification method and a verification date, and a fact that could be checked but was not is weaker than one that was.

**Project facts have owners who are not the author.** A profile is written by whoever set it up; the facts in it belong to different people. A gate belongs to whoever staffs it. A constraint belongs to whoever imposed it. The format records that, because a fact whose owner cannot be named is usually a guess.

## What belongs here, and what does not

| Not this | Because | Where it goes |
|---|---|---|
| Generated agent instructions | This is the source, not the output | Materialized artifacts, regenerable |
| Anything about a person's preferences | Personal scope, different lifecycle, different owner | A [user profile](../user/README.md) — a separate collection, deliberately |
| The project's specification | A profile describes the delivery context, not the product | The project's own spec artifacts |
| A convention's text | The copy here would drift from the real one | A pointer to where the convention actually lives |
| Anything a check already enforces | Same reason | A capability entry pointing at the check |
| Session or task state | Not durable | The agent's own working state |

The convention rule is the one most often broken. When a repository already states its own build steps or layering rules, this collection records **that the statement exists and where** — never what it says. A profile holding a second copy of a convention is holding the copy nobody will update.

---

## Independence

**Independent of any blueprint.** No fact is shaped by a particular practice's vocabulary or file layout. If reading this format tells you which delivery practice is in use, the separation has failed.

**Independent of the [user profile](../user/README.md).** Two collections, two formats, two owners, two lifecycles. That is the mechanism that keeps personal preference out of shared files: a person's criteria and a project's facts cannot accidentally merge when they were never in the same collection. It also handles the ordinary case cleanly — several people work on one project, each carrying their own personal profile, all sharing one project profile, and the artifacts generated from each stay in their own scope.

**Independent of agent tooling.** Every fact is portable. Which agent tooling the repository uses is confined to one bounded section — see [04-harness-binding.md](04-harness-binding.md).

## Nothing here enforces anything either

This collection *records* what a project can enforce. It does not itself enforce.

That distinction is what makes the capability inventory the most valuable part of the whole thing. A generator deciding whether an artifact can be a real control or only a request needs a truthful answer about this environment, and this is where that answer lives. A capability recorded as available but never verified is exactly how a practice ends up believing it holds a control it does not hold.

## Governance

Every fact file opens with:

```yaml
kind: project-fact
project: <project id>
owner: <who this fact belongs to — a person, not a group>
last_verified: <YYYY-MM-DD>
```

`kind` keeps these files inert to anything not looking for them. `project` makes a fact file self-identifying if it is ever moved or quoted. `owner` is one person, because a fact whose owner is "the team" has nobody to ask when it goes stale.

## How it evolves

The same four moves as any profile — add, verify, supersede, retire — with one addition specific to project scope: **re-verify**. An observable fact whose verification has lapsed gets checked against reality rather than asked about, and reality usually answers faster than a person does.

Facts also arrive differently here. Most enter by observation during a survey, not by interview. The useful conversation is about the small number that cannot be read: risk tier, who really approves what, and which constraints are actually binding rather than assumed.

Full rules in [02-collection.md](02-collection.md).

---

## Where it lives

The collection describes shared context, so it lives where the team can see and change it — typically version-controlled, either alongside the projects it describes or in one place that describes all of them.

Both placements work and they trade off differently. Keeping a profile in its own repository puts it next to what it describes and makes ownership obvious. Keeping all profiles in one collection makes the index real, makes cross-project questions answerable, and is the only way path-ownership collisions across projects get caught. Pick one and record which; a collection split between both conventions will lose facts.

## Known limits

- **A project's reality drifts faster than the profile.** Verification dates make that visible; they do not prevent it. A profile is only as good as its last survey.
- **Ownership is often genuinely unclear.** The format requires a named owner, and the honest response when there is not one is to record the fact as unowned and treat it as unverified — not to invent an owner.
- **Capability is easy to overstate.** A pipeline that *could* run a check is not a check. [03-capability-inventory.md](03-capability-inventory.md) exists because this is the failure that matters most.
- **Several practices in one project will contend for paths.** The registry detects collisions; resolving one is a human decision about which practice owns what.
- **Cross-project consistency is not modeled.** Each profile is independent. A team wanting the same practice everywhere gets that by adopting the same blueprint repeatedly, not by a shared profile — and nothing here detects that two profiles have drifted apart.
