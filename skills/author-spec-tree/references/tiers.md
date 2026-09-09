# The Seven Tiers — Lookup Table

*Normative original: [${CLAUDE_PLUGIN_ROOT}/blueprints/ai-sdlc/spec-recipe.md](${CLAUDE_PLUGIN_ROOT}/blueprints/ai-sdlc/spec-recipe.md). Load this file only when a given tier is actually being touched — that is the progressive-disclosure pattern the recipe itself prescribes.*

**Selection rule, stated once and true for every tier below:** prefer a machine-native format over prose whenever one exists. Prose is the fallback for what no grammar can express, not the default — the diff is only computable for what has a grammar.

## Tier 1 — Invariants
*Changes rarely. Applies across the whole solution. Mostly prose, because judgment has no grammar — but scoped so a resolver can select it.*

| Artifact | Format | Validated by | Notes |
|---|---|---|---|
| `principles/architecture.md` | prose + explicit rules | ADR resolver where rules are path-scoped | Layering, dependency direction, boundary ownership |
| `principles/api-design.md` | prose + linter config | spectral / API linter | Pagination, versioning, naming, idempotency |
| `principles/security.md` | prose + policy refs | SAST config, hooks | Authn/authz posture, secret handling, logging rules |
| `principles/data.md` | prose + classification table | schema annotation check | Classification tiers, retention, residency, PII handling |
| `principles/testing.md` | prose | — | What must be unit vs contract vs behavioral; coverage floors |
| `constraints/*.md` | prose, one file per constraint | — | Non-negotiables: regulatory, cost ceilings, banned dependencies, supported platforms |
| `decisions/ADR-NNN-{slug}.md` | prose **+ machine front-matter** | ADR resolver (deterministic precedence) | The load-bearing artifact in this tier — see ADR front-matter below |

**ADR front-matter is mandatory** — without it an ADR is documentation; with it, it is a control:

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

Most ADRs stay `advisory` and only shape agent context; only `blocking` ones compile into a check. Applicability resolves by scope glob with newest-supersession-wins precedence — never by similarity search, because when two decisions cover the same subsystem the newer must win every time, not when its embedding happens to rank higher. **The resolver selects only on `id` + `enforcement` under `decisions/`, and on nothing else** — a repo accumulates plenty of unrelated Markdown carrying front-matter, and `scope` in particular is a key other schemas use to mean something else entirely (an audience, a visibility level, a deployment target). A resolver that treats any file with a `scope:` field as policy will eventually enforce somebody's personal notes.

## Tier 2 — Interface Contracts
*The core of the design. Every one has a native grammar, a linter, and a compatibility checker — this is where the diff earns its keep.*

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

**Versioning convention:** `{name}-v{N}.{ext}`. Parallel versions coexist; removing an old version is its own change with its own diff entry.

## Tier 3 — Behavior
*What the system does, in a form that executes.*

| Artifact | Format | Validated by | Notes |
|---|---|---|---|
| `behavior/{domain}/*.feature` | Gherkin | parser + the runner itself | The acceptance criteria and the test are the same file — the single highest-value artifact in the tree |
| `behavior/{domain}/rules.md` | prose | — | Business rules the scenarios formalize; the parts not obvious from the scenarios alone |
| `behavior/journeys/*.md` | prose + step refs | link check | End-to-end user journeys stitching scenarios together |
| `behavior/state-machines/*.yaml` | YAML (states, transitions, guards) | schema + reachability check | Lifecycle states; catches unreachable and terminal-trap states mechanically |
| `behavior/nfr/*.yaml` | YAML thresholds | assertable in CI | Latency budgets, throughput, availability targets — as numbers, not adjectives |

Gherkin discipline that makes this work: one scenario per acceptance criterion with a stable tag id (`@AC-0142-03`); every scenario names its level (`@unit`, `@contract`, `@e2e`, `@manual`); a scenario nothing can execute is a defect in the scenario — state the proving mechanism or don't write it; negative and error paths are required wherever a failure mode exists, and their absence is stated explicitly rather than left silent.

## Tier 4 — Surface
*Only where the solution has a user-facing surface.*

| Artifact | Format | Notes |
|---|---|---|
| `surface/design-tokens.json` | JSON | Colors, spacing, type scale — diffable, unlike a design file |
| `surface/components/*.md` | prose + prop tables | Component contracts: props, states, variants |
| `surface/screens/*.md` | prose + refs | Screen composition, referencing components and `@AC` tags |
| `surface/accessibility.md` | prose + rule list | Conformance target and the checks that enforce it |
| `surface/content/*.yaml` | i18n key/value | Copy as data — diffable, translatable, reviewable |

Design files (Figma and similar) stay where they are and are *referenced* by URL and version — extract the tokens and the component contract rather than trying to make a design tool a docs-as-code artifact.

## Tier 5 — Operations
*What running the thing requires. Frequently omitted, and the omission shows up as an incident.*

| Artifact | Format | Notes |
|---|---|---|
| `operations/observability.yaml` | YAML | Required metrics, log fields, trace spans per service — makes "did we instrument it" a diff entry rather than an afterthought |
| `operations/flags.yaml` | YAML | Flag key, scope, default per environment, owner, **expiry date or condition**, cleanup entries |
| `operations/slo.yaml` | YAML | Objectives and error budgets; feeds control-band monitoring |
| `operations/runbooks/*.md` | prose | One per failure mode; referenced from alerts |
| `operations/environments.yaml` | YAML | Environments, promotion order, what differs |
| `operations/dependencies.yaml` | YAML | Upstream/downstream services and owners — the cheapest blast-radius input available |

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

## Tier 7 — Meta

| Artifact | Purpose |
|---|---|
| `spec/INDEX.yaml` | Machine-readable map: artifact → owner → validator → format → tier. Lets scripts and agents locate the relevant slice without walking the tree — a direct token saving |
| `REVIEW.md` (per code repo) | Review passes, severity definitions, nit cap, exclusions |
| `AGENTS.md` / `CLAUDE.md` (per code repo) | Repo-scoped conventions, commands, architecture, and recurring repo-level mistakes — about a page. Excludes spec content, anything a script/hook already enforces, and individual preference — see the scoping note in the main skill |
| agent config dir — `.agent/`, `.claude/`, or the harness equivalent | Skills, subagents, hooks, settings — the control plane config, version-controlled and eval-gated |
| agent state dir (`AGENT-STATE`) | Continuity notes, scratch files, telemetry output. Always writable, never frozen, never part of a change, never reviewed. Declare its paths once so the write rules can exempt them |

## Minimum viable spec (repeated here for convenience — see the main skill)

1. `principles/architecture.md`
2. `decisions/` with front-matter (even if it starts with three ADRs)
3. `contracts/http/` **or** whichever interface format the solution actually exposes
4. `contracts/db/` migrations
5. `behavior/{domain}/*.feature`
6. `operations/flags.yaml`
