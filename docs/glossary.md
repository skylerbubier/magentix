*[Magentix](../README.md) › Glossary*

# Glossary

Every named term across the five bodies of work this repository gathers, in one alphabetized place.
Where two documents use the same word compatibly, it is defined once with both users noted. Where
two documents use the same word for genuinely different things, that is called out explicitly —
look for **Disambiguation** below the definition.

---

## A

**Adoption order** — a blueprint's own stated sequencing of its elements. Where a blueprint names one,
elicitation and materialization follow it rather than diagram order.
[`adoption/02-blueprint-contract.md`](../adoption/02-blueprint-contract.md)

**Adoption record** — `adoption-record.md`, written at the end of a run: what was instantiated, what
was deferred and why, what conflicted and how it resolved, what was demoted from enforced to
asserted, and which profile facts the run touched. Distinct from the **run record**, which holds only
what belongs to the run rather than to the profile collection.
[`adoption/01-loop.md`](../adoption/01-loop.md)

**ADR (Architecture Decision Record)** — a Tier-1 spec artifact carrying mandatory machine
front-matter: `id`, `status` (proposed/accepted/superseded), `scope` (path globs), `supersedes`,
`enforcement` (`advisory` or `blocking`), and an optional `expires`. Only `blocking` ADRs compile into
a check; applicability resolves by scope glob with newest-supersession-wins precedence, never by
similarity search. Without the front-matter an ADR is documentation; with it, it is a control.
[`blueprints/ai-sdlc/spec-recipe.md`](../blueprints/ai-sdlc/spec-recipe.md)

**ALLOWED** — the AI-SDLC's repo-wide mutable source allowlist; a declared write-set must be a subset
of it. [`blueprints/ai-sdlc/subsystems.md`](../blueprints/ai-sdlc/subsystems.md)

**Artifacts** (role) — generated agent instructions, preferences, styles, and checks. Owned by
nobody, because they are regenerable from a blueprint and a profile; they change whenever either
input changes. See [`architecture.md`](architecture.md#artifacts).
[`adoption/README.md`](../adoption/README.md)

**Asserted vs. enforced** — the load-bearing split applied throughout the corpus. *Asserted*: a
document an agent or person is asked to honor, checked by nothing. *Enforced*: a mechanism that fails
closed when violated, and must name itself to claim the label. Used identically by the adoption
loop's invariant 3, the agent-context-kit's "preference layer vs. enforcement layer," the project
profile's capability inventory, and the AI-SDLC's "guidance layer vs. control" — one concept, four
vocabularies.
[`adoption/01-loop.md`](../adoption/01-loop.md) · [`blueprints/agent-context-kit/README.md`](../blueprints/agent-context-kit/README.md) · [`profiles/project/03-capability-inventory.md`](../profiles/project/03-capability-inventory.md)

**Audience** — a field name reused with different enumerations. In a **blueprint reading** it is
`individual | team | org | derived-per-element` (who authored the element). In a **profile reading**
it is `individual | shared` (whose truth the profile holds). **Disambiguation:** these are not the
same scale — a blueprint's `audience` describes authorship of a proposal; a profile's `audience`
describes ownership of a collection. Pairing derives from matching one against the other.
[`adoption/02-blueprint-contract.md`](../adoption/02-blueprint-contract.md) · [`adoption/05-profile-contract.md`](../adoption/05-profile-contract.md)

**Authority** — used for related but distinct things. A user criterion's `authority` category
records what *this person* delegates, never a grant belonging to someone else. A project fact's
`authority` field records *who can change the fact*, as distinct from its `owner` (who keeps it
current) — the two diverge whenever a gate's owner isn't the person who staffs it. The
agent-context-kit's "Decision authority & constraints" section is the same delegation concept applied
to a person's principal file.
[`profiles/user/01-criterion-format.md`](../profiles/user/01-criterion-format.md) · [`profiles/project/01-fact-format.md`](../profiles/project/01-fact-format.md)

**Autonomy vocabulary** — five levels a person names per class of action in the Interaction Protocol:
`observer` (report only), `consultant` (recommend, human decides), `collaborator` (act, check in),
`approver` (ask before acting), `operator` (act and inform after). These express a preference *within*
what is already permitted; none of them loosens an enforced constraint.
[`blueprints/agent-context-kit/templates/02-interaction-protocol.md`](../blueprints/agent-context-kit/templates/02-interaction-protocol.md)

---

## B

**B0–B10 (the stages)** — the adoption loop's named stages, in order: **B0** Blueprint Reading ·
**B1** Profile Reading & Verification · **B2** Elicitation · **B3** Reconciliation · **B4** Spec
Authoring · **B5** Spec Validation (script) · **B6** Approval Gate · **B7** Freeze (script, the
pivot) · **B8** Materialization · **B9** Verification · **B10** Manifest & Handoff.
[`adoption/01-loop.md`](../adoption/01-loop.md)

**Blocker triage — Class A/B/C** — the AI-SDLC's deterministic classification of a mid-implementation
surprise, tested by write-set arithmetic, not judgment: **A** — the write fits the declared plan,
continue for free. **B** — outside the plan but no frozen spec artifact affected, re-plan only,
branch and completed work survive. **C** — a frozen artifact must change, hard stop to escalation and
a thaw. The hook is the classifier; no model decides the class.
[`blueprints/ai-sdlc/subsystems.md`](../blueprints/ai-sdlc/subsystems.md)

**Blueprint** (role) — documents proposing how some kind of work should be done, normative and
general, owned by its author elsewhere. Read-only, always, in every stage of the loop without
exception. See [`architecture.md`](architecture.md#blueprint).
[`adoption/README.md`](../adoption/README.md)

**Blueprint fidelity (B assertions)** — see **Validation assertion families**.

---

## C

**Cadence** — a change-frequency field appearing on both a blueprint element (how often the blueprint
expects it to change) and a project fact category (release rhythm, environments, promotion order,
risk tier). Compatible sense — "how often this changes" — applied at two different altitudes.
[`adoption/02-blueprint-contract.md`](../adoption/02-blueprint-contract.md) · [`profiles/project/01-fact-format.md`](../profiles/project/01-fact-format.md)

**Capability vs. convention vs. instrumentation** — the project profile's central distinction. A
**capability** is a mechanism that fails closed on its own, without a person choosing to comply — the
test is "name what happens when somebody violates it." A **convention** is what people follow because
they agreed to; nothing checks it, and it is recorded only as a pointer to where it is stated. An
advisory check that runs and reports but does not block is neither — it is recorded explicitly as
**instrumentation**, because reporting is not enforcement.
[`profiles/project/03-capability-inventory.md`](../profiles/project/03-capability-inventory.md)

**Category enums (the two)** — user profile categories: `identity`, `priority`, `authority`,
`interaction`, `context`, `non-goal`, `correction`, `harness`. Project profile categories: `identity`,
`stack`, `interface`, `capability`, `authority`, `convention`, `constraint`, `cadence`, `harness`.
Both let a generator select a slice without reading the whole collection; they do not overlap in
scope (personal vs. project) even where a name repeats (`identity`, `authority`, `harness`).
[`profiles/user/01-criterion-format.md`](../profiles/user/01-criterion-format.md) · [`profiles/project/01-fact-format.md`](../profiles/project/01-fact-format.md)

**CLAIMED** — paths already owned by another live practice on this project. Disjoint from `DECLARED`,
always. [`adoption/01-loop.md`](../adoption/01-loop.md)

**Completeness (C assertions)** — see **Validation assertion families**.

**Confidence** — a normalized field the loop derives when reading any profile format: `strong`
(observed, measured, verified by test, or from an actual correction), `moderate` (stated by its
owner, or read from config untested), `weak` (inferred or assumed). It maps onto a user criterion's
`source` field and a project fact's `verification.method`, which express the same idea in each
collection's own vocabulary.
[`adoption/05-profile-contract.md`](../adoption/05-profile-contract.md)

**Conflict** — one word, three technical senses, and disambiguating them is the point of listing it
here. (1) As a **disposition** (B3): a profile fact is incompatible with a blueprint element, or two
facts contradict — this blocks the gate and needs a human decision, not a generated file. (2) As an
**elicitation recording category**: the adopter's own answers reveal an incompatibility during
elicitation, recorded with both sides and what a resolution would require. (3) As an entry in a
**profile reading's `conflicts` list**: contradictions the profile format itself already flags,
surfaced as an input rather than resolved automatically. All three feed the same human decision, but
they are produced at different stages by different mechanisms and should not be conflated when
tracing a spec entry back to its cause.
[`adoption/01-loop.md`](../adoption/01-loop.md) · [`adoption/03-elicitation.md`](../adoption/03-elicitation.md) · [`adoption/05-profile-contract.md`](../adoption/05-profile-contract.md)

**Consistency (S assertions)** — see **Validation assertion families**.

**Containment (N assertions)** — see **Validation assertion families**.

**Context rot** — the failure that results from mixing volatility and authorship axes in one
document: slow-changing facts get buried next to a running scratchpad, so nobody trusts either one.
Named as the reason the agent-context-kit splits its four files by those two axes rather than by
topic. [`blueprints/agent-context-kit/README.md`](../blueprints/agent-context-kit/README.md)

**Criterion** — the user profile's unit: one fact about a person, in its own file, with its own date,
source, and rationale. Analogous to a project **fact**, but personal-scope and mostly unobservable.
[`profiles/user/01-criterion-format.md`](../profiles/user/01-criterion-format.md)

---

## D

**Decision** (elicitation) — see **Elicitation recording taxonomy**.

**DECLARED** — a write-set that a reviewable, gated artifact commits to before it may write anything.
Used compatibly in two systems at different granularity: in the adoption loop, the set of *target
paths* `practice-spec.md` says it will write, checked against `CLAIMED` and `PROTECTED`. In the
AI-SDLC, the set of *source paths* `plan.md` declares it will touch, checked against `FROZEN` and
`ALLOWED`. Same mechanism — a declared write-set that a script enforces — applied to a practice's
target paths versus a change's source paths.
[`adoption/01-loop.md`](../adoption/01-loop.md) · [`blueprints/ai-sdlc/subsystems.md`](../blueprints/ai-sdlc/subsystems.md)

**Default taken** — see **Elicitation recording taxonomy**.

**Deferred** — a disposition (B3): the element applies but not now, recorded with a revisit trigger.
The same word labels a row in the **drift-check** report (`DEFERRED <element> trigger: <condition>`)
when that trigger fires — the disposition and the drift-check row describe the same lifecycle event
at two different points in time, not two different meanings.
[`adoption/01-loop.md`](../adoption/01-loop.md) · [`adoption/checks/drift-check.md`](../adoption/checks/drift-check.md)

**Disposition (the six)** — the classification every blueprint element receives in reconciliation
(B3): **Satisfied** (already covered — point at it, generate nothing), **Partial** (covered in part
or stale — extend in place, never fork), **Absent** (nothing covers it — create), **Conflict** (stop;
needs a human decision), **Not applicable** (record why, so it isn't mistaken for an oversight later),
**Deferred** (applies, not now — record the revisit trigger).
[`adoption/01-loop.md`](../adoption/01-loop.md)

**Divergence** — see **Elicitation recording taxonomy**.

**"Done" (pinned meaning)** — explicitly disambiguated in its own source: means *this file's*
completion report — how completion is communicated. Whether a piece of work actually qualifies as
complete is decided by the task's own acceptance criteria, a different and unrelated judgment.
[`blueprints/agent-context-kit/templates/02-interaction-protocol.md`](../blueprints/agent-context-kit/templates/02-interaction-protocol.md)

**Drift states** — the rows a drift check can report: **DRIFTED** (a materialized file's hash no
longer matches the manifest — reconcile before regenerating), **MISSING** (in the manifest, not on
disk — treat as a deletion to reconcile), **REVIEW DUE** (a review date elapsed), **REVIEW SOON** (a
review date falls within the `-WithinDays` window without having elapsed yet — informational only,
not one of the loop's re-entry triggers, unlike `REVIEW DUE`), **STALE** (the blueprint changed since
it was read), **PROFILE STALE** (the profile changed since it was read), **DEFERRED** (a deferral
trigger fired), **OK** (artifact matches). Note that `STALE`/`PROFILE STALE` here are source-version
drift at the *reading* level — a different sense from a fact's own **freshness** value of `stale`
(see below).
[`adoption/checks/drift-check.md`](../adoption/checks/drift-check.md)

---

## E

**Elicitation recording taxonomy** — how every exchange during elicitation is classified before it is
written anywhere: **Decision** (the adopter chose — carries the choice, a rationale, the slot, the
date), **Default taken** (no preference expressed, a default applied — carries the default and its
source), **Open question** (unresolved — blocking or non-blocking, and what would resolve it),
**Divergence** (the adopter chose against the blueprint — carries both positions and the reason),
**Conflict** (a recorded fact is incompatible with an element, or two facts contradict — see the
**Conflict** entry for how this differs from the B3 disposition of the same name).
[`adoption/03-elicitation.md`](../adoption/03-elicitation.md)

**Engine** (role) — the Adoption Loop itself: compiles a blueprint against a profile. Owned by
nobody in particular, changes rarely. See [`architecture.md`](architecture.md#engine).
[`adoption/README.md`](../adoption/README.md)

**Enforcement mechanism** — the named thing that fails closed, required on every entry marked
`enforced`; an entry that cannot name one is demoted to asserted, on the record.
[`adoption/01-loop.md`](../adoption/01-loop.md)

**Environment** — not a role and not a third input: what can be read off disk right now. How profile
facts get verified, and how a profile finds out it has drifted.
[`adoption/01-loop.md`](../adoption/01-loop.md)

**"Escalation" (pinned meaning)** — explicitly disambiguated in its own source: means surfacing
something to *you*, the person — pausing to bring a human in. It is not a stage in any workflow and
does not mean routing an issue up a process (the sense the word would have in an incident-routine
blueprint, for instance).
[`blueprints/agent-context-kit/templates/02-interaction-protocol.md`](../blueprints/agent-context-kit/templates/02-interaction-protocol.md)

---

## F

**`fails_closed`** — the property that makes a mechanism a capability rather than a convention:
denies on its own, without a person choosing to comply. Recorded as a boolean on both a profile
reading's `capabilities` list and a project fact's capability `detail`, always paired with `bypass`
(how it can be circumvented, or "none") — an unrecorded bypass is called out as the single most
misleading thing the capability inventory can contain.
[`adoption/05-profile-contract.md`](../adoption/05-profile-contract.md) · [`profiles/project/03-capability-inventory.md`](../profiles/project/03-capability-inventory.md)

**Finalization gate** — the AI-SDLC's one human gate in Phase 1 (S6): reviews the target spec and its
validation report directly, never a summary, and confirms scope, breaking-change classifications, and
that no blocking question was silently closed. Enforced by CODEOWNERS plus branch protection.
Compare **Merge gate**, the equivalent at the far end of Phase 2.
[`blueprints/ai-sdlc/subsystems.md`](../blueprints/ai-sdlc/subsystems.md)

**Freshness** — a normalized field the loop derives when reading any profile: `fresh` (within its own
interval), `stale` (interval lapsed — **still used**, since discarding it means acting on nothing
instead), `unverified` (never confirmed — confirm before depending on it). This is a per-fact
confidence-decay signal, distinct from the drift-check's `STALE` rows, which describe an entire
blueprint or profile *reading* being out of date relative to its source, not one fact's own age.
[`adoption/05-profile-contract.md`](../adoption/05-profile-contract.md)

**FROZEN** — the exact source paths and SHA-256 hashes listed in `change-manifest.json` at the
moment of freeze; the write-set a plan must avoid.
[`blueprints/ai-sdlc/subsystems.md`](../blueprints/ai-sdlc/subsystems.md)

---

## G

**Gap list** — the capability inventory's record of controls a blueprint wanted and this environment
cannot provide: `want`, `why_unavailable`, `nearest_available`, `authority`, `requested`. It arrives
for free — every demotion from enforced to asserted produces a gap entry — and becomes a prioritized,
evidence-backed backlog of what the project's tooling is missing.
[`profiles/project/03-capability-inventory.md`](../profiles/project/03-capability-inventory.md)

---

## H

**Harness** — the agent tooling in use (Claude Code, Cursor, Codex, or another), named in exactly one
place per collection so that every criterion or fact outlives the tool it happens to be rendered for
today. [`profiles/user/03-harness-binding.md`](../profiles/user/03-harness-binding.md) · [`profiles/project/04-harness-binding.md`](../profiles/project/04-harness-binding.md)

**Harness binding** — the one bounded, agent-specific section per profile collection: names the tool,
its slots, their scope (`personal`/`shared`), and what it can actually enforce (`can_enforce` at
personal scope, `automation_fails_closed`/`automation_bypassable` at project scope). Migration is
edit-this-file-and-regenerate; no criterion or fact is ever touched.
[`profiles/user/03-harness-binding.md`](../profiles/user/03-harness-binding.md) · [`profiles/project/04-harness-binding.md`](../profiles/project/04-harness-binding.md)

**Honesty (H assertions)** — see **Validation assertion families**.

---

## I

**Instrumentation** — see **Capability vs. convention vs. instrumentation**.

---

## L

**Land / Load / Hold (the materialization-check families)** — three ordered questions run after
writing, none optional: **L** (did it land? — every declared path exists, its content matches, and
nothing outside the declared set was touched), **D** (does it load? — an asserted entry actually sits
where the harness reads it), **E** (does it hold? — every enforced entry is tested by *violating* it
and must produce a denial, or it is demoted on the record). A check that has never failed is not
known to be a check.
[`adoption/checks/materialization-check.md`](../adoption/checks/materialization-check.md)

**Lifecycle moves (the four, plus one)** — how any profile collection changes over time. Both
collections share **Add** (a new fact/criterion), **Supersede** (the old one kept and marked
superseded, a new one replaces it), **Retire** (marked retired with a reason, kept). The user profile
calls its third move **Confirm** (only the date changes); the project profile calls the equivalent
**Verify**, and adds a project-specific fifth move, **Re-verify** (re-run `verification.how` and
record what it showed — a correction the environment supplies without asking anyone). Nothing is ever
edited in place except a date, and nothing is ever deleted.
[`profiles/user/02-collection.md`](../profiles/user/02-collection.md) · [`profiles/project/02-collection.md`](../profiles/project/02-collection.md)

---

## M

**Manifest** — two distinct artifacts sharing the name. The adoption loop's **practice manifest**
(`practice-manifest.json`) records every materialized path with its hash, owner, nature, cadence,
review date, and traces — the whole maintenance mechanism. The AI-SDLC's **change manifest**
(`change-manifest.json`) records the frozen spec-artifact hashes and the declared write-set for one
change. Same idea — a hashed record of what a gate approved — applied to a practice versus a single
change.
[`adoption/04-materialization.md`](../adoption/04-materialization.md) · [`blueprints/ai-sdlc/subsystems.md`](../blueprints/ai-sdlc/subsystems.md)

**Materialization** — the APPLY-phase act of writing an approved spec's content to its declared
paths. Pure transcription: nothing is composed at write time, and a better idea arriving now goes
back to the spec, not into the file.
[`adoption/04-materialization.md`](../adoption/04-materialization.md)

**Merge gate** — the AI-SDLC's CI-only verdict layer (S15) at the end of Phase 2: re-hashes every
`FROZEN` path (the authoritative check that catches writes routed around hooks), asserts full
diff-entry coverage and declared-write-set containment, and runs the test suites. Only CI can pass it;
hooks can only ever say no.
[`blueprints/ai-sdlc/subsystems.md`](../blueprints/ai-sdlc/subsystems.md)

**Minimum viable spec** — the AI-SDLC's own concrete instance of a minimum viable subset: six
artifacts (`principles/architecture.md`, `decisions/` with front-matter, one interface-contract
format, `contracts/db/` migrations, `behavior/*.feature`, `operations/flags.yaml`) that give a
diffable surface for most changes before the rest of the seven tiers are built out.
[`blueprints/ai-sdlc/spec-recipe.md`](../blueprints/ai-sdlc/spec-recipe.md)

**Minimum viable subset** — the general concept a blueprint can name for itself: the starting subset
that should be adopted first, distinct from adopting everything at once. The AI-SDLC's **minimum
viable spec** is one blueprint's specific answer to this; the concept itself belongs to the blueprint
contract.
[`adoption/02-blueprint-contract.md`](../adoption/02-blueprint-contract.md)

**Mutability inversion** — the AI-SDLC's first invariant: while intent is uncertain, the spec is
mutable and source is read-only; the moment intent is settled, that inverts. There is no window in
which both are editable. The adoption loop's "drafting is wide, materialization is narrow" is the
same inversion applied to a practice instead of a code change.
[`blueprints/ai-sdlc/overview.md`](../blueprints/ai-sdlc/overview.md)

---

## N

**Not applicable** — see **Disposition**.

---

## O

**Open question** — see **Elicitation recording taxonomy**. The same idea appears structurally as the
`open` list in both a blueprint reading (what the blueprint does not decide) and a profile reading
(what the profile does not say) — the raw material elicitation resolves.
[`adoption/02-blueprint-contract.md`](../adoption/02-blueprint-contract.md) · [`adoption/05-profile-contract.md`](../adoption/05-profile-contract.md)

**`owns_paths`** — the field in a project's `practices.yaml` registry naming the paths one practice
exclusively owns; no other live practice may write them. The mechanism behind "a path belongs to
exactly one practice."
[`profiles/project/02-collection.md`](../profiles/project/02-collection.md)

---

## P

**Path collision** — the same path claimed by more than one practice, listed in the cross-project
index. Resolving one is a human decision about which practice owns the file; the others contribute
through paths it references. Never resolved by merging.
[`profiles/project/02-collection.md`](../profiles/project/02-collection.md)

**`PF-NNNN`** — the id format for a project fact (e.g. `PF-0117`), unique across the whole
cross-project collection, not per project.
[`profiles/project/01-fact-format.md`](../profiles/project/01-fact-format.md)

**Practice** — files, configs, and checks that exist at real paths, plus the record of why each is
the way it is. The sole *output* of the engine; owned by the adopter.
[`adoption/README.md`](../adoption/README.md)

**Practice id** — a short slug identifying one practice; the loop's workspace lives at
`adoption/{practice-id}/`, outside the blueprint, the profile, and the target locations.
[`adoption/_kit/INSTRUCTIONS.md`](../adoption/_kit/INSTRUCTIONS.md)

**Precedence** — used for three distinct orderings across the corpus. (1) The **loop's precedence**
(enforced controls > approved spec > recorded elicitation decisions > blueprint > agent judgment) —
see the Precedence section of [`architecture.md`](architecture.md#5--precedence). (2) The
**agent-context-kit's precedence** among its own four files when more than one is loaded at once:
more specific beats more general, the same "closest file wins" convention the AGENTS.md standard and
Claude Code's memory hierarchy use. (3) A harness binding's own `precedence` field, recording *how
that specific tool* resolves multiple loaded context sources, in the tool's own terms. All three
agree that an enforced control sits outside and above the ordering.
[`adoption/01-loop.md`](../adoption/01-loop.md) · [`blueprints/agent-context-kit/README.md`](../blueprints/agent-context-kit/README.md) · [`profiles/user/03-harness-binding.md`](../profiles/user/03-harness-binding.md)

**Preference layer vs. enforcement layer** — the agent-context-kit's framing of **asserted vs.
enforced** (see above) applied to its own four files: they are entirely a preference layer, and
deliberately not an enforcement layer, because nothing in them is checked by anything.
[`blueprints/agent-context-kit/README.md`](../blueprints/agent-context-kit/README.md)

**Profile** (role) — the durable, evolving collection of what is actually true for a person or
project, descriptive and specific, owned by the adopter. See
[`architecture.md`](architecture.md#profile).
[`adoption/README.md`](../adoption/README.md)

**Progressive disclosure** — keeping a context file thin by pushing real depth into its own linked
reference file, loaded only when a task needs it. Named as the agent-context-kit's organizing
principle for its four files, and reused identically for AI-SDLC skills (workflow in the body, rule
catalogs in `references/` loaded only at the step that needs them).
[`blueprints/agent-context-kit/README.md`](../blueprints/agent-context-kit/README.md) · [`blueprints/ai-sdlc/subsystems.md`](../blueprints/ai-sdlc/subsystems.md)

**PROTECTED** — paths the loop may never write: the blueprint, anything an existing control owns,
anything outside the adopter's authority.
[`adoption/01-loop.md`](../adoption/01-loop.md)

---

## R

**Rank** — the field a `priority`-category user criterion carries, because the whole value of a
priority is breaking ties without asking; an unranked set of priorities is just a list of things
somebody likes. [`profiles/user/01-criterion-format.md`](../profiles/user/01-criterion-format.md)

**READING** — the derived, structured view of either input: `blueprint-reading.yaml` or
`profile-reading.yaml`. Fixed shape, format-agnostic; the *content* is entirely the source's own
detail. [`adoption/01-loop.md`](../adoption/01-loop.md)

**Risk tier** — referenced repeatedly (a project profile's cross-project index records `risk_tier`;
the AI-SDLC derives a "risk-tiered gate" from a diff's blast radius) but its actual scale of values is
never enumerated anywhere in the corpus — see the note on undefined terms at the end of this
document. [`profiles/project/02-collection.md`](../profiles/project/02-collection.md)

**Run record** — `run-record.md`, the loop's own thin record of what belongs to *this run* rather
than to the profile: which fact ids were touched, which defaults were taken, what's still open, and
what conflicts blocked the gate. Contrast **Adoption record**.
[`adoption/01-loop.md`](../adoption/01-loop.md)

---

## S

**Scope** — the corpus's own flagged ambiguity, called out explicitly in its source. A user
criterion's `scope` is an applicability enum (`global | domain:<name> | task:<kind> |
stakes:<low|high>`). An ADR's `scope` is a list of path globs. The agent-context-kit's frontmatter
deliberately avoids the key `scope` and uses `applies_to` instead, *because* — in the
agent-context-kit's own words — "a bare `scope:` key... means different things in different schemas
(an audience here, a path glob elsewhere)," and a naive scanner selecting on it would eventually treat
somebody's personal notes as policy. **Disambiguation:** always check which document's `scope` is in
play before reading a value.
[`profiles/user/01-criterion-format.md`](../profiles/user/01-criterion-format.md) · [`blueprints/ai-sdlc/spec-recipe.md`](../blueprints/ai-sdlc/spec-recipe.md) · [`blueprints/agent-context-kit/README.md`](../blueprints/agent-context-kit/README.md)

**Seven spec tiers** — the AI-SDLC's docs-as-code layout: **Tier 1** Invariants (principles,
constraints, ADRs) · **Tier 2** Interface Contracts (OpenAPI, schemas, GraphQL, protobuf, DB
migrations, permissions, error taxonomy) · **Tier 3** Behavior (Gherkin, rules, journeys, state
machines, NFRs) · **Tier 4** Surface (design tokens, component/screen contracts, accessibility,
content) · **Tier 5** Operations (observability, flags, SLOs, runbooks, environments, dependencies) ·
**Tier 6** Change Workspace (the per-change ephemeral tree) · **Tier 7** Meta (the spec index,
`REVIEW.md`, the repo-scoped agent file, the agent config and state dirs).
[`blueprints/ai-sdlc/spec-recipe.md`](../blueprints/ai-sdlc/spec-recipe.md)

**Slot** — what a blueprint or a harness binding leaves for the adopter to fill. In a blueprint
reading, a slot is something the adopter must supply (`asks`, `blocking`). In a harness binding, a
slot is a named location a tool reads from or writes to (`always_loaded`, `on_demand`,
`presentation`/`project_context`, `automation`, `personal_overlay`, `agent_state`), each carrying a
`scope` of `personal` or `shared`. The two senses meet at materialization: an entry's content fills a
blueprint slot and lands in a harness slot.
[`adoption/02-blueprint-contract.md`](../adoption/02-blueprint-contract.md) · [`profiles/user/03-harness-binding.md`](../profiles/user/03-harness-binding.md) · [`profiles/project/04-harness-binding.md`](../profiles/project/04-harness-binding.md)

**Source** — the evidence-origin field, expressed differently by each profile. A user criterion's
`source` ranks `corrected` (strongest) > `observed` > `stated` > `inferred` (weakest — must be
confirmed before counting as more than a guess). A project fact's analogous field is
`verification.method`: `observed` > `pointer` > `asserted` > `untestable`. **Disambiguation:** these
are parallel but not identical scales — a project fact's `pointer` (authoritative elsewhere, no copy
held) has no equivalent on the user side, because a person's criteria are never "pointed at"
elsewhere.
[`profiles/user/01-criterion-format.md`](../profiles/user/01-criterion-format.md) · [`profiles/project/01-fact-format.md`](../profiles/project/01-fact-format.md)

**SPEC** — two different-scoped things sharing one name. In the adoption loop, `SPEC` is
`practice-spec.md`, one reviewable document for one practice. In the AI-SDLC, `SPEC` is the entire
docs-as-code tree (all seven tiers) shared across every change. **Disambiguation:** the adoption
loop's `SPEC` is a single artifact that gets approved and frozen once; the AI-SDLC's `SPEC` is a
persistent shared tree that a change's `target/` overlay proposes edits against.
[`adoption/01-loop.md`](../adoption/01-loop.md) · [`blueprints/ai-sdlc/subsystems.md`](../blueprints/ai-sdlc/subsystems.md)

**Stability** — a user criterion field: `provisional` (stated once, untested — treat as a starting
guess), `calibrating` (being actively tuned, expect change), `stable` (settled, long confirmation
interval). Distinct from **freshness**, which measures whether a fact was recently *checked* rather
than how *settled* it is.
[`profiles/user/01-criterion-format.md`](../profiles/user/01-criterion-format.md)

**"Stopped at a control"** — the fourth of four progress/completion states named in the Interaction
Protocol, alongside done, blocked, and uncertain-proceeding-anyway. Named separately because the
response differs: the agent hit something it is not *permitted* to do, not something it cannot figure
out. Not a failure to report apologetically and not a problem to route around — a decision that needs
the human, stating what was attempted, what stopped it, and what they would have to decide.
[`blueprints/agent-context-kit/templates/02-interaction-protocol.md`](../blueprints/agent-context-kit/templates/02-interaction-protocol.md)

---

## T

**Thaw ceremony** — the AI-SDLC's Class C recovery procedure (S13): the manifest's phase reverts to
`define` and its revision increments, the implementation branch is preserved (not deleted), the target
spec is amended, a new spec-diff is generated at the next revision, and **diff-of-diffs** salvage
compares the two diffs mechanically to decide which commits survive.
[`blueprints/ai-sdlc/subsystems.md`](../blueprints/ai-sdlc/subsystems.md)

**Diff-of-diffs** — the script that compares `spec-diff@rev1` to `spec-diff@rev2` after a thaw: an
unchanged entry means its tasks and commits stay valid; an added entry means new tasks; a
modified/removed entry means its tasks are invalidated and those commits are reverted. Pure set
arithmetic, no judgment call, made possible because every task recorded a `traces:` field from the
start. [`blueprints/ai-sdlc/subsystems.md`](../blueprints/ai-sdlc/subsystems.md)

**Three phases and the freeze** — the AI-SDLC's top-level shape: **Phase 1 — DEFINE** (spec mutable,
code read-only), the **FREEZE** (the pivot — spec snapshotted, hash written, phase flipped), **Phase
2 — BUILD** (spec frozen, code mutable within the declared write-set), **Phase 3 — PROMOTE** (on
merge, target becomes the new current, the diff and plan archive, the manifest clears).
[`blueprints/ai-sdlc/overview.md`](../blueprints/ai-sdlc/overview.md) · [`blueprints/ai-sdlc/subsystems.md`](../blueprints/ai-sdlc/subsystems.md)

**Traceability (T assertions)** — see **Validation assertion families**.

---

## U

**`UC-NNNN`** — the id format for a user criterion (e.g. `UC-0042`).
[`profiles/user/01-criterion-format.md`](../profiles/user/01-criterion-format.md)

---

## V

**Validation assertion families** — the six letter-prefixed groups `spec-validation.md` runs before
the gate: **T**raceability (every entry traces to a blueprint element or a recorded decision), **H**onesty
(no entry claims enforcement without a named failing-closed mechanism, confirmed as available and
tested), **C**ompleteness (no unfilled placeholder, no open blocking question, every entry named an
owner and a review date), **N** — **C**ontainment (no write outside declared paths or into another
practice's claim, no leaked tool name outside the harness binding), **S** — **C**onsistency (no two
entries state the same fact, no profile fact rewritten), **B**lueprint fidelity (no entry violates the
blueprint's own invariants or out-of-scope list, the minimum viable subset is respected).
[`adoption/checks/spec-validation.md`](../adoption/checks/spec-validation.md)

**Verification method** — a project fact's evidence-strength field: `observed` (read from the project,
`how` required), `pointer` (authoritatively stated elsewhere, no copy held), `asserted` (somebody said
so, unreadable), `untestable` (no way to establish it — justify or drop). Compare a user criterion's
parallel but non-identical `source` field (see **Source**).
[`profiles/project/01-fact-format.md`](../profiles/project/01-fact-format.md)

**Volatility and authorship** — the two axes the agent-context-kit splits its four files by, instead
of by topic: how often a file changes, and who writes it. Mixing these axes is named as the most
common cause of **context rot**.
[`blueprints/agent-context-kit/README.md`](../blueprints/agent-context-kit/README.md)

---

## W

**`W` (the write-set)** — in the AI-SDLC, the write-set required to resolve a given blocker, excluding
`AGENT-STATE`; the quantity blocker triage tests against `DECLARED`, `FROZEN`, and `ALLOWED` to derive
Class A/B/C. [`blueprints/ai-sdlc/subsystems.md`](../blueprints/ai-sdlc/subsystems.md)

**Weight** — a user criterion field expressing how strongly held a preference is, never how enforced
it is: `default` (deviate with a reason), `strong` (deviate only when the deviation is the point),
`firm` (do not deviate without asking). Even `firm` is still a request an agent is asked to honor —
nothing here widens what an agent is permitted to do.
[`profiles/user/01-criterion-format.md`](../profiles/user/01-criterion-format.md)

**WORKSPACE** — `adoption/{practice-id}/`, the loop's own files: always writable, never part of
`DECLARED`, never reviewed as output, and never a home for facts. A fact left here is a fact the next
adoption asks for again.
[`adoption/01-loop.md`](../adoption/01-loop.md)

---

## A note on terms used but never formally defined

**Risk tier** is the clearest case: both the project profile's cross-project index (`risk_tier: <as
recorded in cadence facts>`) and the AI-SDLC (a "risk-tiered gate," a diff that "declares its own
blast radius") rely on the concept as if its scale were already agreed, but no document in the corpus
enumerates the actual tier values (e.g. low/medium/high/critical) or the rule that assigns a change to
one. Anyone adopting either blueprint has to define this scale locally — it is not inherited from
either source. A related, softer case is **blast radius** itself: used descriptively (the AI-SDLC
overview, and a project fact's `interface` category calling itself "the cheapest blast-radius input
available") but never given a formal measurement method beyond "what a change touches."
