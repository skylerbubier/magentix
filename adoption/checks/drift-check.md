*[Magentix](../../README.md) › [Adoption engine](../README.md)*

# Drift Check

Detects when a live practice needs to re-enter the loop. Runs on a schedule, or at the start of any session that touches the practice.

[`../../scripts/Test-PracticeDrift.ps1`](../../scripts/Test-PracticeDrift.ps1) implements the mechanical half.

---

## The triggers

| Trigger | Detected by | Re-enters at |
|---|---|---|
| **Drift** — a materialized file's hash no longer matches the manifest | Re-hash *(script)* | Reconciliation, with the edit as an input |
| **Review due** — a `review_by` date has elapsed | Date scan *(script)* | Verification: re-check the facts it traces to before asking anyone |
| **Blueprint updated** — the source changed since `version_ref` | Re-read and compare to the stored reading *(script)* | Blueprint reading, then reconciliation for changed elements only |
| **Deferral trigger fired** | The condition recorded in the manifest | Reconciliation, for that element alone |
| **Profile changed** — a fact superseded or retired | Profile re-read vs. the stored reading *(script diff)* | Reconciliation, for the entries tracing to that fact only |
| **Fact went stale** | Profile freshness scan *(script)* | Verification first; elicitation only if it cannot be checked |
| **Capability changed** | Re-verification of the capability facts in the project profile, by hand or via `/magentix:inventory-capabilities` — not mechanically detected by the drift script, which contains no capability logic | Reconciliation — likely a promotion or a demotion |

Missing file at a manifest path is drift of the most severe kind — treat it as a deletion to reconcile, never as an absence to silently regenerate.

The script also emits a state that is not a re-entry trigger: **`REVIEW SOON`**, an advance warning that a `review_by` date falls within the `-WithinDays` window without having elapsed yet. It is informational only — nothing re-enters the loop on it, unlike `REVIEW DUE` above — and exists to help schedule the next pass.

---

## Handling drift

**Drift is a signal, not a violation.** A hand-edited artifact usually means the adopter improved it.

| What the edit turns out to be | Response |
|---|---|
| An improvement | Promote it into the spec at re-entry; re-hash the manifest to the new content |
| A correction of something the loop got wrong | Promote it, and record a decision so the next generation does not reintroduce the error |
| An unrelated change touching the path | Reconcile ownership — the path may belong to two practices, which is a conflict |
| Rot — stale content nobody meant to keep | Revert to spec, or re-elicit if the element's slots have gone stale |

The rule under all four: **never silently overwrite a drifted file.** Overwriting somebody's improvement once teaches them the loop destroys their work, and after that they stop using it.

---

## Scope of re-entry

Only what changed re-enters. Everything whose element and traced facts are unchanged keeps its manifest entry and is not regenerated.

This is what makes maintenance minutes rather than another full sitting, and it works only because every entry recorded its traces in both directions — at the blueprint element and at the profile facts. Without the second, "one fact changed" and "regenerate the practice" are the same operation, and a practice that expensive to revise is one nobody revises.

**Verify before asking.** Most triggers here resolve against the environment rather than against a person: a stale fact that records how it was observed is a command to re-run. Reaching for the human first is how maintenance becomes something people avoid.

---

## What the check reports

```
Practice:  <id>
Blueprint: <source> @ <version_ref>
Profile:   <source> @ <version_ref>
Artifacts: <n>             Phase: <live>

DRIFTED       <path>       hash mismatch — reconcile before any regeneration
MISSING       <path>       in manifest, not on disk
REVIEW DUE    <path>       review_by <date>, <n> days elapsed, owner <who>
REVIEW SOON   <path>       review_by <date>, in <n> day(s), owner <who>
STALE         <blueprint>  changed since it was read
PROFILE STALE <profile>    changed since it was read — check traced entries
OK            <n>          artifact(s) match
DEFERRED      <element>    trigger: <condition>

Next review: <date> (<path>)
```

`REVIEW SOON` only appears when the script is run with `-WithinDays` greater than zero and a `review_by` date falls inside that window. It is informational — an early warning, not a re-entry trigger — and is reported for scheduling only; unlike `REVIEW DUE`, nothing routes to a stage on it.

Two capability rows deserve attention when they appear. A control that was **built** means an asserted artifact can be promoted to enforced. A control that was **quietly disabled** means the practice has been advisory for a while and nobody was told — which is the failure invariant 3 exists to prevent, arriving after the fact.

The signal worth watching over time is **elapsed reviews never actioned**. Every other output describes a practice that is running; that one identifies a practice that exists on disk and nowhere else, which is the failure this whole design was built to make visible.
