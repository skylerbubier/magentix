*[Magentix](../../README.md) › [Profiles](../README.md) › [Project profile](README.md) › Collection*

# The Collection

Many projects, each running several practices. This document is about keeping that straight.

---

## Layout

```
project-profiles/
  INDEX.yaml                       # across all projects
  {project-id}/
    facts/
      identity/PF-0001.yaml
      stack/PF-0008.yaml
      interface/PF-0015.yaml
      capability/PF-0032.yaml
      authority/PF-0040.yaml
      conventions/PF-0044.yaml     # pointers only, never copies
      constraints/PF-0051.yaml
      cadence/PF-0060.yaml
    harness/bindings.yaml          # the only agent-specific file
    practices.yaml                 # which blueprints are adopted, and what each owns
    CHANGELOG.md
  {another-project-id}/
    …
```

One fact per file, filenames are ids. Fact ids are unique across the whole collection, not per project, so a fact quoted in a generated artifact can be found without knowing which project it came from.

## The cross-project index

```yaml
generated_at: <YYYY-MM-DD>

projects:
  - id: <project-id>
    name: <human name>
    repositories: [<repo>, …]
    owner: <one named person>
    risk_tier: <as recorded in cadence facts>
    fact_count: { active: 61, superseded: 12, retired: 4 }
    practices: [<practice-id>, …]
    oldest_verification: <YYYY-MM-DD>
    status: <active | dormant | retired>

stale_projects:        # oldest_verification past the interval
  - <project-id>

path_collisions:       # the same path claimed by more than one practice
  - path: <path>
    claimed_by: [<practice-id>, <practice-id>]
```

Two of those fields are the reason the index exists at all.

**`oldest_verification`** is the single most useful number in the collection. A project whose least-recently-verified fact is four months old is a project whose generated artifacts are being trusted on the strength of a four-month-old survey.

**`path_collisions`** is what makes several practices per project safe. Nothing else detects it.

---

## Several practices in one project

A project commonly adopts more than one practice — a delivery pipeline, a review standard, an incident routine — each generating its own artifacts into the same repository. `practices.yaml` is the registry:

```yaml
project: <project-id>

practices:
  - id: <practice-id>
    blueprint: <source>
    blueprint_version: <what was read>
    adopted: <YYYY-MM-DD>
    manifest: <path to the practice manifest>
    owns_paths:              # exclusive — no other practice may write these
      - <path or glob>
    status: <live | draft | retired>
    last_reviewed: <YYYY-MM-DD>
```

### The path-ownership rule

**A path belongs to exactly one live practice.** Two practices writing the same file will overwrite each other, and the second one's regeneration will silently destroy the first one's output.

The rule has three consequences worth stating:

1. **A collision is a human decision, not a merge.** When two practices both want a file, somebody decides which owns it; the other points at it or writes elsewhere. Automatic merging produces a file neither practice can regenerate.
2. **Shared files need a designated owner.** A repository's main agent-instruction file is the usual contention point, because every practice has something to say there. One practice owns the file; the others contribute through paths it references.
3. **Retiring a practice releases its paths.** Until the retirement is recorded, those paths stay claimed, and the next adoption will report a collision against something nobody is maintaining.

### Ordering

Where practices depend on each other — a review standard that assumes a delivery pipeline exists — `practices.yaml` records the adoption order. This matters on regeneration: rebuilding a dependency after its dependent leaves the dependent pointing at content that no longer exists.

---

## Verification intervals

Project reality drifts faster than a person's preferences, and drifts at different rates by category.

| Category | Interval | Why |
|---|---|---|
| `capability` | 1 month | Checks get disabled, pipelines get edited, protection rules get relaxed. The fastest-drifting and most consequential category |
| `interface` | 1 month | Contracts change with every release |
| `stack` | 3 months | Dependency and platform drift |
| `authority` | 3 months | People change roles; CODEOWNERS goes stale quietly |
| `identity` | 6 months | Repository boundaries move during migrations |
| `cadence` | 6 months | Release rhythm and environments |
| `convention` | 6 months | The pointer target may have moved or been deleted |
| `constraint` | 12 months | Slow, but re-check because an expired constraint keeps constraining |
| `harness` | On any tooling change | Event-based |

**`capability` at one month is deliberate and it is the load-bearing interval.** Every honesty claim a generated practice makes rests on these facts. A capability fact that has gone stale is the mechanism by which a practice quietly becomes advisory while still presenting itself as enforced.

A lapsed interval on an `observed` fact is cheap to fix: re-run what `verification.how` names. That is the advantage of a collection that records how it knows things.

---

## The four moves, plus one

| Move | What changes |
|---|---|
| **Add** | New file, next id |
| **Verify** | `last_verified` and `verification.last_result` only |
| **Supersede** | Old file marked superseded and kept; new file points at it |
| **Retire** | Marked retired with a reason, and kept |
| **Re-verify** | The project-scope addition: re-run `verification.how` and record what it showed. Confirms or contradicts without asking anyone |

Nothing is edited in place except verification fields and `detail` values. Nothing is deleted.

A re-verification that contradicts the fact is the most valuable event in the collection's life — it is drift caught before an artifact was regenerated against it.

## Where facts come from

Mostly from observation, which is why the interview is short.

| Source | Typically |
|---|---|
| **Survey of the project** | `identity`, `stack`, `interface`, `capability`, `harness`, and most of `authority`. Read, not asked |
| **Pointer discovery** | `convention` — find what the project already states, record where |
| **Conversation** | `constraint`, `risk_tier`, and the parts of `authority` that are social rather than configured |
| **A practice's own operation** | Capability gaps discovered when something could not be enforced; these come back as facts |

The last row is the loop closing. A practice that had to demote an element from enforced to asserted has just produced a verified capability fact, and it belongs here rather than only in that practice's record.

## Conflicts

| Situation | Resolution |
|---|---|
| Two facts, one `observed` and one `asserted`, disagreeing | The observation wins. Supersede the assertion |
| Two `observed` facts disagreeing | One is stale. Re-verify both |
| Two `asserted` facts disagreeing | Named owners resolve it. Never average |
| A fact contradicted by a practice's operation | The practice is the observation. Supersede the fact |

## Size and pruning

A mature project profile runs to roughly forty to eighty active facts, weighted toward `capability`, `interface`, and `stack`.

Two failure signals:

- **Fewer than fifteen facts** on a real delivery project means the survey was shallow, and the capability inventory is almost certainly the thin part.
- **More than about a hundred and fifty** means the profile is drifting into specification. A profile describes the delivery context; what the software does belongs in the project's own spec artifacts.

Prune by asking which facts a generator has ever selected. A fact no practice reads is either a fact nobody needed or evidence that a practice is missing.

## Dormant and retired projects

A project that is no longer worked on goes `dormant`: verification stops, facts stay, practices stay live. Its generated artifacts remain in place — which matters, because a stale agent-instruction file keeps steering every session in that repository until somebody removes it.

Retiring a project means retiring its practices first, which removes those artifacts and releases their paths. A profile marked retired with artifacts still on disk is the worst state available: nobody maintains the facts, and the artifacts still shape behavior.
