*[Magentix](../README.md) › [Adoption engine](README.md)*

# Elicitation

Getting what is true out of a profile, an environment, and a human — in that order.

---

## The governing rule

**Never ask for what you can read, and never ask twice.**

There are three sources, and they are strictly ordered by cost:

1. **The profile** — already recorded, by an earlier run or an earlier correction. Free.
2. **The environment** — readable right now. Nearly free, and it verifies the profile at the same time.
3. **The human** — the only irreplaceable source, and the only one that runs out.

A question asked at level 3 that could have been answered at level 1 or 2 is the defining failure of this stage. Asking at level 1 is the worse of the two, because it tells the person their answers are not being kept.

The adopter's attention is the scarcest input in the loop and the only one that cannot be recovered later. Every question spent on something already recorded or readable is a question not spent on something only they know — and a long questionnaire that opens with things the agent could have checked itself is how an adoption session gets abandoned in the first ten minutes.

The order is not negotiable:

1. **Read the profile.** Facts already recorded need nothing.
2. **Verify against the environment.** A fact that records how it was observed costs one command to re-check, and the check either confirms it or supersedes it.
3. **Ask about the remainder.** The blueprint's slots neither of the above filled.

A well-run adoption of a dense blueprint should reach the gate on well under a dozen questions. A *second* adoption against the same profile should reach it on two or three, because the first one wrote its answers where they persist.

---

## The survey

Read before asking — and read the profile before reading the disk. What to look for, in rough priority:

| Look for | Because |
|---|---|
| Facts the profile already holds, and how fresh each is | Settles most slots before anything is read from disk |
| Files at the locations the blueprint's elements would occupy | Determines `Satisfied` / `Partial` / `Absent` before a single question |
| Templates present but unfilled | The clearest possible signal of a prior failed adoption, and the strongest thing to lead a conversation with |
| Checks, hooks, and pipeline configuration already running | Defines what can actually be `enforced` here, and what must be demoted |
| Existing conventions documents | The one-home-per-fact input. Anything stated here must be pointed at, never restated |
| Prior manifests from this loop | Turns a fresh adoption into a re-entry, which is a much shorter conversation |
| Paths already claimed by another live practice | A collision is a decision to surface, not an absence to fill |
| The harness and its capabilities | Whether an asserted element will actually load where the blueprint suggests putting it |
| Who owns the target locations | Determines whether the adopter can approve their own gate |

Record every observation with its state — present, stale, unfilled, absent — and record what could not be determined. An undeterminable observation becomes a question; an unrecorded one becomes an assumption nobody knows was made.

### Recorded versus observed versus stated

There are now three descriptions of reality in play, and every disagreement between them is worth more than any agreement.

**Profile says one thing, the environment shows another.** The environment wins. Supersede the fact, with the observation as the new fact's evidence. This is the cheapest correction available and it needs nobody's attention.

**Profile and environment agree, the adopter says something else.** Now it needs a person, and it is one of three things:

- **The record is stale in a way the environment cannot show** — a social fact, an intent, an approval that moved. Supersede it.
- **The practice was abandoned.** Do not regenerate it unchanged. Find out what made it not stick, because the blueprint is about to propose it again.
- **The adopter is describing an aspiration.** Worth adopting deliberately, but that is a new fact, not a correction to an existing one.

Surfacing the gap is the agent's job. Deciding which of the three it is belongs to the adopter.

---

## Asking

### Only slots

The legitimate targets are exactly: the blueprint's `slots`, its unresolved `open` items, and anything neither the profile nor the environment could settle. Anything else is already recorded, observable, or invented scope.

When an adopter volunteers something outside that set, record it — a durable fact belongs in the profile, and occasionally it reveals a `Conflict` the survey missed. But do not go looking.

### Order

Follow the blueprint's own adoption order where it states one, and its minimum-viable subset first where it names one. This has a real effect on the conversation: the adopter answers questions about the parts that will exist soonest, while the payoff is still concrete, rather than being asked about a tier they will not reach for months.

Where the blueprint states no order, work from most-depended-on to least. An element that others reference gets settled first, because its answer constrains theirs.

### Shape of a good question

- **Grounded in what was observed.** "Your global config already sets a default response style — should the practice point at that, or replace it?" beats "How verbose do you want agents to be?"
- **Carrying the blueprint's rationale**, so the adopter can judge whether it applies to them rather than guessing at what the element is for.
- **Offering a defensible default.** Most slots have one, from the blueprint or from what is already on disk. Proposing it and asking for a correction is faster than an open prompt, and it produces better answers.
- **Answerable in one pass.** A question requiring the adopter to go read something is a blocking question; mark it as such and move on rather than stalling the run.

### Shape of a bad question

- Anything answered by a file the agent can open.
- Anything the blueprint already decided. That is not a slot; that is the practice.
- Preference questions with no downstream effect on a spec entry. If no entry changes based on the answer, do not ask it.
- Bundling several slots into one question. The answer becomes ambiguous and the trace back to entries is lost.

---

## Recording

**Every answer is written to the profile, using the profile's own moves — add, confirm, supersede, retire.** Nothing of substance stays in the run's workspace, because a fact recorded there is a fact the next adoption asks for again.

The run keeps a thin record too, but only of what belongs to the run rather than to the collection:

| Belongs to the profile | Belongs to the run's record |
|---|---|
| The fact, its rationale, its scope | Which fact ids this run added or changed |
| A correction and its evidence | That a default was taken rather than chosen |
| A retirement and its reason | An open question, and what would resolve it |
| A capability verified or demoted | A conflict, and what the decision is between |

Every exchange is classified as one of the following before it is written anywhere:

| Recorded as | When | Must carry |
|---|---|---|
| **Decision** | The adopter chose | The choice, a one-line rationale, the slot it fills, the date |
| **Default taken** | No preference expressed; a default was applied | The default, its source (blueprint or observed), and that it was not explicitly chosen |
| **Open question** | Unresolved | Blocking or non-blocking, and what would resolve it |
| **Divergence** | The adopter chose against the blueprint | The choice, the blueprint's position, and the reason for departing |
| **Conflict** | A recorded fact is incompatible with an element, or two facts contradict | Both sides, and what a resolution would require |

Two of these carry weight later.

**Defaults taken must be distinguishable from decisions.** At the gate, an approver reads them differently — a default is a place to look harder. At re-entry, a default is cheap to revisit, while a decision has a reason attached that deserves respect.

**Divergences are the most valuable content produced here.** They are the answer to "why doesn't this match the blueprint?" a year later, and without them the practice looks like a sloppy copy rather than a deliberate adaptation. A divergence belongs in the profile, not in the run's notes — the reason for departing from a blueprint is durable, and the next revision of that blueprint needs to know about it.

---

## When to stop

Stop when every blocking slot is filled. Not when every question is answered.

Non-blocking gaps become deferrals with a revisit trigger and go into the spec as such. This matters because the alternative — pressing for completeness — is the second way an adoption session dies. The blueprint's minimum viable subset exists precisely so that a partial practice can be materialized, used, and extended, and the loop should reach the gate at that boundary rather than pushing past it.

A run that materializes four elements and defers eleven, with the eleven recorded and triggered, is a success. A run that elicited all fifteen and was abandoned before the gate produced nothing at all.

---

## Team practices

Where the audience is a team rather than an individual, three things change and nothing else does.

**Authorship gets specific.** "Team-authored" is not an owner. Each element needs a named owner, because the review cadence in the manifest has to have somebody to belong to.

**The gate-holder may not be in the room.** The person running the loop is often not the person who owns the target locations. The profile already records this: an artifact's approver is whoever holds authority over the facts it depends on and the slots it writes. Carry that into the spec. The agent cannot approve on their behalf, and neither can the person running the session.

**One project, several people, several profiles.** A shared project profile plus one personal profile per contributor is the normal arrangement, not an edge case. Shared artifacts generate from the project profile; each person's own artifacts generate from theirs. Nobody's preferences reach anybody else's files — and that falls out of the collections being separate rather than out of anyone being careful.

**Contested answers are conflicts, not averages.** When two people give different answers to the same slot, that is a `Conflict` disposition for a human to settle. Splitting the difference produces a practice nobody recognizes and everyone quietly ignores.
