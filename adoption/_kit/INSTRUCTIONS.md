*[Magentix](../../README.md) › [Adoption engine](../README.md)*

*This is the canonical procedure that the packaged `adopt-practice` skill follows.*

# Adoption Loop — Agent Instructions

You have been given two inputs:

- a **blueprint** — documents proposing how some kind of work should be done, written by somebody else;
- a **profile** — the durable collection of what is actually true for this person or project.

Your job is to compile one against the other into a working practice at real paths, and to leave both the practice and the profile better than you found them.

Read this file in full. Load the templates and checks it references only at the step that needs them.

---

## Before anything

Establish four things and write them down:

- **Blueprint location.** You will read it. You will never write to it, at any point, for any reason.
- **Profile location.** You will read it and you will write facts back to it — only through its own moves (add, confirm, supersede, retire), never by rewriting it.
- **Practice id.** A short slug. Your workspace is `adoption/{practice-id}/` — outside the blueprint, outside the profile, and outside the target locations.
- **Who approves.** The profile says: whoever holds authority over the facts this practice depends on and the slots it writes. It may not be the person you are talking to.

If no profile exists, this run is a **bootstrap** — same loop, longer elicitation, and every fact you elicit goes into the new collection rather than into your workspace.

Then state, in one or two sentences, what you understand the blueprint to be proposing and what you are about to do. If the adopter corrects you here it costs nothing; if they correct you at the gate it costs the whole draft.

## The rules you cannot break

1. **The blueprint is read-only.** If an element is awkward to instantiate, record a conflict and escalate. Never edit the blueprint to match what you managed to build.
2. **Nothing lands anywhere real before the gate.** Drafting is wide and free precisely because it is inert. Target locations are read-only until approval.
3. **After the gate you transcribe, you do not compose.** Write only what was approved, only to declared paths. A better idea goes back to the spec, not into the file.
4. **Never claim enforcement you cannot demonstrate.** An entry marked enforced names a mechanism that fails closed, and you test it by violating it. If you cannot, demote it and say so.
5. **You cannot approve.** Not for the adopter, and not for an authority who is not present.
6. **Nothing you generate relaxes an existing control.** If a spec entry and a control in this environment disagree, stop and say so.
7. **Facts belong to the profile, never to your workspace.** Anything you elicit, correct, or verify goes into the collection. A fact left in a run's notes is a fact the next adoption asks for again.
8. **Never reshape the profile.** You add, confirm, supersede, and retire. You do not reorganize a collection you do not own.
9. **No blueprint element and no profile fact names a tool.** Agent tooling appears in exactly two places: the profile's harness binding, and the artifacts you generate. If you find yourself wanting to write a tool name anywhere else, stop.

---

## Phase A — Draft

### Step 1 · Read the blueprint

Read all of it. Derive `blueprint-reading.yaml` using [`../templates/blueprint-reading.yaml`](../templates/blueprint-reading.yaml).

Capture the blueprint's **actual detail** — required structure, fields, thresholds, formats, its own arguments for why each element exists. You are indexing the blueprint, not summarizing it. A reading abstract enough to have come from any blueprint will produce a generic practice with a citation on it.

Capture especially:
- its **invariants** — these become validation assertions later
- its **out-of-scope / known-limits / non-goals** — the strongest guard you have against overreach
- its **minimum viable subset** and **adoption order**, if it names them
- its **slots** — everything it leaves for the adopter to fill. These are the only things you may ask about

Every element carries a `source_ref` back into the blueprint. An element with no source is something you invented.

Full contract, including how to handle thin, contradictory, or narrative blueprints: [../02-blueprint-contract.md](../02-blueprint-contract.md).

### Step 2 · Read the profile, then verify it

Derive [`../templates/profile-reading.yaml`](../templates/profile-reading.yaml), recording what you checked in [`../templates/verification-notes.md`](../templates/verification-notes.md). Normalize two things no format expresses the same way:

- **confidence** — `strong` (observed, measured, or from a correction the person actually made) / `moderate` (stated, or read from config but untested) / `weak` (inferred or assumed)
- **freshness** — `fresh` / `stale` (interval lapsed — **still used**, but flag that you are acting on an old fact) / `unverified` (never confirmed; confirm before generating anything that depends on it)

Then **verify what is cheap to verify.** A fact that records how it was observed costs one command to re-check. Do that before asking anybody anything: a stale fact with a recorded verification method is a lookup, not a question.

Where reality contradicts a recorded fact, **supersede it in the profile**, with the observation as evidence. That is a correction to the collection, not a note in your run.

Read the capability picture **pessimistically**. No verified mechanism that fails closed means every enforced element demotes. Guessing optimistically here is how a practice ends up believing it holds a control it does not hold.

Also look for: paths already claimed by another live practice on this project (a collision is a decision to surface, not an absence to fill); templates present but unfilled from an earlier attempt (lead the conversation with those); and a prior manifest for this practice (then this is a re-entry — jump to Step 4).

Full contract: [../05-profile-contract.md](../05-profile-contract.md).

### Step 3 · Elicit the remainder

Three sources, strictly ordered by cost: **the profile** (free), **the environment** (nearly free), **the human** (irreplaceable, and finite). Ask only what the first two could not settle, bounded by the blueprint's slots.

Never ask for what is on disk. Never ask for what the profile already says — that tells the person their answers are not being kept.

Follow the blueprint's adoption order and start with its minimum viable subset. Carry the blueprint's own rationale so the adopter can judge whether it applies to them, and propose a defensible default to correct rather than an open prompt.

**Write every answer to the profile**, using its own moves. Keep only run-scoped material in [`../templates/run-record.md`](../templates/run-record.md): which fact ids you touched, which defaults you took rather than had chosen, what is still open, and what conflicts blocked the gate.

**Stop when every blocking slot is filled.** Not when every question is answered. Non-blocking gaps become deferrals with a revisit trigger. A run that materializes four elements and defers eleven is a success; a run abandoned at question thirty produced nothing.

Method and question shapes: [../03-elicitation.md](../03-elicitation.md).

### Step 4 · Reconcile

Give every element exactly one disposition:

| Disposition | When | What you do |
|---|---|---|
| **Satisfied** | a profile fact or an existing artifact already covers it | Point at what covers it. Generate nothing |
| **Partial** | covered in part, or stale | Extend or refresh **in place**. Never create a parallel copy |
| **Absent** | nothing covers it | Create it |
| **Conflict** | a fact is incompatible with the element, or two facts contradict | Stop. Needs a human decision, not a generated file |
| **Not applicable** | does not apply here | Record why — an unexplained omission looks like an oversight later |
| **Deferred** | applies, not now | Record the revisit trigger |

This is the whole brownfield path. Skipping it produces duplicates of things that already exist.

On re-entry, reconcile only what changed: drifted files, elapsed reviews, superseded facts, updated blueprint elements, changed capabilities, fired deferral triggers. Everything whose element and facts are unchanged keeps its manifest entry untouched.

### Step 5 · Write the spec

Fill [`../templates/practice-spec.md`](../templates/practice-spec.md). One entry per artifact that will exist, each carrying target path, owner, cadence, asserted-or-enforced (with the named mechanism if enforced), disposition, and what it traces to — **both** the blueprint element and the profile facts.

Check every declared path against paths another live practice already owns. Match each entry's authorship to its slot's scope: an individually-authored entry never targets a slot the profile marks `shared`.

**Write the full content of every generated artifact into the spec.** The spec is not a plan to write files later — it is the files, staged for review. This is what makes the gate meaningful and Step 8 mechanical.

Declare the target set: every path you intend to write. Then state what you are deliberately not doing and what would change that.

### Step 6 · Validate

Run every assertion in [`../checks/spec-validation.md`](../checks/spec-validation.md). Any failure sends you back to Step 3 or Step 5 — never forward.

The two that catch the most: no unfilled placeholder survives into an approved spec, and no entry claims enforcement without a mechanism that fails closed.

### Step 7 · Gate

Present the spec to the approver. The full content and the diff against what exists today, not a summary.

Ask them to confirm the dispositions, particularly every `Satisfied` (did it really cover it?) and every `Not applicable` (judgment, or oversight?). Point out the defaults you took and any divergence from the blueprint.

Approved → record identity and timestamp, hash the spec, write the declared set into the manifest. **You cannot approve.** Rejected → back to Step 3 or 5 with the reason recorded.

---

## Phase B — Apply

### Step 8 · Materialize

Transcribe. The content was approved; nothing is composed now.

Order: preserve anything you are about to overwrite → depended-on before dependents → asserted before enforced → enforced last.

Write only declared paths, and never a path another practice owns. Extend in place rather than forking. Where the disposition is `Satisfied`, write nothing. Where an entry is enforced, install the mechanism itself, not a paragraph describing it.

### Step 9 · Verify

Run [`../checks/materialization-check.md`](../checks/materialization-check.md). Three questions:

- **Did it land?** Path exists, content matches the entry.
- **Does it load?** The thing that should read it actually reads it. A context file the harness never scans is stored, not adopted — and this fails silently.
- **Does it hold?** **Test every enforced entry by violating it.** A check that has never failed is not known to be a check. No denial means the entry is demoted to asserted, on the record.

**Every demotion becomes a profile fact.** An element that could not be enforced has just produced verified knowledge about this environment — write a capability fact and a gap entry into the collection. That is how the capability backlog accumulates without anybody maintaining it by hand.

Keep the evidence. Terseness applies to your commentary, never to the record of a result.

### Step 10 · Manifest and hand off

Write [`../templates/practice-manifest.json`](../templates/practice-manifest.json): every materialized path with hash, owner, nature, cadence, review date, and traces. Include deferred elements with their triggers.

Register the practice and the paths it owns, so the next adoption on this project detects a collision instead of overwriting.

Write [`../templates/adoption-record.md`](../templates/adoption-record.md): what was instantiated, what was deferred and why, what conflicted and how it resolved, what was demoted, and which profile facts this run added or changed.

Then report: what is live, what is deferred, what needs the adopter, and when the first review falls due.

---

## Re-entry

Same loop, with prior state. Detect the trigger with [`../checks/drift-check.md`](../checks/drift-check.md).

| Trigger | Re-enter at |
|---|---|
| Drift — a materialized file changed outside the loop | Step 4, with the edit as an input |
| Review date elapsed | Step 2 — re-verify the facts it traces to before asking anyone |
| Blueprint updated | Step 1, then Step 4 for changed elements only |
| A fact was superseded or retired | Step 4, for the entries tracing to that fact only |
| A fact went stale | Step 2 to verify; Step 3 only if it cannot be verified |
| Capability changed | Step 4 — likely a promotion or a demotion |
| Deferral trigger fired | Step 4, for that element alone |

**Verify before asking.** Most triggers resolve against the environment rather than a person. Reaching for the human first is how maintenance becomes something people avoid.

**Never silently overwrite a drifted file.** A hand-edit is usually an improvement. Reconcile it with the adopter — promote it into the spec or revert it deliberately. Overwriting somebody's work once teaches them not to trust this loop again.

---

## Failure modes to check yourself against

Before the gate, ask whether you have done any of these:

- **Asked for something you could have read.** Count your questions against your survey.
- **Generated a copy of something that already exists.** That is a missed `Satisfied` or `Partial`.
- **Left a placeholder in.** The dead-template failure, arriving fully formed.
- **Marked something enforced that nothing checks.** Name the mechanism or demote it.
- **Adopted everything at once.** If the blueprint named a starting subset and you exceeded it, justify that explicitly.
- **Put a personal preference somewhere a team inherits.** Check every target path against its entry's authorship.
- **Softened the blueprint because an element was hard.** That is invariant 1, and it is the failure this loop exists to prevent.
- **Produced a practice with no review dates.** Then you built something that will rot silently.
- **Left a fact in your workspace.** The next adoption will ask for it again.
- **Written a tool name into a blueprint reading or a profile fact.** Agent specifics belong in the harness binding and in the artifacts, nowhere else.
- **Claimed a path another practice owns.** Its next run will overwrite yours, silently.
