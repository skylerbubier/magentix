*[Magentix](../../README.md) › [Blueprints](../README.md) › [AI-SDLC](README.md) › Spec Recipe*

# The Docs-as-Code Recipe

The full inventory of what lives in the specification plane. This is the artifact set that gets frozen, diffed, and planned against.

**Selection rule:** prefer a machine-native format over prose every time one exists. Prose is the fallback for things no grammar can express, not the default. The value of this whole design comes from the diff being computable, and you can only diff what has a grammar.

**Layout convention** — one tree, mirrored per change as an overlay:

```
spec/                      # shared, promoted state ("current")
  principles/
  constraints/
  decisions/
  contracts/
  behavior/
  operations/
  INDEX.yaml
changes/{change-id}/
  change-request.md
  open-questions.md
  target/                  # sparse overlay — only artifacts this change alters
  spec-diff/               # generated
  plan.md
  change-manifest.json
  verification.md
```

---

## Tier 1 — Invariants
*Changes rarely. Applies across the whole solution. Mostly prose, because judgment does not have a grammar — but scoped so a resolver can select it.*

| Artifact | Format | Validated by | Notes |
|---|---|---|---|
| `principles/architecture.md` | prose + explicit rules | ADR resolver where rules are path-scoped | Layering, dependency direction, boundary ownership |
| `principles/api-design.md` | prose + linter config | spectral / API linter | Pagination, versioning, naming, idempotency |
| `principles/security.md` | prose + policy refs | SAST config, hooks | Authn/authz posture, secret handling, logging rules |
| `principles/data.md` | prose + classification table | schema annotation check | Classification tiers, retention, residency, PII handling |
| `principles/testing.md` | prose | — | What must be unit vs contract vs behavioral; coverage floors |
| `constraints/*.md` | prose, one file per constraint | — | Non-negotiables: regulatory, cost ceilings, banned dependencies, supported platforms |
| `decisions/ADR-NNN-{slug}.md` | prose **+ machine front-matter** | ADR resolver (deterministic precedence) | See below — this is the load-bearing one |

**ADR front-matter is mandatory.** Without it an ADR is documentation; with it, it is a control.

```yaml
---
id: ARCH-014
status: accepted            # proposed | accepted | superseded
scope: ["services/auth/**", "libs/token/**"]
supersedes: ARCH-009
enforcement: advisory       # advisory | blocking
expires: 2027-03-01         # blocking ADRs should carry one
---
```

Most ADRs stay `advisory` and only shape agent context. Only `blocking` ones are compiled into a check. Applicability resolves by scope glob with newest-supersession-wins precedence — never by similarity search, because if two decisions cover the same subsystem the newer must win every time, not when its embedding happens to rank higher.

**The resolver selects on `id` + `enforcement` under `decisions/`, and on nothing else.** Front-matter is a popular convention and a repo accumulates plenty of unrelated Markdown carrying it; `scope` especially is a key other schemas use to mean something entirely different — an audience, a visibility level, a deployment target. Requiring both keys, in one location, keeps every foreign metadata block inert. A resolver that treats any file with a `scope:` field as policy will eventually enforce somebody's personal notes.

---

## Tier 2 — Interface Contracts
*The core of the design. Every one has a native grammar, a linter, and a compatibility checker. This is where the diff earns its keep.*

| Artifact | Format | Diff tool class | Breaking-change rule |
|---|---|---|---|
| `contracts/http/*.openapi.yaml` | OpenAPI 3.1 | OpenAPI diff | Removing a field/endpoint, tightening a type, adding a required request field |
| `contracts/events/*.avsc` \| `*.proto` \| `*.asyncapi.yaml` | Avro / Protobuf / AsyncAPI | schema-registry compat check | Per the registry's compatibility mode; default to BACKWARD |
| `contracts/graphql/*.graphql` | SDL | GraphQL inspector | Removing a field, changing nullability, narrowing a union |
| `contracts/rpc/*.proto` | Protobuf | buf breaking | Field renumbering, type change, removal without reservation |
| `contracts/data/*.schema.json` | JSON Schema | JSON Schema diff | New required property, removed property, narrowed enum |
| `contracts/db/migrations/*` + `data-model/*.dbml` | DDL + DBML | migration linter | Destructive DDL, non-nullable column without default, index drop |
| `contracts/auth/permissions.yaml` | YAML matrix | schema-validated | Any scope/role removal or permission widening |
| `contracts/errors/taxonomy.yaml` | YAML | schema-validated | Removing or repurposing an error code |
| `contracts/external/{system}/*` | native format of the far side | compat check where possible | Anything the other party has not agreed to |
| `contracts/config/*.schema.json` | JSON Schema | schema diff | New required config with no default |

**Versioning convention:** `{name}-v{N}.{ext}`. Parallel versions coexist; removal of an old version is its own change with its own diff entry.

---

## Tier 3 — Behavior
*What the system does, in a form that executes.*

| Artifact | Format | Validated by | Notes |
|---|---|---|---|
| `behavior/{domain}/*.feature` | Gherkin | parser + the runner itself | The acceptance criteria and the test are the same file. This is the single highest-value artifact in the tree. |
| `behavior/{domain}/rules.md` | prose | — | Business rules the scenarios formalize; the parts not obvious from the scenarios alone |
| `behavior/journeys/*.md` | prose + step refs | link check | End-to-end user journeys stitching scenarios together |
| `behavior/state-machines/*.yaml` | YAML (states, transitions, guards) | schema + reachability check | Lifecycle states; catches unreachable and terminal-trap states mechanically |
| `behavior/nfr/*.yaml` | YAML thresholds | assertable in CI | Latency budgets, throughput, availability targets — as numbers, not adjectives |

Gherkin discipline that makes this work:
- One scenario per acceptance criterion, with a stable tag ID (`@AC-0142-03`) so diff entries and plan tasks can trace to it.
- Every scenario names its level: `@unit`, `@contract`, `@e2e`, `@manual`.
- A scenario nothing can execute is a defect in the scenario. State the proving mechanism or don't write it.
- Negative and error paths are required wherever a failure mode exists; their absence is stated explicitly rather than left silent.

---

## Tier 4 — Surface
*Only where the solution has a user-facing surface.*

| Artifact | Format | Notes |
|---|---|---|
| `surface/design-tokens.json` | JSON | Colors, spacing, type scale — diffable, unlike a design file |
| `surface/components/*.md` | prose + prop tables | Component contracts: props, states, variants |
| `surface/screens/*.md` | prose + refs | Screen composition, referencing components and `@AC` tags |
| `surface/accessibility.md` | prose + rule list | Conformance target and the checks that enforce it |
| `surface/content/*.yaml` | i18n key/value | Copy as data; diffable, translatable, reviewable |

Design files (Figma and similar) stay where they are and are *referenced* by URL and version. Do not try to make a design tool a doc-as-code artifact; extract the tokens and the component contract instead.

---

## Tier 5 — Operations
*What running the thing requires. Frequently omitted, and the omission shows up as an incident.*

| Artifact | Format | Notes |
|---|---|---|
| `operations/observability.yaml` | YAML | Required metrics, log fields, trace spans per service. Makes "did we instrument it" a diff entry rather than an afterthought |
| `operations/flags.yaml` | YAML | Flag key, scope, default per environment, owner, **expiry date or condition**, cleanup entries |
| `operations/slo.yaml` | YAML | Objectives and error budgets; feeds control-band monitoring |
| `operations/runbooks/*.md` | prose | One per failure mode; referenced from alerts |
| `operations/environments.yaml` | YAML | Environments, promotion order, what differs |
| `operations/dependencies.yaml` | YAML | Upstream/downstream services and owners — the cheapest blast-radius input you will get |

---

## Tier 6 — Change Workspace
*Per-change, ephemeral, archived on promotion.*

| Artifact | Written by | Frozen? |
|---|---|---|
| `change-request.md` | human + agent (S1) | no |
| `open-questions.md` | agent (S3) | no |
| `target/**` | agent (S4) | **yes**, at freeze |
| `change-manifest.json` | script (S7) | **yes** |
| `spec-diff/**` | script (S8) | **yes** |
| `plan.md` | agent (S9) | no — regenerated on Class B and C |
| `verification.md` | agent (S11) | no |

---

## Tier 7 — Meta

| Artifact | Purpose |
|---|---|
| `spec/INDEX.yaml` | Machine-readable map: artifact → owner → validator → format → tier. Lets scripts and agents locate the relevant slice without walking the tree, which is a direct token saving |
| `REVIEW.md` (per code repo) | Review passes, severity definitions, nit cap, exclusions |
| `AGENTS.md` / `CLAUDE.md` (per code repo) | **Repo-scoped** conventions, commands, architecture, and recurring repo-level mistakes. About a page. See the scoping note below |
| agent config dir — `.agent/`, `.claude/`, or the harness equivalent (skills, subagents, hooks, settings) | The control plane config, version-controlled and eval-gated |
| agent state dir (`AGENT-STATE`) | Where the agent keeps continuity notes, scratch files, and telemetry output. Always writable, never frozen, never part of a change, never reviewed. Declare its paths once so the write rules can exempt them |

**Scoping the per-repo agent file.** That file is inherited by everyone who works in the repo, which fixes what belongs in it: facts about *this repo* that every contributor and every agent session needs. Three things do not belong in it, each for a different reason:

- **Spec content.** It is not diffable, not frozen, and not validated. A contract stated there is a contract with no compatibility check.
- **Rules a script or hook already enforces.** The copy in prose is the one that goes stale, and an agent reading a stale rule behaves worse than one reading none.
- **Individual preference** — how verbose to be, how much autonomy someone extends, what one person is optimizing for. That is per-person, changes on a different clock, and does not belong in a file the whole team inherits. Whatever layer owns it, this is not that layer.

"Recurring mistakes" in this file means the repo-level kind: a build step people keep missing, a directory that is generated and keeps getting hand-edited. A running log of what went wrong in one session is working state, not a repo convention, and it lives in the agent state dir until it either recurs enough to become a convention here or ages out.

---

## Minimum viable spec

Do not build all seven tiers before starting. A team can run this design with six artifacts and add the rest as the need proves itself:

1. `principles/architecture.md`
2. `decisions/` with front-matter (even if it starts with three ADRs)
3. `contracts/http/` **or** whichever interface format the solution actually exposes
4. `contracts/db/` migrations
5. `behavior/{domain}/*.feature`
6. `operations/flags.yaml`

Those six give you a diffable surface for the majority of changes. Everything above is the direction to grow in, ordered by how often its absence causes rework.

---

## Two rules that keep the tree healthy

**One home per fact.** An artifact that restates another is a future contradiction. Downstream artifacts reference upstream IDs; they never copy content. This is what keeps the diff meaningful — a duplicated fact produces two diff entries for one change, or worse, one.

**Every artifact names its validator.** If nothing can check it, it cannot be part of the frozen set in any meaningful sense, and it should be demoted to a reference note rather than pretending to be a contract.
