---
name: setup-agent-context
description: Use when instantiating or maintaining the four-file Agent Context Kit for a person or a project — "set up my agent context files", "write my CLAUDE.md preference layer", "what belongs in the working log vs the principal file". Walks the person through filling the kit incrementally and covers the periodic maintenance pass.
argument-hint: "[person | project] [harness, if known]"
---

Normative source: [Agent Context Kit — README](${CLAUDE_PLUGIN_ROOT}/blueprints/agent-context-kit/README.md) and its four templates: [01-principal.md](${CLAUDE_PLUGIN_ROOT}/blueprints/agent-context-kit/templates/01-principal.md) · [02-interaction-protocol.md](${CLAUDE_PLUGIN_ROOT}/blueprints/agent-context-kit/templates/02-interaction-protocol.md) · [03-workflow-index.md](${CLAUDE_PLUGIN_ROOT}/blueprints/agent-context-kit/templates/03-workflow-index.md) · [04-working-log.md](${CLAUDE_PLUGIN_ROOT}/blueprints/agent-context-kit/templates/04-working-log.md).

This skill produces four filled context documents — `01-principal.md`, `02-interaction-protocol.md`, `03-workflow-index.md`, `04-working-log.md` — placed at the paths the harness binding says they belong, each carrying required governance frontmatter.

The blueprint's own README states this kit is meant to be instantiated by the adoption loop, never filled in by hand, and pairs with a user profile — the tracked, gated route is [/magentix:adopt-practice](../adopt-practice/SKILL.md) run against this blueprint. This skill is the direct walkthrough for when a full gated adoption run is not warranted (a first pass, a quick fix to one file); it does not produce a manifest or a review schedule the way the loop does, and it does not substitute for `/magentix:adopt-practice` where drift tracking and re-entry matter.

## Procedure

1. **Split by volatility and authorship, not topic.** Four files, four different rates of change and two different authors:

   | File | Answers | Authored by | Changes |
   |---|---|---|---|
   | `01-principal.md` | Who am I working for? | The person | Rarely (quarterly-ish) |
   | `02-interaction-protocol.md` | How should the agent behave with me? | The person | Occasionally, as trust calibrates |
   | `03-workflow-index.md` | What recurring work exists, and where's the detail? | The person / their team | Moderate — new workflow, new row |
   | `04-working-log.md` | What's the current state, and what have we learned? | The agent | Constantly |

   Mixing these axes — burying a slow fact next to a running scratchpad — is the most common cause of context rot: nobody ends up trusting either one.

2. **Find where each file actually goes before writing anything.** Do not assume a layout — read it from the profile's harness binding (see [/magentix:bind-harness](../bind-harness/SKILL.md)). `01` and `02` are natural candidates for a global, personal slot; `03` usually wants a project-level copy per codebase, plus a personal/global copy for cross-project workflows; `04` is inherently per-project or per-thread. If no personal slot exists for a given harness, that is recorded rather than worked around — nothing is materialized for it.

3. **Give `04-working-log.md` a location that survives write restrictions.** It is agent-written state, so the agent must be able to write it at any point in a task, including where a repo restricts what may be modified. Put it on a path a write-restriction policy treats as agent state — a dedicated scratch/state directory excluded from those policies — or outside the repo entirely. A continuity log the agent is periodically forbidden to write fails silently and hands the next session a partial record.

4. **Fill the files incrementally, one sitting per file, not all four at once.** For each:
   - **`01-principal.md`** — role & context (one or two sentences calibrating explanation level), ranked priorities (what breaks ties without asking), decision authority & constraints (what the agent may decide alone vs. always needs sign-off — this only ever narrows, never grants an approval that belongs to someone else, and never widens what an enforced mechanism already blocks), standing context (durable, not already stated in a repo's own conventions or a check's configuration), explicit non-goals.
   - **`02-interaction-protocol.md`** — output format defaults, a verbosity-by-situation table (routine / high-stakes / long-running / something-went-wrong — one floor under every row: evidence a claim depends on is never compressed away), an autonomy-by-action-class table (observer / consultant / collaborator / approver / operator — a level here can be stricter than an enforced floor, never looser), progress signaling for done / blocked / uncertain-proceeding-anyway / **stopped at a control** (a distinct fourth state — a decision needing the person, not a failure to apologize for), and a clarification policy (when to ask vs. proceed on a default).
   - **`03-workflow-index.md`** — one row per recurring workflow: when to use it, what it does, its `Authority` (a named approver, a pipeline check, an owning team — filled in only where the workflow has its own gate, left blank otherwise), and a link to its detail file. This file is a router; if a row is growing paragraphs, the detail belongs in a linked reference instead.
   - **`04-working-log.md`** — current focus, standing decisions (with a one-line why), a corrections log (mistakes made once and the fix), and open threads / handoff notes written as if the reader has none of the current context, because at a real session boundary that is exactly the case.

5. **Write the governance frontmatter on every file:**

   ```yaml
   kind: agent-context
   owner: <who maintains this>        # 04 uses `maintained_by: agent` instead of `owner`
   applies_to: <global | project: name | team: name>
   last_reviewed: <YYYY-MM-DD>
   ```

   `kind: agent-context` is the discriminator that keeps these files inert to any other frontmatter-scanning script or schema in the repo — do not drop it, and do not reuse a bare `scope:` key, which other schemas already claim with different meanings.

6. **Enforce precedence and the preference/enforcement boundary.** Within the kit, more specific beats more general (a project copy of `03` over a global one) — the same rule the AGENTS.md convention and Claude Code's memory hierarchy both use. An explicit instruction in the conversation overrides all four files. **Enforced controls sit outside this ordering entirely**, above the conversation included: a tool-call denial, a required approval, a pipeline check, or an org policy holds regardless of what any file here says. A preference in this kit may be *more* conservative than an enforced control. It may never be less. When a preference and a control disagree, say so plainly and stop — never route around either one.

## Maintenance mode (a distinct, recurring pass)

Run this periodically — weekly, or at natural checkpoints — rather than only at first setup:

1. Skim `04-working-log.md` and ask, of each entry: is this durable enough to belong in `01`, `02`, or `03` instead?
2. If yes, promote it into the right file by volatility/authorship, then delete it from the log. A promotion that lands somewhere *outside* this kit entirely — a recurring correction that turns out to be a team convention, or one that turns out to be mechanically checkable — is a good outcome, not a failure of the loop.
3. If no, let it age out. Do not let the log quietly become a second, uncurated instructions file.
4. Check every file's length. **Rule of thumb: past ~150-300 lines, something wants to be split out** into its own linked reference file — for `03` specifically, into a file under a `workflows/` or `skills/`-adjacent folder, referenced from the relevant row.

### The "adding a workflow" bar-test for `03`

Before adding a row, check all three: has this come up more than once (a one-off task doesn't need a permanent row, and nothing that hasn't recurred at least twice is a workflow yet); does it have a non-obvious trigger or procedure; would a new agent or new teammate benefit from a pointer to it. And once added: is the row staying a pointer, or is it becoming the documentation? If it's growing paragraphs, move them to the detail file.

## Do not

- Do not restate a fact a repo's own conventions already state, or a rule some check already enforces — point at it instead. A second copy is the one that goes stale.
- Do not put team-inherited content (workflow conventions, process definitions with their own approvals, anything a check enforces) into `01` or `02` — those own preference, personal context, and pointers only.
- Do not materialize `01` or `02` into a shared project slot, even when the harness binding technically allows a write there — personal preference does not belong in a file other people inherit. If the project slot is already team-owned content, put `03` beside it as its own file.
- Do not let anything in this kit widen what an agent is permitted to do. A section under "can decide without asking" narrows; it never licenses past an enforced mechanism or grants an approval that belongs to someone else.
- Do not treat retained context across a session boundary as sufficient. Whatever the next session needs must be written into `04-working-log.md` before the current one ends — a deliberate fresh session is asserting that retained context is not a transport mechanism.
- Do not let `04-working-log.md` become the authoritative home for a decision, a convention, or an enforced rule. It points at those; it never restates them.
- Do not place `04-working-log.md` somewhere a write-restriction policy can deny — a log the agent is periodically forbidden to write fails silently.
- Do not skip the frontmatter, and do not substitute a bare `scope:` key for `applies_to`.

## How to know you did it right

- Each of the four files answers only its own question — a fact that belongs in another file was not duplicated into this one.
- Every file carries the governance frontmatter, including a real `last_reviewed` date.
- No file exceeds roughly 150-300 lines without having split real depth into a linked reference.
- `04`'s location was checked against write-restriction policy, not assumed.
- Placement of each file matches what the harness binding actually records as readable and writable — not a guess at a conventional layout.
- The maintenance pass, when run, ends with the working log shorter than it started (something promoted, something aged out) or explicitly unchanged because nothing in it qualified yet.
