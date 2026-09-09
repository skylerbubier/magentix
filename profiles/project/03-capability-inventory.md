*[Magentix](../../README.md) › [Profiles](../README.md) › [Project profile](README.md) › Capability inventory*

# The Capability Inventory

What this project can actually check, block, or require. The highest-value facts in the collection, and the ones most often overstated.

---

## Why this deserves its own document

Every generated practice has to decide, for each thing it produces, whether that thing is **asserted** — a document somebody is asked to honor — or **enforced** — something that fails closed when violated.

That decision cannot be made from a blueprint. A blueprint describes what *should* be enforced in the environment its author had in mind. Whether it *can* be enforced here is a fact about this project, and this is where that fact lives.

Get it wrong in the optimistic direction and the outcome is specific: a practice that believes it holds a control it does not hold. That belief is worse than knowing you have no control at all, because it is what stops anyone from building the real thing. The generated artifact reads like a rule, everyone treats it like a rule, and nothing checks it.

So the inventory has one job: **be pessimistic and be verified.**

## What counts as a capability

A capability is a mechanism that **fails closed**. Something that says no, on its own, without a person choosing to comply.

| Counts | Does not count |
|---|---|
| A required status check that blocks merge | A check that runs and reports |
| A branch protection rule with no bypass | A convention that people follow |
| A pre-commit hook that denies, where it cannot be skipped | A hook that can be bypassed with a flag, unless the bypass is itself blocked |
| A required review from a named owner | A review request that can be dismissed |
| A schema validation in the pipeline that fails the build | A linter whose failures are warnings |
| An environment that refuses an unsigned artifact | A documented deployment procedure |

The test for each entry: **name what happens when somebody violates it.** If the answer is "the build goes red and merge is blocked," it is a capability. If the answer is "someone would notice in review," it is not — it is a convention, and it belongs in a `convention` pointer fact.

## The advisory trap

Two things that look like capabilities and are not, both common enough to name:

**A check that runs but does not block.** Reporting is not enforcement. A pipeline stage that produces findings nobody is required to act on is instrumentation. Record it as instrumentation.

**A control with an available bypass.** Admin override, a skip flag, a force push, a shell redirect that routes around a tool-level hook. A control with a bypass enforces against accident, not against pressure — and pressure is when it matters. Record the bypass explicitly:

```yaml
detail:
  mechanism: <what it is>
  fails_closed: true
  bypass: <how it can be circumvented, and by whom — or "none">
```

An entry with an unrecorded bypass is the single most misleading thing this collection can contain.

---

## The inventory entry

Each capability is a `capability`-category fact, and it carries more than the base schema requires:

```yaml
id: PF-NNNN
category: capability
statement: >
  <What it prevents, stated as the thing that cannot happen.>
detail:
  mechanism: <the concrete thing — a named check, a protection rule, a hook>
  layer: <local | pipeline | platform | process>
  fails_closed: <true | false>
  bypass: <how, and by whom — or "none">
  scope: <what it applies to: paths, branches, environments>
  covers: <what class of violation it catches>
  does_not_cover: <the gap, stated explicitly>
verification:
  method: observed
  how: <how it was tested — ideally by violating it>
  last_result: <what happened when violated>
authority: <who can disable or change it>
```

Three fields do the real work.

**`layer`** matters because layers have different trustworthiness. A local hook is fast feedback that can be routed around; a pipeline check is authoritative but late; a platform control is the strongest. A practice needing something to actually hold routes it through the strongest available layer, and needs to know which that is.

**`does_not_cover`** is the field that prevents overreach. A capability's gap is as important as its coverage — a check on tool-mediated writes that misses shell redirects covers the accident case and not the deliberate one, and a practice relying on it should know that.

**`verification.how` should be a violation.** A capability confirmed by reading configuration is confirmed to exist. A capability confirmed by attempting the thing it prevents and being denied is confirmed to *work*. Only the second one earns `fails_closed: true`.

---

## The gap list

The inventory's most useful output is not what exists. It is what does not.

Record, alongside the capabilities, what a practice would want and cannot have:

```yaml
gaps:
  - want: <the control a blueprint asked for>
    why_unavailable: <no mechanism | mechanism exists but not enabled | outside our authority>
    nearest_available: <the weaker thing that does exist, or none>
    authority: <who could change this>
    requested: <YYYY-MM-DD, if it has been asked for>
```

This list is the capability backlog, and it arrives for free: every time a practice demotes something from enforced to asserted, the demotion is a gap entry. Over a few adoptions the list becomes a prioritized, evidence-backed statement of what the project's tooling is missing — ordered by how many practices wanted it.

That is worth more than the inventory itself, because the inventory describes the present and the gap list describes what to build.

---

## Keeping it current

**One month.** The shortest interval in the collection, and deliberately so.

Capability facts drift in the dangerous direction. Checks get disabled to unblock a release and not re-enabled. Protection rules get relaxed for a migration. A required check gets renamed and silently stops being required. None of those announce themselves, and every one of them turns an enforced artifact into an advisory one while the artifact still reads like a rule.

Re-verification is cheap when `verification.how` names a violation attempt: run it, confirm the denial, stamp the date. Where it is not cheap, that is itself a finding — a control nobody can easily test is a control nobody can easily trust.

## What this inventory is not

- **Not a list of tools.** A tool is not a capability. What it prevents, and whether it fails closed, is the capability.
- **Not aspirational.** A control that is planned, or configured but disabled, is a gap entry rather than a capability.
- **Not a security assessment.** The question here is narrow: which mechanisms can a generated practice rely on to hold.
- **Not a grant.** Recording that a control exists says nothing about who may change it; `authority` says that, and it is a note rather than permission.
