*[Magentix](../../README.md) › [Profiles](../README.md) › [User profile](README.md) › Collection*

# The Collection

How criteria are organized, indexed, and kept honest as they accumulate.

---

## Layout

```
user-profile/
  INDEX.yaml                 # generated — the map a generator reads first
  criteria/
    identity/UC-0001.yaml
    priority/UC-0004.yaml
    authority/UC-0012.yaml
    interaction/UC-0031.yaml
    context/UC-0020.yaml
    non-goals/UC-0027.yaml
    corrections/UC-0038.yaml
  harness/
    bindings.yaml            # the only agent-specific file in the collection
  CHANGELOG.md               # append-only: what changed, when, why
```

One criterion per file. Filenames are ids, so a criterion can be referenced by a generated artifact and found again later without a search.

## The index

`INDEX.yaml` is generated from the criteria and never hand-edited. It exists so a generator can select what it needs without reading every file — the direct token cost of the whole design.

```yaml
generated_at: <YYYY-MM-DD>
count: { active: 34, superseded: 8, retired: 3 }
criteria:
  - id: UC-0031
    category: interaction
    scope: stakes:high
    weight: firm
    stability: stable
    source: corrected
    last_confirmed: 2026-09-01
    status: active
    path: criteria/interaction/UC-0031.yaml
stale:            # last_confirmed older than the category's interval
  - UC-0018
  - UC-0022
conflicts:        # same scope, contradictory statements — human resolves
  - [UC-0009, UC-0044]
```

The index carries no `statement` and no `rationale`. It is a router: a generator reads it, selects the slice matching its scope and category, and loads only those files.

---

## Confirmation intervals

Staleness is per category, because facts age at different rates.

| Category | Interval | Why |
|---|---|---|
| `identity` | 12 months | Changes with a role change, rarely otherwise |
| `priority` | 6 months | Shifts with what the person is responsible for |
| `authority` | 6 months | Shifts with trust and with role |
| `interaction` | 3 months while `calibrating`, 12 once `stable` | The whole point is that it tunes |
| `context` | 12 months | Durable, but a stack anchor goes stale silently |
| `non-goal` | 12 months | Stable, and cheap to re-confirm |
| `correction` | 6 months | Either it has become permanent or it stopped mattering |
| `harness` | On any tooling change | Not time-based — event-based |

A lapsed interval is not an error. It is a prompt: ask about this one before trusting it, and re-confirm or supersede.

**A stale criterion is still used.** The alternative — ignoring it — throws away the best information available in favor of nothing. Staleness changes how much an agent should volunteer that it is acting on an old fact, not whether it acts.

---

## The four moves

| Move | What changes | What is preserved |
|---|---|---|
| **Add** | A new file, next id | — |
| **Confirm** | `last_confirmed` only | Everything else, byte for byte |
| **Supersede** | Old file `status: superseded`; new file with `supersedes:` pointing at it | The old file stays, forever |
| **Retire** | `status: retired` plus `retired_reason` | The file stays |

Nothing is edited in place except a confirmation date. Nothing is deleted.

Two reasons this matters more than it looks. A generated artifact traces to the exact criterion version that produced it, so a surprising instruction can always be explained. And a retired criterion is the record that somebody already considered this and decided against it — deleting it means the same suggestion gets made again next year.

## Promotion

Facts enter this collection from three directions, and most of the good ones arrive sideways rather than from an interview.

**A correction becomes a criterion when it recurs.** The first time somebody corrects an agent, that is a moment. The second time, it is a pattern. The third time it should already have been written down. `source: corrected` with the `evidence` line is the highest-value content in the collection precisely because it is revealed rather than reported.

**A `provisional` criterion becomes `calibrating` once real work has tested it**, and `stable` once it has survived a confirmation cycle without changing.

**An `inferred` criterion must be confirmed before it counts.** Until then it is a guess, and an agent acting on it should say that it is acting on a guess. An inference that is never confirmed is retired, not promoted.

## Promotion out

Not everything that arrives belongs here. Three things get promoted **out** of the collection, and doing so is a good outcome rather than a failure:

| What it turns out to be | Where it goes |
|---|---|
| A project fact, not a personal one | A [project profile](../project/README.md) |
| Something a team is also bound by | Team or project scope, never here |
| Something a mechanism could check | The mechanism. This collection then points at it, or drops it entirely |

The third is the one worth watching for. A preference that can be turned into a check should become one, because a check holds and a criterion only asks.

---

## Conflicts

Two active criteria at the same scope with contradictory statements are a conflict. The index lists them; nothing resolves them automatically.

| Situation | Resolution |
|---|---|
| Different scopes | Not a conflict. More specific wins |
| Same scope, one `corrected` and one `stated` | Resolve toward the correction; supersede the stated one |
| Same scope, both `stated` | The person decides. Never average them |
| Same scope, one stale and one fresh | Ask. A lapsed date is not a tiebreaker on its own |

Averaging is the failure mode to avoid. A midpoint between two real preferences is a third preference nobody holds, and it produces behavior that is wrong in both of the situations the originals covered.

## Contradiction by behavior

A criterion the person repeatedly acts against is a signal, not a rule to enforce harder. Three possibilities, and they need different responses:

- **The criterion was aspirational.** They described who they want to be. Supersede it with what is actually true.
- **The scope is wrong.** It holds in some situations and not others; split it by scope.
- **It has stopped being true.** Supersede it.

None of those are resolved by an agent insisting on the criterion. Surface the mismatch and let the person say which it is.

---

## Size

A useful profile is small. Rough shape at maturity: on the order of thirty to fifty active criteria, weighted toward `interaction` and `priority`, with `identity` and `context` in single digits.

Two failure signals:

- **Under ten active criteria after months of use** means corrections are not being captured. The collection is being treated as a form to fill in rather than something that accumulates.
- **Over a hundred** means facts are being recorded that a generator will never select, or that project facts are leaking in. Prune by asking which criteria have ever been loaded.

The bar for a new criterion: would an agent get this wrong without it, and is it durable? Both, or it does not belong.
