*[Magentix](../../README.md) › [Blueprints](../README.md) › [AI-SDLC](README.md) › Subsystems*

# Subsystem Reference

Every subsystem below states: who owns it, what it reads and writes, the concrete actions it performs, and what enforces it. Anything marked **script** or **hook** costs no tokens and is not subject to model judgment.

Vocabulary used throughout:

| Term | Meaning |
|---|---|
| `SPEC` | the docs-as-code tree (see [spec-recipe.md](spec-recipe.md)) |
| `FROZEN` | the exact paths + SHA-256 hashes listed in `change-manifest.json` |
| `DECLARED` | source paths `plan.md` declares it will write |
| `ALLOWED` | repo-wide mutable source allowlist |
| `AGENT-STATE` | paths holding the agent's own working state — continuity notes, scratch files, telemetry output. Always in `ALLOWED`, never in `FROZEN`, never required to be in `DECLARED`, and excluded from every write-set assertion. Not project content and not reviewable output. |
| `W` | the write-set required to resolve a given blocker, excluding `AGENT-STATE` |

---

## Phase 1 — DEFINE
*Spec is mutable. Source code is read-only. No implementation may begin.*

### S1 · Intake
- **Owner:** originator (any role) + agent · **Writes:** `changes/{id}/change-request.md`
- Accept a signal from any channel: idea, ticket, incident, scan finding, support theme.
- Assign `{id}`, commit the request with author and timestamp before any other work.
- Record the *problem*, not the solution. Solution shape belongs to S2.
- Resolve which service/area is affected; a request that cannot name one is rejected back to the originator.
- **Enforced by:** CI rejects a change directory without a committed `change-request.md`.
- **Exit:** request committed.

### S2 · Exploration & Refinement
- **Owner:** human + agent, conversational · **Reads:** `CURRENT SPEC` (read-only), codebase (read-only) · **Writes:** `TARGET SPEC`, decision ledger
- Agent interviews the human the way an analyst would: scope, users, constraints, failure modes, what is explicitly out of scope.
- Agent restates intent as concrete changes to spec artifacts, not prose. "Add a field" becomes an edit to a schema and a new Gherkin scenario.
- Every ambiguity becomes an entry in `open-questions.md`, marked blocking or non-blocking.
- Agent loads only the spec slices relevant to the change; it does not read the whole tree.
- **Enforced by:** hook denies all writes to source code paths while phase is `define`.
- **Exit:** target spec expresses the intent with no blocking questions open.

### S3 · Decision Ledger
- **Owner:** agent authors, human decides · **Writes:** `changes/{id}/open-questions.md`, `spec/decisions/ADR-NNN-{slug}.md`
- Open a question the moment an assumption is made; close it with an answer or an ADR.
- Promote a question to an ADR when the answer will outlive this change.
- Every ADR carries machine front-matter: `id`, `status`, `scope` (path globs), `supersedes`, `enforcement: advisory|blocking`, optional `expires`.
- **Enforced by:** ADR resolver script (S19) — deterministic precedence, newest supersession wins. Retrieval feeds the resolver; retrieval never votes.
- **Resolver selection is explicit, not positional.** A document is an ADR to the resolver only if it lives under `decisions/` *and* its front-matter carries both `id` and `enforcement`. Anything else with front-matter is ignored — a repo accumulates plenty of Markdown with metadata blocks, and `scope` in particular is a field other schemas use with entirely different semantics. The resolver must never treat a foreign document as policy because a key name happened to match.
- **Exit:** zero blocking questions.

### S4 · Target Spec Authoring
- **Owner:** agent · **Writes:** `changes/{id}/target/**` (an overlay of the spec tree)
- Edit contracts, schemas, Gherkin, principles, and NFR thresholds to describe the world *after* the change.
- Touch only artifacts the change actually alters. An untouched artifact is inherited from current by reference, never copied.
- Additive-first: prefer new versions and optional fields over mutation; record any breaking change explicitly.
- **Enforced by:** hook denies writes outside `changes/{id}/` during Phase 1 — the shared spec tree is never edited in place.
- **Exit:** S5 passes.

### S5 · Spec Validation *(script)*
- **Owner:** script · **Reads:** target overlay · **Writes:** validation report
- Parse and lint every artifact against its own grammar (OpenAPI, JSON Schema, Avro/Proto, GraphQL SDL, Gherkin).
- Run backward-compatibility checks per contract type; classify each change `additive | breaking`.
- Resolve applicable ADRs by scope glob; fail on any violation of an ADR marked `enforcement: blocking`.
- Check internal referential integrity: every Gherkin `Given` referencing an entity that exists, every error code declared, every flag declared.
- **Enforced by:** CI. Failure blocks the finalization gate.
- **Exit:** clean report.

### S6 · Finalization Gate *(the only human gate in Phase 1)*
- **Owner:** named human approver
- Review the *target spec* and the validation report. Do not review prose summaries of it.
- Confirm scope, breaking-change classifications, and that no blocking question was silently closed.
- Approve → triggers S7. Reject → back to S2 with a recorded reason.
- **Enforced by:** CODEOWNERS on the spec tree + branch protection.
- **Exit:** signed approval recorded with identity and timestamp.

---

## The FREEZE
*The pivot. Mutability inverts here.*

### S7 · Freeze & Manifest *(script)*
- Snapshot `CURRENT SPEC` at its exact commit.
- Write `changes/{id}/change-manifest.json`:
  ```json
  {
    "change_id": "chg-0142", "revision": 1, "phase": "build",
    "frozen": [ {"path": "...", "sha256": "..."} ],
    "declared_write_set": [],
    "finalized_by": "…", "finalized_at": "…"
  }
  ```
- Flip `phase` to `build`. Every hook and script reads phase from this file; it is the single source of truth for mutability.
- **Enforced by:** the manifest itself is frozen against its own hash.

### S8 · Diff Generation *(script — never a model)*
- Compute `changes/{id}/spec-diff/` from (current snapshot, target overlay) using **format-aware** diffs, not text diffs: OpenAPI diff, JSON Schema diff, Avro compatibility, GraphQL SDL diff, Gherkin scenario set-diff.
- Emit one entry per semantic change with a stable `diff-entry-id`, a classification (`additive | breaking | removal`), and the affected consumers.
- If a model generates this artifact, the entire determinism argument collapses. Keep it a script.
- **Exit:** diff committed and hashed into the manifest.

---

## Phase 2 — BUILD
*Spec is frozen. Source code is mutable, but only within the declared write-set.*

### S9 · Change Planning
- **Owner:** agent · **Reads:** frozen set + codebase · **Writes:** `changes/{id}/plan.md`
- Plan against the **diff**, not the full spec. The diff is the work list; current and target are reference.
- Every task carries `traces: [diff-entry-id...]`. This one field makes S10 and the Class C salvage possible.
- Declare the write-set: every source path the plan intends to touch, as globs.
- Name the verification command per task and its expected passing output.
- Order work so contract-producing changes land before consumers.
- **Exit:** S10 passes.

### S10 · Plan Validation *(script)*
- Assert every `diff-entry-id` is traced by at least one task. Untraced entries mean the plan silently dropped a requirement.
- Assert `DECLARED ∩ FROZEN = ∅` and `DECLARED ⊆ ALLOWED`.
- Reject a plan that declares an `AGENT-STATE` path. Those paths are always writable and are not part of the change; declaring one means the plan has confused its own notes with project content.
- Write `declared_write_set` back into the manifest so hooks can enforce it.
- **Enforced by:** CI. Blocks the implementation loop.

### S11 · Implementation Loop
- **Owner:** agent · **Writes:** source within `DECLARED` only
- Write the failing test first where the diff entry is behavioral; the Gherkin from the target spec is already that test.
- Implement, then self-verify: run the named commands and paste the output. Nothing is reported done without evidence from the toolchain.
- **The evidence requirement is not a style setting.** However terse the agent has been configured to be in conversation, the output that substantiates a "passing" claim is part of `verification.md` and is not summarized away. Brevity applies to commentary about the work, never to the record of its result.
- Iterate until the loop is green before any human or reviewer sees the work.
- **Enforced by:** hooks (below). A denial is not advice.

### S12 · Blocker Triage *(script + hook — the core mechanism)*

The write-set is the discriminator, and the hook is the classifier. No model decides the class.

| Class | Deterministic test | Meaning | Response | Cost |
|---|---|---|---|---|
| **A** | `W ⊆ DECLARED` | Resolution fits the plan | Continue in loop. Log it. No gate, no human. | free |
| **B** | `W ⊄ DECLARED` and `W ∩ FROZEN = ∅` and `W ⊆ ALLOWED` | The plan was wrong; the spec is still right | **Re-plan only.** Regenerate `plan.md` from the *same* frozen set. Branch and completed work survive untouched. | one planning pass |
| **C** | `W ∩ FROZEN ≠ ∅` | The spec itself is wrong or unachievable | **Hard stop → S13 escalation → thaw.** | full Phase-2 restart |

- Class A and B need no human. Only Class C escalates.
- Class B is the common case and is deliberately cheap — most surprises are planning errors, not contract errors, and treating them as contract errors is the expensive mistake.
- Every classification emits a telemetry event. The Class-B and Class-C rates are your two most valuable process metrics.

### S13 · Blocker Escalation & Thaw *(HITL — Class C only)*
- Human decides: amend the target spec, or abandon the change.
- On amend, the thaw ceremony runs:
  1. Manifest `phase` → `define`, `revision` += 1. The implementation branch is **preserved**, not deleted.
  2. Return to S2/S4. Amend the target spec; record the reason as an ADR if it is a real decision.
  3. Re-run S5, S6, S7, S8 → a **new spec-diff at revision 2**.
  4. **Diff-of-diffs salvage** *(script)* — compare `spec-diff@rev1` to `spec-diff@rev2`:
     - entry **unchanged** → tasks tracing to it stay valid; their commits survive
     - entry **added** → new tasks
     - entry **modified or removed** → tasks tracing to it are invalidated; those commits are reverted
  5. Re-plan (S9) seeded with the surviving task list.
- **Answering the design question directly:** the *plan* is always discarded and regenerated. The *code* is salvaged mechanically by set arithmetic on diff-entry traces — no judgment call. If the invalidated fraction exceeds a configured threshold (50% is a reasonable default), the script recommends abandoning the branch and the human confirms.

### S14 · Review
- Fresh-context agent review, report-only, against `REVIEW.md`: bugs, security, and **conformance to the diff** — the last one is the pass that catches an agent that built the wrong thing correctly.
- The reviewing agent must not be the authoring session. A verdict from the context that produced the code is not a verdict.
- Human review is risk-tiered, derived from the diff: a diff touching auth, payments, migrations, or anything an ADR marks `blocking` always gets a named human.
- The review report's required content is set by `REVIEW.md` — passes, severities, exclusions. That inventory does not shrink because the agent is configured to be brief; a report missing a pass is an incomplete review, not a concise one.
- Findings feed back to S11; a finding that is really a contract disagreement is escalated to S13, not patched around.

### S15 · Merge Gate *(CI — the verdict layer)*
- **Re-hash every path in `FROZEN` and compare to the manifest.** This is the authoritative freeze check, and it is what catches writes that routed around the hooks (a shell redirect is not a tool call).
- Assert every `diff-entry-id` has passing verification evidence.
- Assert no source file outside `DECLARED` was modified, disregarding `AGENT-STATE` paths.
- Run the full test suite, the Gherkin suite, and contract tests against real consumers.
- **Only CI can pass this gate.** Hooks can only ever say no.

---

## Phase 3 — PROMOTE

### S16 · Promotion *(script)*
- On merge to main: copy `changes/{id}/target/**` over the shared spec tree, so target becomes the new current.
- Archive `spec-diff/`, `plan.md`, `change-manifest.json`, and the verification record with the change.
- Clear the manifest, unfreeze, close the change.
- **Without this step the next change plans against a stale baseline and every subsequent diff is wrong.** It is the most commonly forgotten edge in this design.

### S17 · Telemetry & Feedback Capture
- Emit per change: token cost by phase and by skill, wall-clock per phase, Class-A/B/C blocker counts, diff size, first-pass merge rate, review findings by severity.
- Every Class C blocker becomes an eval case — it is direct evidence that the definition phase produced an unachievable spec.
- Every escaped production defect becomes a Gherkin scenario in the spec, permanently.

---

## Control Plane
*Spans all phases. Costs no tokens.*

### S18 · Hooks — fast local feedback
| Event | Rule |
|---|---|
| `SessionStart` | Load `change-manifest.json`; inject phase, frozen paths, declared write-set into context. The agent knows the rules before it acts. |
| `PreToolUse` (any) | path ∈ `AGENT-STATE` → **allow unconditionally**, evaluated before every rule below. The agent's own note-taking is never a policy event. |
| `PreToolUse` (edit/write tools) | `phase == define` and path ∈ source → **deny** |
| `PreToolUse` (edit/write tools) | `phase == build` and path ∈ `FROZEN` → **deny**, emit `blocker.class=C` |
| `PreToolUse` (edit/write tools) | `phase == build` and path ∉ `DECLARED` → **deny**, emit `blocker.class=B` |
| `PreToolUse` (shell) | deny obvious write patterns targeting the spec tree — partial coverage only, which is why S15 exists |
| `PostToolUse` | format, lint, and re-validate the touched artifact's grammar |

Hooks are deny-only by design. Silence never approves. Treat any PR editing the hook directory as a policy change, because it is one.

**Deny-only has a corollary about configuration.** Every agent also runs with instruction files and preference configuration — how verbose to be, when to ask before acting, what it may decide alone. None of that can lift a denial, and no denial should be phrased as though it were negotiable guidance. A denial is a fact the agent reports: what it attempted, which rule stopped it, and what a human would have to decide. Configuration is free to make the agent *more* cautious than these rules; the rules are the floor it cannot go under.

### S19 · Scripts
`diff-gen` · `spec-validate` · `plan-validate` · `adr-resolve` · `blocker-triage` · `diff-of-diffs` · `promote` · `manifest-verify`. Version-controlled, unit-tested, and callable from both the hooks and CI so local and remote verdicts cannot disagree.

### S20 · CI Checks
The only layer with authority to pass anything. Runs `manifest-verify`, `spec-validate`, `plan-validate`, diff-entry coverage, the test suites, and the eval suite.

### S21 · Agent Config & Evals
- Skills use progressive disclosure: workflow in the body, rule catalogs in `references/` loaded only at the step that needs them.
- Route models by step — mechanical work (validation orchestration, indexing, status sync) on the cheapest tier; authoring and review on the frontier tier; codebase exploration in subagents that return a paragraph rather than a transcript.
- Each phase is a session boundary. Do not carry one session across the freeze. The boundary is on *retained context*, not on written state: anything the next phase needs must exist in an artifact or in the agent's own working notes before the current session ends. A fresh session is the point, and it only works if the handoff was written down.
- An eval suite of 20–50 real past changes runs on every modification to skills, hooks, or settings, and gates them on pass rate. The config that steers the agent gets the regression testing that code gets.
