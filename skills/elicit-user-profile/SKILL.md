---
name: elicit-user-profile
description: Use when building or maintaining a personal user-criteria collection so agents stop re-asking what's already known. Triggers on "set up my profile", "remember that I prefer X", "what do you know about how I work", "review my preferences".
argument-hint: "[path to existing user-profile collection, if not the default]"
---

Normative source: [User profile — architecture](${CLAUDE_PLUGIN_ROOT}/profiles/user/README.md), [criterion format](${CLAUDE_PLUGIN_ROOT}/profiles/user/01-criterion-format.md), [collection](${CLAUDE_PLUGIN_ROOT}/profiles/user/02-collection.md), [elicitation method](${CLAUDE_PLUGIN_ROOT}/adoption/03-elicitation.md).

This skill produces or extends a **user-criteria collection**: one `UC-NNNN` criterion file per durable fact about the person, filed under `criteria/<category>/`, with a regenerated `INDEX.yaml` — never a document written for a human to read.

## Procedure

1. **Locate or scaffold.** Look for an existing collection (`INDEX.yaml`, `criteria/`, `harness/bindings.yaml`, `CHANGELOG.md`). If none exists, this is a **bootstrap**: scaffold the layout from [`templates/INDEX.yaml`](${CLAUDE_PLUGIN_ROOT}/profiles/user/templates/INDEX.yaml), [`templates/criterion.yaml`](${CLAUDE_PLUGIN_ROOT}/profiles/user/templates/criterion.yaml), and [`templates/bindings.yaml`](${CLAUDE_PLUGIN_ROOT}/profiles/user/templates/bindings.yaml) — see [bind-harness](../bind-harness/SKILL.md) for the binding itself.

2. **Never run a big upfront interview.** This collection is only worth having if it is populated incrementally, mostly from corrections and observations during real work. A first-sitting attempt to fill it completely produces confident answers to questions the person has not actually thought about. Mark anything elicited this way `stability: provisional`.

3. **Follow the source order, strictly:** the profile itself (already recorded — free) → the environment (readable right now — nearly free, and it verifies the profile at the same time) → the human (irreplaceable, and the only source that runs out). Never ask for what `INDEX.yaml` already holds, and never ask for what could be read off disk. Asking at the profile level is worse than asking at the environment level, because it tells the person their answers are not being kept.

4. **Determine the move** for whatever prompted this run:
   - **Add** — a new fact was elicited, observed, or corrected into existence.
   - **Confirm** — an existing criterion was re-checked and still holds. Only `last_confirmed` changes.
   - **Supersede** — the fact changed, or reality/behavior contradicts it. The old file is kept, marked `status: superseded`; a new file replaces it with `supersedes:` pointing back.
   - **Retire** — the fact stopped applying. Marked `status: retired` with a `retired_reason`; the file is kept.

5. **Classify contradiction by behavior**, when the person repeatedly acts against a criterion the collection holds. Three possibilities, and only the person can say which:
   - **Aspirational** — they described who they want to be. Supersede with what is actually true.
   - **Wrong scope** — it holds in some situations and not others. Split it by `scope`.
   - **Stopped being true** — supersede it.
   Surface the mismatch; do not resolve it by insisting on the existing criterion.

6. **Write one criterion per file**, exactly on the [schema](${CLAUDE_PLUGIN_ROOT}/profiles/user/templates/criterion.yaml): frontmatter `kind: user-criterion`, `owner`, `last_confirmed`; body `id` (next `UC-NNNN`), `category`, `rank` (priority only), `statement` (one behaviorally-comparable fact — could you tell from a transcript whether it was honored?), `rationale` (why, so the fact generalizes), `scope`, `weight` (`default | strong | firm` — none of these enforce anything), `stability` (`provisional | calibrating | stable`), `source` (`corrected | observed | stated | inferred`), `evidence` (required for `corrected` and `inferred`), `supersedes`, `status`.

7. **Regenerate `INDEX.yaml`** from the criteria files — never hand-edit it. Include `count` by status, the router list (id/category/rank/scope/weight/stability/source/last_confirmed/status/path — no `statement`, no `rationale`), the `stale` list, and the `conflicts` list (same-scope, contradictory statements).

8. **Run the staleness sweep**, per category, against the confirmation intervals:

   | Category | Interval |
   |---|---|
   | `identity` | 12 months |
   | `priority` | 6 months |
   | `authority` | 6 months |
   | `interaction` | 3 months while `calibrating`, 12 once `stable` |
   | `context` | 12 months |
   | `non-goal` | 12 months |
   | `correction` | 6 months |
   | `harness` | on any tooling change (event-based) |

   A lapsed interval is not an error — it is a prompt to ask about that one criterion before trusting it. **A stale criterion is still used**; staleness changes how loudly the agent volunteers that it is acting on an old fact, not whether it acts.

## Do not

- Do not run a big upfront interview. Build incrementally, from what the person has already said and done.
- Do not ask for what is already in `INDEX.yaml`, and never ask for what is readable off disk.
- Do not edit a criterion file in place, except the `last_confirmed` date on a Confirm.
- Do not delete a criterion. Superseded and retired files are kept forever.
- Do not average two contradicting criteria at the same scope. That is a conflict for the person to resolve.
- Do not record a project-specific fact here — it belongs in a project profile.
- Do not restate something a mechanism already enforces; point at the mechanism, or drop the criterion.
- Do not let `weight: firm` be read as enforcement. Nothing in this collection is checked by anything, and nothing in it can widen what an agent is permitted to do — a criterion may be more conservative than an enforced control, never less.
- Do not write a tool name, config path, or product feature into any criterion. That belongs only in `harness/bindings.yaml` — see [bind-harness](../bind-harness/SKILL.md).
- Do not reshape or reorganize the collection. Only add, confirm, supersede, retire.

## How to know you did it right

- Every new `statement` passes the transcript test: a reader could say whether it was honored.
- Every `corrected` or `inferred` criterion carries a real one-line `evidence`.
- `INDEX.yaml` regenerated and consistent with the files on disk — same counts, same stale list, same conflicts.
- No file was edited except for a `last_confirmed` date, a supersession, or a retirement.
- Nothing was asked that the profile already held or the environment could show.
- Early/newly-elicited criteria are marked `provisional`, not `stable`.
- The staleness sweep ran and its results (if any) are reflected in `INDEX.yaml`'s `stale` list, not silently dropped.
