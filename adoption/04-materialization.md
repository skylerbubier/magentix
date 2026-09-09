*[Magentix](../README.md) › [Adoption engine](README.md)*

# Materialization and Maintenance

What happens after the gate, and what keeps it from rotting afterward.

---

## The freeze

Approval hashes the spec and writes the declared target set into the manifest. From that moment the spec is read-only and the declared paths are writable.

The point of the inversion is that materialization requires no judgment. The content was written during drafting, reviewed at the gate, and approved. Writing it is transcription.

This has a consequence worth stating plainly, because it is where an agent will be tempted to be helpful: **a better idea arriving during materialization is not implemented.** It goes back to the spec, which means back to the gate. An improvement written at transcription time is an unreviewed change to an approved practice, and it is indistinguishable — at the manifest level — from a mistake.

---

## Writing

### Order

1. **Preserve first.** Anything about to be overwritten is captured before the first write. An adoption that destroys something unrecoverable has failed regardless of the quality of what replaced it.
2. **Depended-on elements before dependents.** An index that points at files writes after the files exist.
3. **Asserted before enforced.** A check that fails closed against content that has not landed yet blocks the rest of the run.
4. **Enforced last, and inert until tested.** Install the mechanism, then verify it in B9 before anything depends on it holding.

### Rules

**Write only declared paths.** A path not in the declared set is not written, even if it obviously should be. That is a spec defect, and the correct response is to record it and return to drafting for it.

**Never write a path another practice owns.** A project running several practices has one owner per path. Writing into a claimed path destroys output the other practice will regenerate, and the destruction is silent in both directions — its next run simply overwrites yours back.

**Extend in place; never fork.** Where the disposition is `Partial`, the existing file is edited. Creating a parallel file next to one that already covers the same ground is the one-home-per-fact violation, and it is the most common way adoption makes a situation worse than it found it.

**Point, don't copy.** Where the disposition is `Satisfied`, the output is a reference to what already covers it. If nothing needs to be written for an element, nothing is written.

**Install mechanisms, not descriptions of mechanisms.** An enforced entry that materializes as a paragraph explaining what should be checked has produced an asserted entry with a misleading label. Either the mechanism goes in, or the entry is demoted on the record.

**Respect authorship-to-location.** A personally-authored entry never lands in a location the team inherits, even when the spec's target path would technically allow it. Spec validation catches this before the gate; materialization catches it again, because the cost of getting it wrong is somebody else silently bound by a preference they never saw.

---

## Verification

Three questions, in order, and none of them is optional.

**Did it land?** Every declared path exists, and its content matches the approved entry.

**Does it load?** Every asserted entry is actually read by whatever is supposed to read it. A context file in a directory the harness does not scan is not adopted, it is stored — and this failure is silent, which is what makes it worth an explicit check.

**Does it hold?** **Every enforced entry is tested by violating it.** Attempt the thing the check exists to prevent and confirm the denial. A check that has never failed is not known to be a check.

That last one is the most-skipped step in the loop and the one that decides whether invariant 3 held in reality or only on paper. An entry whose violation test does not produce a denial is not enforced — it is demoted, on the record, in the adoption record, and the manifest reflects the demotion.

The evidence goes in the record. However terse the agent has been asked to be in conversation, the output substantiating an "in place and holding" claim is part of the record and is not summarized away. Brevity applies to commentary about the work, never to the record of its result.

---

## The manifest

The manifest is what makes this a practice rather than a delivery. One entry per materialized path:

```json
{
  "practice_id": "…",
  "blueprint": { "source": "…", "version_ref": "…", "read_at": "…" },
  "approved_by": "…", "approved_at": "…",
  "artifacts": [
    {
      "path": "…",
      "sha256": "…",
      "owner": "…",
      "nature": "asserted | enforced",
      "enforcement_mechanism": "… | null",
      "cadence": "…",
      "review_by": "YYYY-MM-DD",
      "traces": { "element": "element-id", "facts": ["fact-id", "fact-id"] }
    }
  ],
  "deferred": [ { "element_id": "…", "trigger": "…" } ]
}
```

Every field earns its place:

- **`sha256`** makes drift detectable without judgment. This is the whole maintenance mechanism.
- **`owner`** gives the review date somebody to belong to. A review date with no owner is a date.
- **`nature`** and **`enforcement_mechanism`** carry invariant 3 into the future, including any demotion made during verification.
- **`review_by`** is what converts silent rot into a scheduled question. An artifact that genuinely never needs review says so explicitly rather than being left blank.
- **`traces`** is what makes re-entry cheap, and it points in two directions: at the blueprint element, and at the profile facts. Without the second, a superseded fact means regenerating everything rather than the three entries that actually depended on it.
- **`deferred`** is why the practice looks incomplete on purpose. Without it, a later reader cannot distinguish a deliberate deferral from an oversight.

---

## Drift

A materialized file whose hash no longer matches has drifted. The loop treats that as information, not as a violation.

| What the edit turns out to be | Response |
|---|---|
| An improvement the adopter made | Promote it into the spec at the next re-entry; the manifest re-hashes to the new content |
| A correction of something the loop got wrong | Same, plus a superseding fact in the profile so the next generation does not reintroduce it |
| An unrelated change that happens to touch the path | Reconcile ownership — the path may belong to two practices, which is a conflict |
| Rot — stale content nobody meant to keep | Revert to spec, or re-elicit if the element's slots have gone stale |

The rule underneath all four: **never silently overwrite a drifted file.** Overwriting somebody's improvement once teaches them that the loop destroys their work, and after that they stop using it. Drift is reconciled, at re-entry, with the adopter's knowledge.

---

## Review

Each artifact carries a review date, and an elapsed date is a re-entry trigger — but the review itself is small. It asks one question per artifact: **do the facts this traces to still hold?**

Answer it against the environment first. A fact recording how it was observed is a command to re-run, and most reviews resolve without anyone being asked anything. Only what cannot be verified reaches a person.

When a fact has changed, only the artifacts tracing to it re-enter drafting. This is why the traces field matters more than it looks: without it, "one fact changed" and "regenerate the practice" are the same operation, and a practice that expensive to revise is a practice nobody revises.

A useful default is to inherit the cadence the blueprint states for each element. A blueprint that says one file changes quarterly and another changes constantly has already done the scheduling.

---

## What the loop measures

All of it falls out of artifacts the loop already produces. None of it requires separate instrumentation.

| Signal | Reads as |
|---|---|
| **Conflicts per adoption** | Fit between blueprint and situation. Many conflicts means this blueprint may be wrong for this environment, not that the environment is wrong |
| **Demotions from enforced to asserted** | Capability gap in the target environment, and a direct backlog of what to build next |
| **Deferral rate at first gate** | Whether the blueprint's minimum viable subset is realistic here |
| **Drift rate by artifact** | Which artifacts the practice is actually using. High drift on one file usually means the generated version was wrong, not that the adopter is careless |
| **Elapsed reviews never actioned** | The practice has been abandoned. This is the honest early warning, and it is worth more than any of the others |
| **Questions asked on a re-adoption** | Whether the profile is doing its job. A second adoption against the same profile should ask almost nothing |
| **Facts superseded by verification** | How fast this environment drifts, and therefore how short the verification intervals should be |
| **Elements still deferred after two re-entries** | They are not being adopted. Retire them explicitly rather than carrying them as permanent intent |
| **Questions asked per adoption** | Whether the survey is doing its job. A rising count means the loop is asking for what it could read |

The one that matters most is the fifth. Every other signal describes a practice that is running. That one detects a practice that exists on disk and nowhere else, which is the failure this entire design was built to make visible.

---

## Several practices, one project

The common case, and the one that breaks naive regeneration.

**One owner per path.** Registered at materialization, checked before it. The contended file is almost always a repository's main agent-instruction file, because every practice has something to say there. One practice owns it; the others contribute through paths it references.

**Regenerate in declared order.** Where one practice depends on another, rebuilding the dependency after its dependent leaves the dependent pointing at content that no longer exists.

**Retiring a practice releases its paths.** Until the retirement is recorded those paths stay claimed, and the next adoption reports a collision against something nobody maintains.

---

## Retirement

A practice that is not working should be removed, not left in place.

Retirement is a spec — the same loop, run in reverse — listing the artifacts to remove or revert, running through the same gate, and preserving prior state the same way. It ends with the manifest closed and an adoption record stating why the practice was retired.

This matters for a reason that is easy to miss: an abandoned practice leaves behind context files that agents still load and still follow. A stale asserted document does not become inert when people stop believing it. It keeps steering every session until somebody deletes it.
