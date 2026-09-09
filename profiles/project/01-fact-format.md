*[Magentix](../../README.md) › [Profiles](../README.md) › [Project profile](README.md) › Fact format*

# The Fact Format

One true statement about the project, one file.

---

## The schema

```yaml
---
kind: project-fact
project: <project id>
owner: <one named person>
last_verified: <YYYY-MM-DD>
---
id: PF-0117
category: <see categories below>
statement: >
  <One fact, one sentence, stated concretely enough that it could be
   checked against the project.>
detail: <values, names, numbers, commands — whatever the fact actually is>
rationale: <why it is this way, where that is not obvious and matters>
verification:
  method: <observed | asserted | pointer | untestable>
  how: <the command, path, or artifact that establishes it — required for observed>
  last_result: <what it showed, one line>
authority: <who can change this fact, where different from owner>
supersedes: <fact id, or null>
status: <active | superseded | retired>
retired_reason: <required when status is retired>
```

## The fields that carry weight

### `statement` and `detail` — split on purpose

The statement is the durable shape of the fact. The detail is its current value.

```yaml
statement: >
  The full test suite is the gate for merge, and it runs from a single command.
detail:
  command: <the command>
  duration_p50: <minutes>
```

That split means a value change is an edit to `detail` plus a re-verification, while the statement — the thing artifacts were generated against — is unchanged. Merging the two produces a supersession every time a number moves, and a profile whose history is entirely version bumps.

### `verification` — the field that separates this from a [user profile](../user/README.md)

Most project facts are checkable. The format insists you say whether you checked.

| `method` | Meaning | Strength |
|---|---|---|
| `observed` | Read from the project. `how` names the command or path, `last_result` what it showed | Strongest |
| `pointer` | The fact is authoritatively stated elsewhere; this record points at it and holds no copy | Strong, and preferred wherever it applies |
| `asserted` | Somebody said so and it cannot be read | Moderate — the honest label for risk tier, intent, and social facts |
| `untestable` | No way to establish it, now or later | Weakest. Justify it or drop the fact |

The distinction that matters: **`observed` requires `how`.** A fact claiming to be observed without naming what observed it is an assertion wearing a stronger label, and it will be trusted more than it deserves for exactly as long as it takes to cause a problem.

`pointer` is the mechanism for one-home-per-fact across the collection boundary. Where the repository already states its own conventions, the profile records that the statement exists and where — never what it says.

### `authority` — who can change the fact, versus who watches it

`owner` is who keeps the fact current. `authority` is who can make it different. They diverge more often than not:

- A gate's owner is whoever notices when it breaks. Its authority is whoever staffs it.
- A constraint's owner is whoever recorded it. Its authority is whoever imposed it — often outside the team entirely.

This field is what stops a generated artifact from implying a team can decide something it cannot. Where authority sits outside the project, saying so here is a note, not a grant.

### `category`

Categories let a generator select a slice without reading the collection.

| Category | Answers | Usual verification |
|---|---|---|
| `identity` | What is this project, which repositories, where are its boundaries? | `observed` |
| `stack` | What is it built on — languages, frameworks, platform, runtime anchors? | `observed` |
| `interface` | What contracts does it expose and consume? | `observed` |
| `capability` | What can this environment actually check or block? | `observed`, and see [03-capability-inventory.md](03-capability-inventory.md) |
| `authority` | Which gates exist, who approves what, what is branch-protected? | `observed` or `asserted` |
| `convention` | What does this project already state about how work is done, and where? | `pointer`, always |
| `constraint` | What is non-negotiable — regulatory, contractual, platform, cost? | `asserted` |
| `cadence` | Release rhythm, environments, promotion order, risk tier | mixed |
| `harness` | Which agent tooling this repository carries | `observed` — see [04-harness-binding.md](04-harness-binding.md) |

Three notes.

**`convention` facts are always pointers.** A convention's text lives where the project states it. This collection records its existence, its location, and its owner, so a generator knows to point at it rather than restate it.

**`capability` facts are the highest-value entries in the collection**, because they decide whether a generated artifact can be a real control or only a request. They get their own document.

**`interface` facts are the cheapest blast-radius input available.** Knowing what a project exposes and consumes is what lets a change's reach be estimated without analysis.

---

## Two examples

An observed capability fact:

```yaml
---
kind: project-fact
project: <project id>
owner: <person>
last_verified: 2026-09-01
---
id: PF-0032
category: capability
statement: >
  Merge is blocked until the required status checks pass; the block is
  enforced by branch protection, not by convention.
detail:
  required_checks: [<check>, <check>]
  applies_to: <branch>
  admin_bypass: <true | false>
rationale: >
  This is the only mechanism in the project that fails closed. Anything a
  generated practice needs to actually hold has to route through it.
verification:
  method: observed
  how: <the command or settings path that shows the protection rule>
  last_result: both checks required, admin bypass disabled
authority: <who administers the repository>
supersedes: null
status: active
```

A convention fact, which is a pointer and holds no copy:

```yaml
---
kind: project-fact
project: <project id>
owner: <person>
last_verified: 2026-09-01
---
id: PF-0044
category: convention
statement: >
  Layering and dependency-direction rules for this project are stated in the
  repository and are authoritative there.
detail:
  location: <path in the repository>
  states: <one line on what it covers — NOT what it says>
rationale: >
  Recorded as a pointer so a generated artifact references it instead of
  restating it. A second copy here would be the one nobody updates.
verification:
  method: pointer
  how: <path>
  last_result: present, last modified <date>
authority: <who owns that document>
supersedes: null
status: active
```

---

## What a fact must never contain

- **A copy of something stated elsewhere.** Point at it. The copy here is the one that goes stale.
- **A person's preference.** Different collection, different owner, different lifecycle.
- **More than one fact.** Independent dating, verification, supersession, and retirement are the entire reason for this format.
- **A capability that has not been verified.** Overstated capability is how a practice comes to believe it holds a control it does not hold.
- **An `observed` label with no `how`.** That is an assertion claiming a strength it has not earned.
- **A claim of authority the project does not have.** Recording where authority sits is a note; it never grants anything.
