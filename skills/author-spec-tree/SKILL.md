---
name: author-spec-tree
description: Use when building or amending an AI-SDLC specification plane — "set up the spec tree", "add a contract/ADR/Gherkin scenario to the spec", "what's the minimum spec I need to start". Authors docs-as-code artifacts by tier; does not freeze, diff, or promote — those are scripts by design.
argument-hint: "[repo path] [tier, if known]"
---

Normative source: [spec-recipe.md](${CLAUDE_PLUGIN_ROOT}/blueprints/ai-sdlc/spec-recipe.md), with phase context from [overview.md](${CLAUDE_PLUGIN_ROOT}/blueprints/ai-sdlc/overview.md) and [subsystems.md](${CLAUDE_PLUGIN_ROOT}/blueprints/ai-sdlc/subsystems.md).

This skill produces or amends **the specification plane** — the docs-as-code tree under `spec/` and its per-change overlay under `changes/{change-id}/target/` — starting from the six-artifact minimum and expanding only as the need proves itself.

## The mutability inversion, stated up front

While intent is uncertain, the specification is mutable and the source code is read-only. The moment intent is settled, that inverts: the specification freezes and the source code becomes mutable. There is no window in which both are editable. This is the answer to an agent quietly amending a requirement to match what it managed to build — moving the goalposts is genuinely the cheapest path available to it, and removing that path is a configuration change, not a supervision problem.

**Every hop between planes is a script, not a model.** The chain from intent to code is a compilation pipeline whose intermediate representation is documents — spec grammar checks, diff generation, freeze/hash verification, plan-diff coverage, and diff-of-diffs salvage are all deterministic. If a model generates any of these, the determinism argument the whole design rests on is gone. This skill authors the documents the pipeline consumes; it is never the pipeline.

## Directory layout

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

An untouched artifact is inherited from `spec/` (current) by reference — never copied into a change's `target/` overlay.

## Procedure

1. **Default to the minimum viable spec.** Do not build all seven tiers before starting; nothing else works without something diffable, and building in diagram order is explicitly the wrong order. The six-artifact minimum:

   1. `principles/architecture.md`
   2. `decisions/` with front-matter (even if it starts with three ADRs)
   3. `contracts/http/` **or** whichever interface format the solution actually exposes
   4. `contracts/db/` migrations
   5. `behavior/{domain}/*.feature`
   6. `operations/flags.yaml`

   Everything past these six is the direction to grow in, ordered by how often its absence causes rework — expand a tier only when the current change actually needs it, and load [references/tiers.md](references/tiers.md) only for the tier being touched.

2. **Edit additive-first.** Prefer new versions and optional fields over mutation; record any breaking change explicitly rather than letting it fall out of a diff. Contracts follow `{name}-v{N}.{ext}`, with parallel versions coexisting — removing an old version is its own change with its own diff entry.

3. **One home per fact.** An artifact that restates another is a future contradiction. Downstream artifacts reference upstream ids; they never copy content. A duplicated fact produces two diff entries for one change, or worse, only one — either way the diff stops being trustworthy.

4. **Every artifact names its validator.** If nothing can check it, it cannot be part of the frozen set in any meaningful sense — demote it to a reference note rather than letting it pretend to be a contract. [references/tiers.md](references/tiers.md) names the validator for every artifact in every tier.

5. **Stamp ADR front-matter correctly** for anything under `decisions/`:

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

   Without this front-matter an ADR is documentation; with it, it is a control. Most ADRs stay `advisory`; only `blocking` ones compile into a check. The resolver selects on `id` + `enforcement` under `decisions/` and nothing else, with newest-supersession-wins precedence by scope glob — never by similarity search. Do not let anything treat a file with a `scope:` key as an ADR unless it also lives under `decisions/` and carries `id` and `enforcement`; that key means something else in other schemas.

6. **Scope the per-repo `AGENTS.md` / `CLAUDE.md` correctly**, when touching Tier 7. It carries repo-scoped conventions, commands, architecture, and recurring repo-level mistakes — about a page. Three things never belong in it: spec content (not diffable, not frozen, not validated there); a rule a script or hook already enforces (the prose copy is the one that goes stale); and individual preference (different clock, different owner — that belongs to a different layer entirely, e.g. [/magentix:setup-agent-context](../setup-agent-context/SKILL.md)'s files, never this one).

7. **Know the growth order beyond the minimum**, so an expansion request lands in the right place: spec tree → spec validation in CI → diff generation as a script → freeze + manifest + hooks (the mutability inversion actually taking effect) → plan traceability + validation → blocker triage → promotion → review split, telemetry, evals. The first four are a working system on their own; piloting three or four real changes surfaces more than further design will.

## What this skill does not do

- **It does not freeze.** Snapshotting `CURRENT SPEC`, writing `change-manifest.json` with a SHA-256 per artifact, and flipping the phase flag is S7, a script, by design.
- **It does not generate the diff.** `spec-diff/` comes from format-aware diff tools — OpenAPI diff, JSON Schema diff, schema-registry compatibility, GraphQL inspector, Gherkin scenario set-diff — run as S8, never authored. **"If a model generates this artifact, the entire determinism argument collapses."**
- **It does not promote.** Copying `target/**` over the shared `spec/` tree on merge, archiving the diff and plan, and unfreezing is S16, a script, run after the merge gate — not something this skill performs.

Where any of these three is needed, that is the signal the change is ready for its own scripted step, not a reason to write the artifact by hand and call it done.

## Do not

- Do not build all seven tiers before the first change needs them, and do not build in diagram order — build in the dependency order above.
- Do not copy a fact between artifacts. Reference the upstream id instead.
- Do not leave an artifact with no named validator presented as a contract — demote it to a reference note.
- Do not let any script or resolver treat a document as an ADR because it merely carries a `scope:` field; it must live under `decisions/` and carry both `id` and `enforcement`.
- Do not put spec content, an already-enforced rule, or individual preference into the per-repo `AGENTS.md` / `CLAUDE.md`.
- Do not edit an artifact nobody's change actually alters — an untouched artifact stays inherited by reference in `target/`, not copied.
- Do not author the freeze, the diff, or the promotion step yourself, even when it would be convenient in the moment.

## How to know you did it right

- The tree contains at minimum the six-artifact subset, or a stated, justified reason for starting smaller or larger.
- Every artifact in the tree names a validator, drawn from [references/tiers.md](references/tiers.md), or has been explicitly demoted to a reference note.
- Every file under `decisions/` carries `id`, `status`, `scope`, `supersedes`, `enforcement`, and `expires` where `enforcement: blocking`.
- No fact appears in two artifacts — a search for the same statement in two places turns up nothing.
- The per-repo `AGENTS.md` / `CLAUDE.md`, if touched, contains none of the three excluded categories.
- Nothing produced by this skill call is a `change-manifest.json`, a `spec-diff/` entry, or a promotion — those remain script output.
