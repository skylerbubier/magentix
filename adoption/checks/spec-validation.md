*[Magentix](../../README.md) › [Adoption engine](../README.md)*

# Spec Validation

Runs on `practice-spec.md` before the gate. **Any failure sends the run backward, never forward.**

Every assertion here is mechanical — it has a yes/no answer that does not require an opinion about whether the practice is good. That is the point: the gate should spend the approver's judgment on whether this is the right practice, not on whether the spec is internally sound.

---

## Traceability

| # | Assertion | Catches |
|---|---|---|
| T1 | Every entry traces to an element in the blueprint reading | Invented content |
| T2 | Every element in the reading has exactly one disposition | A silently dropped requirement |
| T3 | Every fact this run added or changed is reflected in at least one entry or an explicit deferral | An answer that was collected and then ignored |
| T4 | No entry traces to an element marked `not-applicable` | Contradictory dispositions |
| T5 | Every entry traces to at least one profile fact, or states that it needs none | Content with no situated basis — a generic scaffold with a citation |

T2 is the one that matters most. It is the direct analogue of a coverage check: an element with no disposition is a requirement that vanished between reading and spec, and nothing else in the loop will notice.

## Honesty

| # | Assertion | Catches |
|---|---|---|
| H1 | Every entry with `nature: enforced` names a mechanism that **fails closed** | A document pretending to be a control |
| H2 | Every enforced entry's mechanism appears as available in the profile's capability list | Enforcement assumed rather than confirmed |
| H3 | Every element the blueprint marked enforced is either enforced here or appears in the demotions table | A silent downgrade |
| H4 | No entry describes a control it does not install | The most common form of self-deception in adoption |
| H5 | No enforced entry rests on a capability whose `verified` date is null | Enforcement assumed from configuration rather than tested |
| H6 | Every entry depending on a `weak` or `unverified` fact says so in the entry | A practice built on a guess, presented as settled |
| H7 | Every demotion has a matching gap entry destined for the profile | A capability gap learned and then thrown away |

If H1 fails, the fix is never to delete the assertion. It is to install the mechanism or to demote the entry and record it.

## Completeness

| # | Assertion | Catches |
|---|---|---|
| C1 | **No entry's content contains an unfilled placeholder** — no `<…>`, `TODO`, `TBD`, `{{ }}`, or empty required section | The dead-template failure, mechanically |
| C2 | Every blocking question in the run record is closed | Proceeding on an unresolved unknown |
| C3 | No entry is marked `conflict` | A conflict silently generated around |
| C4 | Every entry names a review date, or an explicit `never` with a reason | Silent rot |
| C5 | Every entry names an owner who is a person, not a group | A review date belonging to nobody |
| C6 | Every entry an approver must sign is within that approver's authority per the profile | A gate nobody present can pass |

C1 is worth running literally, as a text scan, not as a judgment. It is the single highest-value assertion in this file, because the failure it catches is the most common way a best practice dies and the easiest one to miss by reading.

## Containment

| # | Assertion | Catches |
|---|---|---|
| N1 | `declared ∩ blueprint paths = ∅` | Writing the blueprint — invariant 1 |
| N2 | Every declared path is one the adopter owns or has authority over | Writing outside authority |
| N3 | No declared path appears in another live practice manifest | Two practices owning one file |
| N4 | No entry authored by an individual targets a harness slot the profile marks `shared` | Preference leaking into a shared file |
| N5 | `declared ∩ claimed_paths = ∅` | Two practices overwriting each other, silently and in both directions |
| N6 | No declared path lies outside the harness slots the profile records | An artifact written where nothing will read it |
| N7 | Every entry's content appears in full in the spec | A gap that would be improvised at write time |

## Consistency

| # | Assertion | Catches |
|---|---|---|
| S1 | No two entries state the same fact | A guaranteed future contradiction |
| S2 | Every `satisfied` disposition names what covers it, and that thing was observed or recorded | An assumed coverage |
| S3 | Every `partial` disposition extends an existing path rather than creating a parallel one | The one-home-per-fact violation |
| S4 | No entry restates something recorded as already stated elsewhere | The same, from the other direction |
| S5 | No entry contains a tool name that does not come from the profile's harness binding | Agent specifics leaking out of the one place they belong |
| S6 | No spec content was written into the profile, and no fact was rewritten | A collection reshaped by the last practice adopted |

## Blueprint fidelity

| # | Assertion | Catches |
|---|---|---|
| B1 | No entry violates one of the blueprint's own stated invariants | Adoption that breaks the thing it is adopting |
| B2 | No entry produces something on the blueprint's out-of-scope list | Overreach the blueprint explicitly warned about |
| B3 | If the blueprint names a minimum viable subset, every element in it is `absent → create`, `satisfied`, or explicitly justified | Adopting the optional parts and skipping the load-bearing ones |
| B4 | If the spec exceeds the blueprint's minimum viable subset, that is stated and justified | Adopting everything at once — the most common abandonment cause |

---

## Recording the result

```
Validated: <date>
Result:    <pass | fail>
Failed:    <assertion ids, one line each with what failed>
```

Three of these have no analogue in a design that surveys fresh each run, and they are the ones worth running first: **C1** (no unfilled placeholder), **H5** (no untested enforcement), and **N5** (no contended path). Each catches a failure that is invisible on reading and expensive to discover later.

A spec that fails validation does not go to the gate. Returning to drafting is cheap; an approver reviewing an unsound spec spends attention on the wrong thing and, worse, learns that the spec is not to be trusted.
