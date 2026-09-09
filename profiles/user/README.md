*[Magentix](../../README.md) › [Profiles](../README.md) › User profile*

# The User Profile — Architecture

**Companion documents:** [01-criterion-format.md](01-criterion-format.md) (the unit) · [02-collection.md](02-collection.md) (how it is organized and how it evolves) · [03-harness-binding.md](03-harness-binding.md) (the one agent-specific seam) · [user-profile.excalidraw](../../docs/diagrams/user-profile.excalidraw) (the diagram)

**In this collection:**

- [01-criterion-format.md](01-criterion-format.md) — the schema for a single criterion: fields, categories, and what a criterion must never contain.
- [02-collection.md](02-collection.md) — layout, the generated index, confirmation intervals, the four moves, and conflict handling.
- [03-harness-binding.md](03-harness-binding.md) — the one file where agent tooling may be named.
- [templates/](templates/) — the scaffold to copy: `INDEX.yaml`, `bindings.yaml`, and `criterion.yaml`.

---

## What this is

A durable, evolving collection of **what is true about one person** as somebody an agent works for: who they are, what they optimize for, what they delegate, how they want to be worked with, and what they never want optimized for.

It is not a set of agent instructions. It is the source those are generated from.

That distinction is the whole design. Instructions are shaped by whatever best practice is currently believed to be right, and that belief changes every few months as agent capability changes. What a person is actually like changes far more slowly. Storing the two together means re-deriving the slow thing every time the fast thing moves — which in practice means re-interviewing somebody about their own preferences because a template was restructured.

## Criteria, not documents

The unit of this collection is a single **criterion**: one fact about the person, in its own file, with its own date, its own source, and its own rationale.

That choice is doing five specific jobs:

1. **A blueprint change re-renders; it never re-elicits.** When the practice being followed changes shape, the criteria are unchanged and the generated documents are rebuilt from them. Nobody gets asked anything twice.
2. **The same fact serves different shapes.** One practice wants verbosity expressed as a table by situation; another wants it as a paragraph; a third wants it as a machine-readable setting. All three render from one criterion.
3. **Facts can be dated individually.** A document can only be stale as a whole. A criterion can be individually re-confirmed, so a review asks about the six things that have gone stale rather than re-reading everything.
4. **Re-elicitation becomes selective.** Only criteria whose confirmation has lapsed, or whose rationale has been contradicted, come back into a conversation.
5. **Review happens at fact granularity.** "Do I still believe this?" is answerable. "Is this document still right?" is not.

The cost is that a criterion is a poor thing to read. Nobody browses a profile — they read the artifacts generated from it. That is the correct division of labor, and it is why this collection ships no prose document intended for human reading beyond the ones in this folder.

## What belongs here, and what does not

**Belongs here** — anything true about this person that an agent would otherwise have to be told again in every new session, or would guess wrong.

**Does not belong here:**

| Not this | Because | Where it goes |
|---|---|---|
| Generated agent instructions | This collection is the source, not the output | Materialized artifacts, regenerable |
| Anything about a specific project | It is not durable about the person | A [project profile](../project/README.md) |
| Anything a team is also bound by | Personal scope only — this is the boundary that keeps a preference from becoming somebody else's rule | Team or project scope |
| A rule some mechanism enforces | The copy here would be the stale one | The mechanism, pointed at |
| Session state, running notes, task context | Not durable | The agent's own working state |
| An approval right belonging to someone else | This collection records what *this person* delegates, never what they may grant | The process or role that owns it |

## Nothing here enforces anything

Every criterion is a statement an agent is *asked* to honor. Nothing in this collection is checked by anything, and nothing in it can widen what an agent is permitted to do.

A criterion may be **more** conservative than an enforced control. It may never be less. Where a criterion and an enforced control disagree, the correct behavior is to stop at the control and say what stopped it — not to route around either one.

This is why the format has a `weight` field and why none of its values mean "enforced." A criterion marked as strongly held is still a request. Enforcement, where it exists at all, is a property of a generated artifact in an environment that can actually run a check — which is a different layer's problem.

---

## Independence

This collection is deliberately independent of three things.

**Independent of any blueprint.** No criterion is shaped by a particular practice's file layout, section headings, or vocabulary. A criterion states a fact; how that fact gets expressed is the generator's business. If reading this format tells you which best practice is in use, the separation has failed.

**Independent of the [project profile](../project/README.md).** Personal criteria and project facts are separate collections with separate formats, separate owners, and separate lifecycles. That is not tidiness — it is the mechanism that keeps a personal preference out of a file the whole team inherits. Two independent collections cannot accidentally merge; two sections of one collection eventually will.

**Independent of agent tooling.** Every criterion is portable. Which agent is in use, and where its configuration lives, is confined to one bounded section — see [03-harness-binding.md](03-harness-binding.md). Changing tools means editing that section and regenerating, with no criterion touched.

## Governance

Every file in the collection opens with:

```yaml
kind: user-criterion
owner: <the person this describes — always exactly one>
last_confirmed: <YYYY-MM-DD>
```

`kind` is the discriminator, and it earns its keep the moment these files sit anywhere alongside other metadata-bearing documents. Selecting on `kind: user-criterion` keeps every foreign frontmatter block inert and keeps these files invisible to anything not looking for them.

`owner` is always one person. A criterion with two owners is a team fact in the wrong collection.

`last_confirmed` is what makes staleness detectable. A criterion nobody has confirmed in a year is not wrong, but it is a thing to ask about before trusting it — and that is a different signal from one confirmed last week.

## How it evolves

The collection changes through four moves, and only four:

| Move | When |
|---|---|
| **Add** | A new fact was elicited, observed, or corrected into existence |
| **Confirm** | An existing criterion was re-checked and still holds; only the date changes |
| **Supersede** | The fact changed. The old criterion is marked superseded and kept; a new one replaces it |
| **Retire** | The fact stopped applying. Marked retired, with a reason, and kept |

Nothing is edited in place except a confirmation date, and nothing is deleted. That is what makes the collection's history readable, and it is what lets a generated artifact be traced back to the exact version of the fact that produced it.

Full rules — including how contradictions and promotions work — in [02-collection.md](02-collection.md).

---

## Where it lives

The collection is personal, so it lives wherever that person's durable files live — a private repo, a synced directory, a dotfiles tree. It does **not** live inside a project, because a project is shared and this is not.

One placement rule matters: the collection must be readable by an agent at the start of any session, and writable when a correction happens mid-task. A profile an agent can read but not correct decays into a stale document, because the moment where a preference becomes visible is exactly the moment where writing it down is inconvenient.

## Known limits

- **A person's stated preferences are not their revealed ones.** Criteria sourced from what somebody said are weaker evidence than criteria sourced from a correction they actually made. The format records the difference; it cannot resolve it.
- **Nobody wants to be interviewed.** This collection is only worth having if it is populated incrementally, mostly from corrections during real work. A first-sitting attempt to fill it completely will produce confident answers to questions the person has not actually thought about.
- **Staleness is detectable, wrongness is not.** A lapsed confirmation date is a signal to ask. A criterion that was confirmed last week and is nonetheless wrong looks identical to a correct one.
- **One person, one profile.** Someone who works in genuinely different modes — a maintainer role and a research role with different priorities — needs scoped criteria rather than two profiles, and scoping only partly captures it.
- **This collection cannot tell you it is being followed.** It records what someone wants. Whether the generated artifacts actually changed agent behavior is a question for the artifacts, not for this.
