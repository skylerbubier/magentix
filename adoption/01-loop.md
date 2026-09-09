*[Magentix](../README.md) › [Adoption engine](README.md)*

# The Loop — Stage Reference

Every stage below states who owns it, what it reads and writes, what it actually does, and what checks it. Anything marked **script** costs no judgment and is not subject to model opinion.

Vocabulary used throughout:

| Term | Meaning |
|---|---|
| `BLUEPRINT` | the source documents describing the practice. Read-only in every stage, without exception |
| `PROFILE` | the durable collection of what is true for this person or project. Read freely; written only through add / confirm / supersede / retire |
| `READING` | the derived, structured views: `blueprint-reading.yaml` and `profile-reading.yaml` |
| `ENVIRONMENT` | what can be read off disk right now. Not an input in its own right — it is how `PROFILE` facts get verified |
| `SPEC` | `practice-spec.md` — the proposed practice, entry by entry. The reviewable object |
| `DECLARED` | the set of target paths `SPEC` says it will write |
| `CLAIMED` | paths already owned by another live practice on this project. Disjoint from `DECLARED`, always |
| `PROTECTED` | paths the loop may never write: the blueprint, anything an existing control owns, anything outside the adopter's authority |
| `WORKSPACE` | `adoption/{practice-id}/` — the loop's own files. Always writable, never part of `DECLARED`, never reviewed as output, and **never a home for facts** |

---

## Phase A — DRAFT
*Target locations are read-only. Nothing lands anywhere real.*

### B0 · Blueprint Reading
- **Owner:** agent · **Reads:** `BLUEPRINT` · **Writes:** `WORKSPACE/blueprint-reading.yaml`
- Read the blueprint in full. It is the one input worth reading completely rather than sampling, because everything downstream is a projection of it.
- Derive one **element** per thing the blueprint proposes should exist — a document, a check, a step, a role, a cadence. Capture the blueprint's actual detail for each: what it is, who authors it, how often it changes, whether it is asserted or enforced, what it leaves for the adopter to fill.
- Capture the blueprint's own **invariants**, its **out-of-scope list**, its **adoption order**, and its **minimum viable subset** where it states them. A blueprint that names its own anti-patterns has just handed you the best guard against overreach available; use it.
- Record what the blueprint deliberately leaves open. Those become elicitation targets in B2, and nothing else should be.
- **Enforced by:** every element carries a `source_ref` back into the blueprint. An element with no source is an invention, and inventions are what invariant 1 exists to prevent.
- **Exit:** a reading whose element list, read back to a person familiar with the blueprint, is recognizably that blueprint. Full contract in [02-blueprint-contract.md](02-blueprint-contract.md).

### B1 · Profile Reading & Verification
- **Owner:** agent · **Reads:** `PROFILE`, `ENVIRONMENT` (both read-only) · **Writes:** `WORKSPACE/profile-reading.yaml`, `WORKSPACE/verification-notes.md`, and corrections back into `PROFILE`
- Derive the profile reading. Normalize two fields the loop depends on and no format expresses the same way: **confidence** (strong / moderate / weak) and **freshness** (fresh / stale / unverified).
- **Verify what is cheap to verify.** An observable fact recording how it was observed costs one command to re-check. Do that before asking anyone anything — a stale fact with a recorded verification method is not a question, it is a lookup.
- Where reality contradicts a recorded fact, **supersede it in the profile**, with the observation as the new fact's evidence. That is a correction to the collection, not a note in this run.
- Read the capability picture pessimistically. An element the blueprint marks enforced, where no verified mechanism fails closed, is a demotion — and it is far cheaper to discover here than at verification.
- Note what the profile does not cover. Those gaps, plus the blueprint's own slots, are the entire legitimate scope of B2.
- **Enforced by:** no write to any target path. A run that modifies the practice here has broken invariant 2 before it has a spec.
- **Exit:** a normalized reading, a verification record, and a profile no less accurate than when the run started. Full contract in [05-profile-contract.md](05-profile-contract.md).

### B2 · Elicitation
- **Owner:** human + agent, conversational · **Reads:** both `READING`s, verification notes · **Writes:** `PROFILE`
- Ask only about what the profile does not hold and B1 could not verify, bounded by the blueprint's slots. **Never ask for what is on disk, and never ask for what the profile already says.**
- Work slot by slot, in the blueprint's own adoption order where it states one. Propose a defensible default and invite correction rather than opening with a blank question.
- **Every answer is written to the profile, not to this run.** Add, confirm, supersede, or retire — using the collection's own moves. A fact left in the workspace is a fact the next adoption will ask for again, which is the whole failure this design exists to prevent.
- Where the profile and the person disagree — someone describes a habit their own recorded facts contradict — surface it. That gap is the highest-value conversation in the loop, and it resolves into a supersession, a scope split, or a retirement.
- **Enforced by:** an answer with no slot is out of scope; a slot with no answer is an open question marked blocking or non-blocking. Nothing is silently defaulted without being recorded as a default.
- **Exit:** zero blocking questions open. Full method in [03-elicitation.md](03-elicitation.md).

### B3 · Reconciliation
- **Owner:** agent · **Reads:** both `READING`s, verification notes · **Writes:** a disposition per element, into `SPEC`
- Classify every blueprint element against what the profile and the environment jointly say:

| Disposition | Test | What the spec does |
|---|---|---|
| **Satisfied** | a profile fact or an existing artifact already covers this | Point at what covers it. Generate nothing |
| **Partial** | covered in part, or covered but stale | Extend or refresh in place; never create a parallel copy |
| **Absent** | nothing covers it | Create it |
| **Conflict** | a profile fact is incompatible with the element, or two facts contradict | Stop. This needs a decision, not a generated file |
| **Not applicable** | the element does not apply here | Record why. An unexplained omission is indistinguishable from an oversight later |
| **Deferred** | applies, but not now | Record the revisit trigger |

- This is the entire brownfield path. A loop that skips reconciliation generates duplicates of things that already exist, which is how a practice becomes less trustworthy by being adopted.
- **Enforced by:** every element has exactly one disposition, and `Conflict` blocks the gate until resolved.

### B4 · Spec Authoring
- **Owner:** agent · **Writes:** `WORKSPACE/practice-spec.md`
- Write one entry per artifact that will exist, each carrying: target path, owner, change cadence, **asserted or enforced** (and for enforced, the named mechanism), disposition from B3, and the blueprint element and profile facts it traces to.
- Declare the target set: every path the spec intends to write, and check it against paths already `CLAIMED` by other live practices on this project.
- Write the content of every generated artifact in full, in the spec. The spec is not a plan to write files later — it is the files, staged for review. This is what makes the gate meaningful and materialization mechanical.
- State what is deliberately not being done, and the trigger that would change that.
- **Exit:** B5 passes.

### B5 · Spec Validation *(script)*
- **Owner:** script · **Reads:** `SPEC`, `READING` · **Writes:** validation report

| Assertion | Catches |
|---|---|
| Every entry traces to an element or a recorded decision | Invented content |
| Every non-deferred element has a disposition | Silently dropped requirements |
| No entry marked enforced lacks a named failing-closed mechanism | A document pretending to be a control |
| No unfilled placeholder anywhere in an entry's content | The dead-template failure, mechanically |
| No two entries state the same fact | Guaranteed future contradiction |
| `DECLARED ∩ PROTECTED = ∅` | Writing the blueprint, or something the adopter does not own |
| No individually-authored entry targets a harness slot the profile marks `shared` | Preference leaking into a file others inherit |
| `DECLARED ∩ CLAIMED = ∅` | Two practices overwriting each other's artifacts |
| Every entry depending on a `weak` or `unverified` fact says so | A practice built on a guess, presented as settled |
| Every entry names a review cadence or an explicit "never" | Silent rot |

- **Enforced by:** failure blocks the gate. Checklist form in [checks/spec-validation.md](checks/spec-validation.md).

### B6 · Approval Gate *(the only human gate)*
- **Owner:** named human approver. The profile says who: an artifact's approver is whoever holds `authority` over the facts it depends on and the slots it writes — which is not always the person running the loop
- Review the spec itself, including the full content of what will be written and the diff against what exists today. Not a summary.
- Confirm the dispositions, particularly every `Satisfied` (did it really cover it?) and every `Not applicable` (was that a judgment or an oversight?).
- Approve → freeze. Reject → back to B2 or B4 with a recorded reason.
- **Enforced by:** the freeze cannot run without a recorded approval carrying an identity and a timestamp. The agent cannot approve on the adopter's behalf, and for a team practice cannot approve on the owner's behalf either.

---

## The FREEZE
*The pivot. Mutability inverts here.*

### B7 · Freeze *(script)*
- Hash the approved spec. Write `DECLARED` into `WORKSPACE/practice-manifest.json` with the approval identity and timestamp. Flip the phase flag to `apply`.
- From here the spec is read-only and the declared paths are writable. Any need to change the spec is a return to B4 and a new approval — there is no in-flight amendment.

---

## Phase B — APPLY
*Spec is frozen. Target locations are writable, at declared paths only.*

### B8 · Materialization
- **Owner:** agent · **Writes:** target paths in `DECLARED` only
- Write each entry's content to its declared path. This is transcription: the content was approved, and nothing is composed at write time.
- Before overwriting anything that exists, capture its prior state. A practice adoption that destroys something unrecoverable has failed regardless of the quality of what replaced it.
- Where an entry is enforced, install the mechanism, not a description of it.
- **Enforced by:** a write outside `DECLARED`, or into a path `CLAIMED` by another practice, is denied. Full procedure and the ordering rules in [04-materialization.md](04-materialization.md).

### B9 · Verification
- **Owner:** agent · **Writes:** `WORKSPACE/adoption-record.md`
- Every declared path exists and its content matches the spec entry.
- Every asserted entry actually loads where it is supposed to load. A context file in a location the harness does not read is not adopted, it is stored.
- **Every enforced entry is tested by violating it.** A check that has never failed is not known to be a check. This is the single most-skipped step and the one that determines whether invariant 3 held in practice or only on paper.
- Record the evidence. However terse the agent has been asked to be, the output substantiating a "this is in place" claim is part of the record and is not summarized away.
- **Every demotion becomes a profile fact.** An element that could not be enforced has just produced verified knowledge about this environment: write a capability fact and a gap entry into the profile. That is how the capability backlog accumulates without anyone maintaining it by hand.

### B10 · Manifest & Handoff *(script + agent)*
- Write the final manifest: every materialized path with its hash, owner, cadence, review date, and the spec entry it came from.
- Write the adoption record: what was instantiated, what was deferred and its trigger, what conflicted and how it was resolved, what was demoted from enforced to asserted.
- Register the practice and the paths it owns, so the next adoption on this project detects a collision instead of overwriting.
- **Exit:** the practice is live and re-enterable. Everything the next run needs is in the manifest, the profile, or the adoption record — never in this session.

---

## Re-entry — the maintenance half

The loop is the same loop. What changes is that prior state exists, and it exists in two places: the manifest describes the artifacts, and the profile describes the facts they were generated from.

| Trigger | Detected by | Re-enters at |
|---|---|---|
| **Drift** — a materialized file changed outside the loop | Manifest re-hash *(script)* | B3, with the edit as an input to reconcile |
| **Review due** — a review date elapsed | Manifest scan *(script)* | B1: re-verify the facts the artifact traces to before asking anybody anything |
| **Blueprint updated** | Blueprint re-read vs. stored reading *(script diff)* | B0, then straight to B3 for changed elements only |
| **Profile changed** — a fact was superseded or retired | Profile re-read vs. stored reading *(script diff)* | B3, for the entries tracing to that fact only |
| **Fact went stale** | Profile freshness scan *(script)* | B1 to re-verify; B2 only if it cannot be verified |
| **Deferral trigger fired** | The condition recorded in the adoption record | B3 for that element alone |
| **Capability changed** — something became enforceable, or stopped being | Capability re-verification *(script)* | B3, and likely a promotion or demotion |

The two most valuable rows are the ones the earlier shape of this design could not detect. **Profile changed** means somebody's circumstances moved and the artifacts should follow without anyone re-reading a blueprint. **Capability changed** cuts both ways — a control that was built means an asserted artifact can be promoted to enforced, and a control that was quietly disabled means a practice has been advisory for a while and nobody was told.

Three rules make re-entry cheap rather than a second full adoption:

**Drift is a signal, not a violation.** A materialized file edited by hand usually means the adopter improved it. The response is to reconcile: promote the edit into the spec, or revert it deliberately — but never silently overwrite it. Overwriting somebody's improvement once teaches them not to trust the loop again.

**Verify before asking.** Most re-entry triggers resolve against the environment rather than against a person. A stale fact that records how it was observed is a command to re-run, not a question to ask. Reaching for the human first is how maintenance becomes something people avoid.

**Only what traces to the change re-enters.** A blueprint update touching two elements re-runs those two; a superseded fact re-runs the entries tracing to it. Everything else keeps its manifest entry untouched. This is what makes the second run minutes rather than another full sitting, and it works only because every spec entry recorded both the element and the facts it came from.
