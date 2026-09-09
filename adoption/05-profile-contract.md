*[Magentix](../README.md) › [Adoption engine](README.md)*

# The Profile Contract

How the loop consumes a profile collection it has never seen, in a format it does not know.

This is the mirror of [02-blueprint-contract.md](02-blueprint-contract.md). A blueprint says what *should* be true; a profile says what *is* true. The loop compiles one against the other.

---

## Why the situation is a collection, not a survey

An earlier shape of this design surveyed the situation fresh on every run and kept the result in the loop's own workspace. That works exactly once.

The problem shows up on the second adoption. A person who answered thirty questions to adopt one practice gets asked most of them again to adopt the next, because the answers lived in the first run's workspace. And when a blueprint is revised — which it will be, because blueprints track agent capability and that moves — the re-run re-interviews somebody about preferences that never changed.

So the situated half is its own durable collection, maintained independently, with its own lifecycle. That makes both inputs independently evolvable, which is the property the whole ecosystem rests on:

| Input | Evolves because | A change to it means |
|---|---|---|
| **Blueprint** | Agent capability changed, or the practice was improved | Re-render artifacts. Ask nobody anything |
| **Profile** | The person or project changed | Re-render artifacts. Re-read no blueprint |

Neither change requires the other to be revisited. That is the payoff, and it is only available because they are separate collections.

## The contract is one-sided, again

A profile collection is required to declare nothing. It has its own format, its own vocabulary, its own categories, and its own lifecycle rules, defined wherever it is defined.

The loop derives a structured **reading** and stores it in its own workspace. As with a blueprint, the shape of the reading is fixed and format-agnostic; the content is the profile's own detail.

One thing differs from the blueprint side, and it is important. **A blueprint is read-only, always. A profile is read-only in shape but writable in content** — through exactly one channel, described at the end of this document.

---

## The reading

```yaml
profile:
  source: <path>
  read_at: <YYYY-MM-DD>
  version_ref: <commit, date, or hash of what was read>
  describes: <a person | a project | something else, in the profile's own words>
  audience: individual | shared
  owner: <who this profile belongs to>
  index: <path to the profile's own index, if it has one>

facts:
  - id: <the profile's own id>
    category: <the profile's own category>
    statement: <the fact>
    detail: <values, names, numbers — whatever the profile carries>
    rationale: <why, where the profile records it>
    scope: <where the fact applies, in the profile's own terms>
    weight: <how strongly held, if the format expresses it>
    confidence: strong | moderate | weak      # normalized, see below
    freshness: fresh | stale | unverified     # normalized, see below
    authority: <who can change this, where the profile records it>
    source_ref: <file>

capabilities:                # only where the profile records them
  - mechanism: <the concrete thing>
    layer: <local | pipeline | platform | process | unknown>
    fails_closed: true | false
    bypass: <how, or none>
    covers: <…>
    does_not_cover: <…>
    verified: <YYYY-MM-DD, or null>

gaps:                        # controls wanted and unavailable
  - want: <…>
    why_unavailable: <…>
    nearest_available: <…>

harness:                     # the agent-specific seam
  slots:
    - id: <slot name in the profile's terms>
      path: <path>
      scope: personal | shared
      format: <…>
      writable: true | false
      fails_closed: true | false
  agent_state_path: <path — must be writable at all times>

open: [<what the profile does not say and must be elicited>]
conflicts: [<contradictions the profile itself flags>]
```

## Normalizing two fields

Profile formats express evidence quality and staleness differently. The loop normalizes both, because downstream decisions depend on them and nothing else can be assumed.

**`confidence`** — how much to trust the fact:

| Normalize to | From anything meaning |
|---|---|
| `strong` | Observed, measured, verified by test, or derived from a correction the person actually made |
| `moderate` | Stated by its owner, or read from configuration without being tested |
| `weak` | Inferred, assumed, or unverified — treat as a starting guess, and say so when acting on it |

**`freshness`** — whether it has been checked recently enough, per whatever interval the profile itself defines:

| Normalize to | Meaning |
|---|---|
| `fresh` | Within its own interval |
| `stale` | Interval lapsed. **Still used** — the alternative is discarding the best available information in favor of nothing. It changes how loudly the agent says it is acting on an old fact, and it makes the fact a candidate for re-elicitation |
| `unverified` | Never confirmed at all. Confirm before generating anything that depends on it |

A `weak` fact and a `stale` fact are different problems. Weak means the evidence was never good. Stale means it was good once. The first needs confirming; the second needs re-checking.

---

## Pairing: which profile goes with which blueprint

Derived, never hardcoded. The rule is scope matching.

| The blueprint's elements are authored by | Requires a profile whose | Produces artifacts in |
|---|---|---|
| `user` — an individual | `audience: individual` | personal slots only |
| `team` or `script` — shared ownership | `audience: shared` | shared slots |
| A mix | Both, each element drawing from the profile matching its authorship | Each in its own scope |

The mixed case is the one that needs care, and it is common. A delivery practice usually has team-authored elements and one or two the individual adopting it owns. Each element draws from the profile matching its authorship, and each materializes into a slot matching that profile's audience. An element authored by an individual never materializes into a shared slot, whatever the blueprint's location hint says.

That containment is now mechanical rather than a matter of care: the profile reading marks each harness slot `personal` or `shared`, and spec validation asserts that no individually-authored entry targets a shared one.

## When there is no profile

The first run against a fresh profile is a **bootstrap**, and it is the same loop with two differences:

1. **Elicitation is longer**, because nothing has been asked yet. The blueprint's minimum viable subset matters more than ever here — bootstrap only the facts that subset needs, and let the rest arrive from corrections during real work.
2. **Every elicited fact is written to the profile**, not to the run's workspace. The workspace holds the reading and the spec; the facts belong to the collection, which outlives both.

A bootstrap that ends with a populated profile and four materialized artifacts is a better outcome than one that ends with a complete profile and an abandoned session.

## The one write channel

Elicitation writes back. That is the only way a run changes a profile, and it uses the profile's own moves — add, confirm, supersede, retire — never a rewrite.

| During a run | Writes to the profile |
|---|---|
| A fact is elicited that the profile did not hold | **Add** |
| A fact is confirmed as still true | **Confirm** — the date only |
| Reality contradicts a recorded fact | **Supersede**, with what was observed as the new fact's evidence |
| A fact has stopped applying | **Retire**, with a reason |
| A capability could not be enforced as the blueprint expected | **Add** a capability fact and a gap entry — the demotion is evidence |

The last row is the loop closing on itself. A practice that had to demote an element from enforced to asserted has just learned something verified about the environment, and it belongs in the collection rather than only in that run's record.

Two rules on this channel:

**Never rewrite, never delete.** A run that reorganizes a profile has taken ownership of a collection it does not own, and the next run against a different blueprint will find a profile shaped by the last practice adopted.

**Never write a fact the blueprint invented.** A profile holds facts about the person or project. A blueprint's opinion about what should be true is not a fact about anything, and a profile polluted with normative content stops being an independent input.

---

## Profiles that resist

| Situation | Handling |
|---|---|
| **Thin profile** — a handful of facts | Most blueprint slots become elicitation targets. Bootstrap the minimum subset, defer the rest with triggers |
| **No capability information** | Treat every capability as unknown. **Every enforced element demotes** until something is verified. Pessimism is the only safe default here |
| **Stale throughout** | Do not silently regenerate against it. Re-verify what is cheap to re-verify — an observable fact recording how it was observed costs one command — and ask about the rest |
| **Internally contradictory** | The profile's own conflict list is an input, not a problem to solve. Contradictions at the same scope are a human decision |
| **No harness slots recorded** | The blueprint's location hints cannot be resolved. This blocks materialization, not drafting — elicit the slots |
| **Facts whose authority sits outside the adopter** | The adopter cannot approve a spec entry depending on them. Name the real authority in the spec and gate on them |
| **Two profiles offered for one run** | Legitimate in the mixed case. Each element draws from the one matching its authorship; a fact present in both is a conflict, not a merge |

---

## What the loop must never do to a profile

- **Reshape it to suit a blueprint.** The profile's format belongs to the profile.
- **Copy blueprint content into it.** Normative material is not a fact about anyone.
- **Treat a stale fact as absent.** Stale is information; absent is not.
- **Treat an unverified capability as available.** This is the one place where guessing optimistically produces a practice that lies about itself.
- **Merge two profiles.** They have separate owners and separate lifecycles, and merging destroys both.
- **Leave an elicited fact in the run's workspace.** The next run would ask again, which is the failure this whole contract exists to prevent.
