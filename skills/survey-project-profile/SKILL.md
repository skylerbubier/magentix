---
name: survey-project-profile
description: Use when surveying a repository to build or update a project profile — recording CI, branch protection, CODEOWNERS, dependencies, and conventions before asking a human anything. Triggers on "survey this project", "set up a project profile", "what do we know about this repo".
argument-hint: "[project-id] [path to project-profiles collection, if not the default]"
---

Normative source: [Project profile — architecture](${CLAUDE_PLUGIN_ROOT}/profiles/project/README.md), [fact format](${CLAUDE_PLUGIN_ROOT}/profiles/project/01-fact-format.md), [collection](${CLAUDE_PLUGIN_ROOT}/profiles/project/02-collection.md).

This skill produces or extends one project's fact collection: one `PF-NNNN` fact file per true, checkable statement about the project, filed under `{project-id}/facts/<category>/`, plus a regenerated `INDEX.yaml` and a maintained `practices.yaml` registry.

Full survey checklist (what to look for, where, and which category it becomes): [references/survey-checklist.md](references/survey-checklist.md).

## Procedure

1. **Locate or scaffold.** Look for `{project-id}/facts/`, `{project-id}/harness/bindings.yaml`, `{project-id}/practices.yaml`, and the cross-project `INDEX.yaml`. If none exists for this project, scaffold from [`templates/fact.yaml`](${CLAUDE_PLUGIN_ROOT}/profiles/project/templates/fact.yaml), [`templates/INDEX.yaml`](${CLAUDE_PLUGIN_ROOT}/profiles/project/templates/INDEX.yaml), and [`templates/practices.yaml`](${CLAUDE_PLUGIN_ROOT}/profiles/project/templates/practices.yaml).

2. **Observe before asking.** Most project facts are observable — walk the [survey checklist](references/survey-checklist.md): CI config, branch protection, `CODEOWNERS`, dependency manifests, interface specs, test setup, release cadence, existing conventions docs, existing agent tooling. Record every observation with its state — present, stale, unfilled, absent — before writing a single fact.

3. **Emit one fact per file**, exactly on the [schema](${CLAUDE_PLUGIN_ROOT}/profiles/project/templates/fact.yaml): frontmatter `kind: project-fact`, `project`, `owner` (one named person — never "the team"; a fact with no real owner has nobody to ask), `last_verified`; body `id` (next `PF-NNNN`), `category` (`identity | stack | interface | capability | authority | convention | constraint | cadence | harness`), `statement` (the durable, checkable shape), `detail` (current values — split from `statement` so a value change is not a supersession), `rationale`, `verification`, `authority` (who can *change* the fact, if different from who keeps it current), `supersedes`, `status`.

4. **Set `verification.method` honestly:**
   - `observed` — read from the project; `how` is **required** (the command, path, or artifact) and `last_result` states what it showed. An `observed` label with no `how` is an assertion wearing a stronger label than it earned.
   - `pointer` — the fact is authoritatively stated elsewhere in the repo; hold no copy of its content, only where it lives. Always the method for `convention` facts.
   - `asserted` — somebody said so and it cannot be read. The honest label for risk tier, intent, and social facts.
   - `untestable` — no way to establish it, now or later. Justify the fact's inclusion or drop it.

5. **Never copy a convention's text.** When the repository already states its own build steps, layering rules, or style guide, the fact records that the statement exists and where — never what it says. A profile holding a second copy is holding the copy nobody will update.

6. **Maintain `practices.yaml`** — the registry of which blueprints/practices this project has adopted: `id`, `blueprint`, `blueprint_version`, `adopted`, `manifest`, `owns_paths` (exclusive), `depends_on`, `status`, `last_reviewed`. Detect and record `path_collisions` where two practices claim the same path or glob — a collision is a human decision, never a merge.

7. **Regenerate `INDEX.yaml`** (cross-project) — never hand-edit it: per-project entry (`fact_count`, `practices`, `oldest_verification`, `status`), `stale_projects`, `path_collisions`, `stale_facts` (with the `how` to re-run), and `gaps` (the capability backlog — see [inventory-capabilities](../inventory-capabilities/SKILL.md)).

8. **Set verification intervals per category**, and use them to drive re-verification rather than re-interview:

   | Category | Interval |
   |---|---|
   | `capability` | 1 month — the shortest, deliberately; every honesty claim rests on these |
   | `interface` | 1 month |
   | `stack` | 3 months |
   | `authority` | 3 months |
   | `identity` | 6 months |
   | `cadence` | 6 months |
   | `convention` | 6 months |
   | `constraint` | 12 months |
   | `harness` | on any tooling change (event-based) |

   A lapsed `observed` fact is cheap to fix: re-run what `verification.how` names. Only ask a human about what genuinely cannot be observed — mostly `constraint`, risk tier, and the social half of `authority`.

## Do not

- Do not ask a human anything the repository itself can answer. Observation comes first, always.
- Do not copy a convention's text into the profile. Point at it with `verification.method: pointer`.
- Do not label a fact `observed` without a real `how`. That is the single most common way this format gets abused.
- Do not treat an unverified capability as available — see [inventory-capabilities](../inventory-capabilities/SKILL.md) for the full discipline on that category specifically.
- Do not invent an owner. If none is clear, record the fact as unowned and treat it as unverified rather than guessing.
- Do not record a person's preference here — different collection, different owner, different lifecycle. It belongs in the user profile.
- Do not edit a fact in place except verification fields and `detail` values. Nothing is deleted; supersede or retire instead.
- Do not write a tool name, config path, or product feature into any fact — that belongs only in `harness/bindings.yaml`. See [bind-harness](../bind-harness/SKILL.md).
- Do not let the project profile drift into a specification of the software. It describes the delivery context, not what the product does.

## How to know you did it right

- Every fact's `verification.method` is the honest one, and every `observed` fact names a real `how` with a real `last_result`.
- No `convention` fact contains the convention's actual text — only its location.
- `practices.yaml` and `INDEX.yaml`'s `path_collisions` agree with each other.
- `INDEX.yaml` regenerated, with `oldest_verification` reflecting the least-recently-checked fact, not an assumed date.
- The number of questions asked of a human is small relative to the number of facts recorded — a rising ratio means the survey is skipping observable ground.
- Fact count at maturity runs roughly forty to eighty active facts, weighted toward `capability`, `interface`, and `stack`; well under fifteen suggests a shallow survey.
