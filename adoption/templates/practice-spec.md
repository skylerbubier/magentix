*[Magentix](../../README.md) › [Adoption engine](../README.md)*

# Practice Spec — {practice-id}

**Status:** `draft | validated | approved | frozen`
**Blueprint:** `<source>` at `<version_ref>`
**Approver:** `<who>` · **Approved:** `<identity + timestamp, once approved>`

This is the reviewable object. It is not a plan to write files later — it contains the full content of everything that will be written. After approval it freezes, and materialization is transcription.

---

## What this changes

The diff against what exists today. Read this first at the gate.

| Target path | Change | Element | Nature |
|---|---|---|---|
| | `create` / `extend` / `refresh` / `leave` / `retire` | | `asserted` / `enforced` |

**Declared target set** — every path this spec will write, and nothing else may be written:

```
<path>
<path>
```

Must be disjoint from every path another live practice on this project already owns, and every path must lie inside a harness slot the profile records.

| Declared path | Harness slot | Slot scope | Already claimed by |
|---|---|---|---|
| | | `personal` / `shared` | `<practice-id>` / — |

---

## Element dispositions

Every element in the reading appears exactly once.

| Element | Disposition | Where it is covered / why not |
|---|---|---|
| | `satisfied` / `partial` / `absent` / `conflict` / `not-applicable` / `deferred` | |

Any row marked `conflict` blocks the gate.

---

## Entries

One per artifact that will exist. Repeat this block.

### ENTRY-NN · `<target path>`

| | |
|---|---|
| **Element** | `<element id>` |
| **Disposition** | `<absent → create / partial → extend / …>` |
| **Owner** | `<named person, not "the team">` |
| **Authored by** | `<user / team / agent / script>` |
| **Nature** | `<asserted \| enforced>` |
| **Enforcement mechanism** | `<what fails closed, or n/a — an enforced entry with none is invalid>` |
| **Cadence** | `<how often it changes>` |
| **Review by** | `<YYYY-MM-DD, or an explicit "never" with a reason>` |
| **Traces — element** | `<blueprint element id>` |
| **Traces — facts** | `<profile fact ids this entry depends on>` |
| **Weakest fact** | `<confidence + freshness of the least certain fact above — stated when weak, unverified, or stale>` |
| **Prior state** | `<what is there now, and where it is preserved before overwrite>` |

**Content** — exactly what will be written. No placeholders survive validation.

```
<full content>
```

---

## Demotions

Elements the blueprint marks enforced that this environment cannot enforce. Each becomes an asserted entry, on the record, **a capability fact and a gap entry written to the profile**, and a candidate for the capability backlog.

| Element | Blueprint's mechanism | Why unavailable here | Now | Profile fact written |
|---|---|---|---|---|
| | | | `asserted` / `deferred` | |

## Profile changes this spec depends on

Facts added, confirmed, superseded, or retired during drafting. The profile holds the content; this table is what the approver reads.

| Fact id | Move | What it covers |
|---|---|---|
| | `add` / `confirm` / `supersede` / `retire` | |

## Deliberately not doing

| Element | Why | What would change it |
|---|---|---|

## Validation

Run [../checks/spec-validation.md](../checks/spec-validation.md) before the gate. Record the result:

- **Validated:** `<date>` · **Result:** `<pass | fail — which assertions>`
