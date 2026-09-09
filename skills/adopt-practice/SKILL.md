---
name: adopt-practice
description: Use when compiling a best-practice blueprint against a profile into a working practice at real paths — "adopt this practice", "run the adoption loop", "materialize this blueprint", or re-entering an already-adopted practice after drift, a review date, or a blueprint/profile change. Orchestrates drafting, the approval gate, and materialization end to end.
argument-hint: "[blueprint path] [profile path] [practice-id]"
---

Normative source: [the canonical procedure](${CLAUDE_PLUGIN_ROOT}/adoption/_kit/INSTRUCTIONS.md) — read it in full before running this skill, and adapt it faithfully. Companion contracts: [the loop](${CLAUDE_PLUGIN_ROOT}/adoption/01-loop.md) · [blueprint contract](${CLAUDE_PLUGIN_ROOT}/adoption/02-blueprint-contract.md) · [elicitation](${CLAUDE_PLUGIN_ROOT}/adoption/03-elicitation.md) · [materialization](${CLAUDE_PLUGIN_ROOT}/adoption/04-materialization.md) · [profile contract](${CLAUDE_PLUGIN_ROOT}/adoption/05-profile-contract.md) · [checks/](${CLAUDE_PLUGIN_ROOT}/adoption/checks/).

This skill produces a **working practice**: files, configs, and checks materialized at real, declared paths, plus a `practice-manifest.json` and an `adoption-record.md` that make the practice re-enterable rather than a one-shot generation. It compiles two inputs — a blueprint (read-only, always) and a profile (read freely, written only through its own moves) — and leaves both the practice and the profile better than it found them.

## Procedure

**Before anything**, establish and write down: the blueprint location (read, never written, for any reason); the profile location (read freely, written only through add/confirm/supersede/retire); a practice-id, whose workspace is `adoption/{practice-id}/` — outside the blueprint, the profile, and every target location; and who approves — the profile's authority holder over the facts this practice depends on and the slots it writes, who may not be the person running this skill. If no profile exists, this run is a **bootstrap**: same loop, longer elicitation, and every elicited fact goes into the new collection, never into the workspace. Then state, in one or two sentences, what the blueprint is proposing and what you are about to do — a correction here costs nothing; the same correction at the gate costs the whole draft.

### The rules you cannot break

1. The blueprint is read-only. An awkward element gets a recorded conflict and an escalation, never an edited blueprint.
2. Nothing lands anywhere real before the gate. Drafting is wide and free precisely because it is inert.
3. After the gate you transcribe, you do not compose. A better idea goes back to the spec, not into the file.
4. Never claim enforcement you cannot demonstrate. Name a mechanism that fails closed and test it by violating it, or demote and say so.
5. You cannot approve — not for the adopter, and not for an absent authority.
6. Nothing you generate relaxes an existing control. A disagreement between a spec entry and an environment control stops the run, not routes around it.
7. Facts belong to the profile, never to the workspace.
8. Never reshape the profile — add, confirm, supersede, retire only.
9. No blueprint element and no profile fact names a tool. Agent tooling appears in exactly two places: the profile's harness binding, and the artifacts you generate.

### Phase A — Draft *(target locations are read-only; nothing lands anywhere real)*

**Step 1 · Read the blueprint.** Read all of it — this is the one input worth reading completely. Derive `blueprint-reading.yaml` using [`${CLAUDE_PLUGIN_ROOT}/adoption/templates/blueprint-reading.yaml`](${CLAUDE_PLUGIN_ROOT}/adoption/templates/blueprint-reading.yaml). Capture the blueprint's actual detail — required structure, fields, thresholds, formats, its own arguments for why each element exists — plus its invariants (they become validation assertions), its out-of-scope/known-limits list (the strongest guard against overreach), its minimum viable subset and adoption order where stated, and its slots (the only legitimate elicitation targets). Every element carries a `source_ref`; an element with none is something you invented. Full contract: [02-blueprint-contract.md](${CLAUDE_PLUGIN_ROOT}/adoption/02-blueprint-contract.md).

**Step 2 · Read the profile, then verify it.** Derive [`profile-reading.yaml`](${CLAUDE_PLUGIN_ROOT}/adoption/templates/profile-reading.yaml), recording what you checked in [`verification-notes.md`](${CLAUDE_PLUGIN_ROOT}/adoption/templates/verification-notes.md). Normalize **confidence** (`strong` = observed/measured/from a real correction; `moderate` = stated or read from config untested; `weak` = inferred or assumed) and **freshness** (`fresh`; `stale` = interval lapsed, still used, but flag it; `unverified` = never confirmed, confirm before depending on it). Verify what is cheap to verify before asking anyone anything. Where reality contradicts a recorded fact, supersede it in the profile, with the observation as evidence. Read the capability picture pessimistically: no verified failing-closed mechanism means every enforced element demotes. Also check for paths already claimed by another live practice, unfilled templates from an earlier attempt (lead with these), and a prior manifest for this practice-id (a re-entry — see the table below). Full contract: [05-profile-contract.md](${CLAUDE_PLUGIN_ROOT}/adoption/05-profile-contract.md).

**Step 3 · Elicit the remainder.** Three sources, strictly ordered by cost: the profile (free), the environment (nearly free, and it verifies the profile too), the human (irreplaceable and finite). Ask only what the first two could not settle, bounded by the blueprint's slots — never for what is on disk, never for what the profile already says. Follow the blueprint's adoption order and start with its minimum viable subset; carry the blueprint's own rationale so the adopter can judge whether it applies; propose a defensible default. **Write every answer to the profile**, using its own moves. Keep only run-scoped material in [`run-record.md`](${CLAUDE_PLUGIN_ROOT}/adoption/templates/run-record.md): which fact ids this run touched, defaults taken rather than chosen, open questions, and conflicts. Stop when every *blocking* slot is filled, not when every question is answered — non-blocking gaps become deferrals with a revisit trigger. Method and question shapes: [03-elicitation.md](${CLAUDE_PLUGIN_ROOT}/adoption/03-elicitation.md).

**Step 4 · Reconcile.** Give every element exactly one disposition:

| Disposition | When | What the spec does |
|---|---|---|
| **Satisfied** | a profile fact or existing artifact already covers it | Point at what covers it. Generate nothing |
| **Partial** | covered in part, or stale | Extend or refresh in place — never a parallel copy |
| **Absent** | nothing covers it | Create it |
| **Conflict** | a fact is incompatible with the element, or two facts contradict | Stop — needs a human decision, not a generated file |
| **Not applicable** | does not apply here | Record why — an unexplained omission looks like an oversight later |
| **Deferred** | applies, not now | Record the revisit trigger |

This is the whole brownfield path; skipping it produces duplicates of things that already exist. On re-entry, reconcile only what changed.

**Step 5 · Write the spec.** Fill [`practice-spec.md`](${CLAUDE_PLUGIN_ROOT}/adoption/templates/practice-spec.md): one entry per artifact, each carrying target path, owner, cadence, asserted-or-enforced (with the named mechanism if enforced), disposition, and what it traces to — both the blueprint element and the profile facts. Check every declared path against paths another live practice already owns, and match each entry's authorship to its slot's scope — an individually-authored entry never targets a slot the profile marks `shared`. **Write the full content of every generated artifact into the spec** — it is the files, staged for review, not a plan to write them later. Declare the target set, and state what is deliberately not being done and what would change that.

**Step 6 · Validate.** Run every assertion in [spec-validation-assertions.md](references/spec-validation-assertions.md) (originals: [checks/spec-validation.md](${CLAUDE_PLUGIN_ROOT}/adoption/checks/spec-validation.md)). Any failure sends the run backward — to Step 3 or Step 5 — never forward to the gate. The two that catch the most: no unfilled placeholder survives (C1), and no entry claims enforcement without a named failing-closed mechanism (H1).

**Step 7 · Gate — the only human approval in the loop.** Present the spec to the approver: full content and the diff against what exists today, never a summary. Ask them to confirm dispositions, particularly every `Satisfied` (did it really cover it?) and every `Not applicable` (judgment, or oversight?). Point out defaults taken and any divergence from the blueprint. Approved → record identity and timestamp, hash the spec, write the declared set into the manifest. You cannot approve. Rejected → back to Step 3 or 5 with the reason recorded.

### The FREEZE

Approval hashes the spec and writes `DECLARED` into `practice-manifest.json` with the approval identity and timestamp; the phase flag flips to `apply`. From this instant the spec is read-only and the declared paths are writable — there is no in-flight amendment. **A better idea arriving during materialization is not implemented.** It goes back to the spec, which means back to the gate; an improvement written at transcription time is an unreviewed change to an approved practice and is indistinguishable, at the manifest level, from a mistake.

### Phase B — Apply *(spec frozen; declared paths writable, nowhere else)*

**Step 8 · Materialize.** Transcribe — nothing is composed now. Order: preserve anything about to be overwritten → depended-on elements before dependents → asserted before enforced → enforced last, and inert until tested. Write only declared paths, never a path another practice owns. Extend in place rather than forking; where the disposition is `Satisfied`, write nothing. Where an entry is enforced, install the mechanism itself, not a paragraph describing it. Full ordering rules: [04-materialization.md](${CLAUDE_PLUGIN_ROOT}/adoption/04-materialization.md).

**Step 9 · Verify.** Run every assertion in [materialization-assertions.md](references/materialization-assertions.md) (originals: [checks/materialization-check.md](${CLAUDE_PLUGIN_ROOT}/adoption/checks/materialization-check.md)) — did it land, does it load, does it hold. **Every enforced entry is tested by violating it**; a check that has never failed is not known to be a check. No denial means demote to asserted, on the record. **Every demotion becomes a profile fact** — a capability fact and a gap entry, so the capability backlog accumulates without anyone maintaining it by hand. Keep the evidence in full; terseness applies to commentary, never to the record of a result.

**Step 10 · Manifest and hand off.** Write [`practice-manifest.json`](${CLAUDE_PLUGIN_ROOT}/adoption/templates/practice-manifest.json): every materialized path with hash, owner, nature, cadence, review date, and traces (both the blueprint element and the profile facts — the second is what makes re-entry cheap). Include deferred elements with their triggers. Register the practice and the paths it owns in the project's practice registry, so the next adoption detects a collision instead of overwriting. Write [`adoption-record.md`](${CLAUDE_PLUGIN_ROOT}/adoption/templates/adoption-record.md): what was instantiated, what was deferred and why, what conflicted and how it resolved, what was demoted, and which profile facts this run touched. Report: what is live, what is deferred, what needs the adopter, and when the first review falls due.

## Where the workspace lives

`adoption/{practice-id}/` holds `blueprint-reading.yaml`, `profile-reading.yaml`, `verification-notes.md`, `practice-spec.md`, `practice-manifest.json`, and `adoption-record.md`. It never lives inside the blueprint (that would break rule 1 on the first write), it never holds the profile (a copy of a fact here is a fact that will not be updated), and it is agent-writable at all times — writing it is never a change to the practice, never reviewed, and never subject to the declared target set.

## Re-entry

Same loop, with prior state. Detect the trigger with [/magentix:check-practice-drift](../check-practice-drift/SKILL.md).

| Trigger | Re-enters at |
|---|---|
| Drift — a materialized file changed outside the loop | Step 4, with the edit as an input |
| Review date elapsed | Step 2 — re-verify the facts it traces to before asking anyone |
| Blueprint updated | Step 1, then Step 4 for changed elements only |
| A fact was superseded or retired | Step 4, for the entries tracing to that fact only |
| A fact went stale | Step 2 to verify; Step 3 only if it cannot be verified |
| Capability changed | Step 4 — likely a promotion or a demotion |
| Deferral trigger fired | Step 4, for that element alone |

**Verify before asking** — most triggers resolve against the environment rather than a person. **Never silently overwrite a drifted file** — a hand-edit is usually an improvement; reconcile it with the adopter, promoting it into the spec or reverting it deliberately. Overwriting somebody's work once teaches them not to trust this loop again.

## Do not

- Ask for something you could have read, or ask the profile something it already holds.
- Generate a copy of something that already exists — that is a missed `Satisfied` or `Partial`.
- Leave a placeholder in an approved spec entry.
- Mark something enforced that nothing checks. Name the mechanism or demote it.
- Adopt everything at once. If the blueprint named a starting subset and you exceeded it, justify that explicitly.
- Put a personally-authored entry somewhere a team inherits.
- Soften the blueprint because an element was hard to instantiate — that is exactly what rule 1 exists to prevent.
- Produce a practice with no review dates, or with an unjustified `never`.
- Leave a fact in the run's workspace — the next adoption will ask for it again.
- Write a tool name into a blueprint reading or a profile fact. Agent specifics belong only in the harness binding and the artifacts.
- Claim a path another practice owns — its next run will overwrite yours, silently.
- Implement an improvement discovered during materialization instead of sending it back to the spec.

## How to know you did it right

- Every element in the blueprint reading has exactly one disposition, and the spec passed every assertion in [spec-validation-assertions.md](references/spec-validation-assertions.md) before the gate.
- The gate was a named human's decision, recorded with identity and timestamp — never the agent's.
- Every enforced entry in the manifest carries evidence it was tested by violation, in [materialization-assertions.md](references/materialization-assertions.md)'s form; every demotion has a matching profile gap entry.
- Nothing was written outside the declared target set, and nothing another practice owns was touched.
- The profile gained facts (elicited, verified, or demoted) and lost none — every write used add/confirm/supersede/retire.
- The manifest and adoption record together let a different agent, with no memory of this run, re-enter the practice correctly.
