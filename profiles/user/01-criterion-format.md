*[Magentix](../../README.md) › [Profiles](../README.md) › [User profile](README.md) › Criterion format*

# The Criterion Format

One fact, one file. This is the only unit in the collection.

---

## The schema

```yaml
---
kind: user-criterion
owner: <the person this describes>
last_confirmed: <YYYY-MM-DD>
---
id: UC-0042
category: <see categories below>
statement: >
  <One fact, one sentence. Written so that an agent's behavior could be
   compared against it. Not a topic, not a heading, not a paragraph.>
rationale: >
  <Why this is true for this person. This field is what lets an agent
   generalize to a situation the statement does not literally cover,
   instead of pattern-matching the words.>
scope: <global | domain:<name> | task:<kind> | stakes:<low|high>>
weight: <default | strong | firm>
stability: <provisional | calibrating | stable>
source: <stated | observed | corrected | inferred>
evidence: <what happened that produced this, one line — required for corrected and inferred>
supersedes: <criterion id, or null>
status: <active | superseded | retired>
retired_reason: <required when status is retired>
```

## The fields that carry weight

### `statement` — one fact, behaviorally comparable

The test: could you look at a transcript and say whether an agent honored this? If not, it is a topic rather than a criterion.

| Not a criterion | A criterion |
|---|---|
| "Communication style" | "Lead with the outcome; put the reasoning after it, or omit it." |
| "Prefers concise output" | "Default to under 200 words unless the answer is a document I asked for." |
| "Cares about testing" | "A change is not reported as working until its test output is in the response." |

The left column is what a document produces. The right column is what a criterion produces, and it is the difference between an instruction an agent can follow and a heading it can only interpret.

### `rationale` — the field that makes criteria generalize

A statement covers the situations it names. A rationale covers the ones it does not.

"Default to under 200 words" tells an agent nothing about what to do with a 40-page report. "Because I read on a phone between meetings and scroll cost is what actually loses me" tells it exactly what to do — and tells it when the statement does not apply.

This field is also what makes review possible. Re-reading a statement produces "yes, still fine." Re-reading a rationale produces "that stopped being true when I changed jobs."

Skipping it is the single most common way this format degrades into a preferences file.

### `scope` — where the fact applies

| Value | Meaning |
|---|---|
| `global` | Always true |
| `domain:<name>` | True within a subject area |
| `task:<kind>` | True for a class of work — review, exploration, drafting, debugging |
| `stakes:<low\|high>` | True at a level of consequence |

Scope is what lets one person hold criteria that would otherwise contradict. Wanting terse output on routine work and dense evidence on risky work is not a contradiction; it is two criteria with different `stakes` scopes. Recording that as a single averaged preference produces behavior that is wrong in both cases.

More specific scope wins over less specific. Two criteria at the same scope that contradict are a conflict, and conflicts are resolved by the person, never averaged.

### `weight` — how strongly held, never how enforced

| Value | Meaning |
|---|---|
| `default` | A preference. Deviate when there is a reason, and say so |
| `strong` | Deviate only when the deviation is the point, and say so first |
| `firm` | Do not deviate without asking |

**None of these enforce anything.** `firm` is the strongest thing this collection can say, and it is still a request an agent is asked to honor. Nothing here is checked, and nothing here widens what an agent is permitted to do — a criterion may be more conservative than an enforced control, never less.

The reason `firm` exists is to distinguish a preference from a line, so that an agent asks instead of guessing. It is not a control, and any generated artifact that presents it as one has misrepresented this collection.

### `stability` — how settled

| Value | Meaning |
|---|---|
| `provisional` | Stated once, not yet tested against real work. Treat as a starting guess |
| `calibrating` | Being actively tuned. Expect it to change; re-confirm often |
| `stable` | Settled. Long confirmation interval |

This field exists because trust calibrates in both directions and at different rates for different facts. A verbosity preference is usually `calibrating` for a while and then settles. An identity fact is `stable` from the start.

### `source` and `evidence` — where the fact came from

| Value | Strength | Notes |
|---|---|---|
| `corrected` | Strongest | The person corrected an agent's actual behavior. Revealed, not stated |
| `observed` | Strong | Inferred from what they consistently do. `evidence` names what was observed |
| `stated` | Moderate | They said so. Real, but people describe their preferences imperfectly |
| `inferred` | Weakest | Derived from other criteria or from context. **Must be confirmed before it is treated as more than a guess** |

This ranking is load-bearing. A `stated` criterion and a `corrected` criterion that disagree resolve toward the correction, because what somebody fixes in the moment is better evidence than what they reported about themselves in the abstract.

`evidence` is required for `corrected` and `inferred`. Without it a correction is indistinguishable from an opinion, and an inference is indistinguishable from an invention.

---

## Categories

Categories exist so a generator can select the slice it needs without reading the whole collection. They describe **what kind of fact this is**, never which document it ends up in — that binding belongs to whatever practice is generating, and it changes when the practice changes.

| Category | Answers | Typically |
|---|---|---|
| `identity` | Who is this, and what can be assumed known? | `stable`, `global` |
| `priority` | What is being optimized for, and in what order? | `stable`; ordering matters, so these carry a rank |
| `authority` | What is delegated, and what is held back? | `stable`, `firm` |
| `interaction` | How should an agent behave in the moment? | `calibrating`, often scoped by stakes |
| `context` | What should never need re-explaining? | `stable`, often `domain`-scoped |
| `non-goal` | What should *not* be optimized for, even when it looks helpful? | `stable`, `strong` |
| `correction` | A recurring correction that has become durable | `source: corrected` |
| `harness` | Which agent tooling, and where its configuration lives | The only agent-specific category — see [03-harness-binding.md](03-harness-binding.md) |

Two notes.

**`priority` criteria carry a rank**, because their whole value is breaking ties without asking. An unranked set of priorities is a list of things somebody likes.

**`authority` describes only what this person delegates.** It never assigns an approval right that belongs to someone else, and nothing in it widens what is permitted. A criterion saying an agent may act alone on some class of work means: act freely up to whatever gate exists, then stop at the gate and say so.

---

## Two examples

A `corrected` interaction criterion, scoped by stakes:

```yaml
---
kind: user-criterion
owner: <person>
last_confirmed: 2026-09-01
---
id: UC-0031
category: interaction
statement: >
  On anything hard to reverse, state what will change and wait, even when
  the change itself is small.
rationale: >
  The cost of asking is one turn. The cost of a wrong irreversible action is
  an afternoon. Size of the change is not a proxy for the cost of getting it wrong.
scope: stakes:high
weight: firm
stability: stable
source: corrected
evidence: >
  Force-pushed a branch after being told to "clean up the history" — the
  instruction was about the working tree.
supersedes: null
status: active
```

A `priority` criterion carrying a rank:

```yaml
---
kind: user-criterion
owner: <person>
last_confirmed: 2026-09-01
---
id: UC-0004
category: priority
rank: 2
statement: >
  Prefer the change that is easiest to undo over the change that is smallest.
rationale: >
  Most of what gets built here is exploratory and will be revised. Reversibility
  is worth more than elegance at this stage, and this ordering is what should
  break ties without asking.
scope: global
weight: strong
stability: stable
source: stated
supersedes: null
status: active
```

---

## What a criterion must never contain

- **A section heading or a document structure.** That is a generated artifact's shape, not a fact.
- **A restatement of something a mechanism enforces.** Point at the mechanism instead; the copy here will be the stale one.
- **More than one fact.** Two facts in one file cannot be dated, sourced, superseded, or retired independently, which removes the entire reason for this format.
- **A project-specific detail.** Durable about the person, or it belongs in a [project profile](../project/README.md).
- **A claim about what someone else must approve.** This collection records delegation, not grants.
