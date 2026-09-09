*[Magentix](../../README.md) › [Blueprints](../README.md) › Agent Context Kit*

# Agent Context Kit

A Magentix blueprint for the **preference layer**: four context documents that
tell an agent who it is working for and how, split by volatility and
authorship rather than by topic. This page is the blueprint's landing page —
the argument for its shape follows below; the templates themselves live in
[`templates/`](templates/).

**Companion diagram:** [agent-context-kit.excalidraw](../../docs/diagrams/agent-context-kit.excalidraw)

## In this blueprint

- [`01-principal.md`](templates/01-principal.md) — who the agent is working for
- [`02-interaction-protocol.md`](templates/02-interaction-protocol.md) — how the agent should behave, moment to moment
- [`03-workflow-index.md`](templates/03-workflow-index.md) — a router to recurring work and where its detail lives
- [`04-working-log.md`](templates/04-working-log.md) — the agent's own continuity notes across sessions and compactions

## Profile pairing

This blueprint pairs with a **user profile**
(see [`profiles/user/`](../../profiles/user/README.md)): the adoption engine
reads this blueprint's elements alongside a person's criteria and compiles
the four documents above at harness-specific paths. The kit itself is never
filled in by hand — see [`adoption/`](../../adoption/README.md) for the loop
that instantiates it.

---

Four documents, split by **volatility** (how often it changes) and **authorship**
(who writes it), not by topic. Mixing these axes is the most common cause of
context rot: slow-changing facts get buried next to a running scratchpad, so
nobody trusts either one.

| File | Answers | Authored by | Changes |
|---|---|---|---|
| [`01-principal.md`](templates/01-principal.md) | Who am I working for? | You | Rarely (quarterly-ish) |
| [`02-interaction-protocol.md`](templates/02-interaction-protocol.md) | How should the agent behave with me? | You | Occasionally, as trust calibrates |
| [`03-workflow-index.md`](templates/03-workflow-index.md) | What recurring work exists, and where's the detail? | You / your team | Moderate — new workflow, new row |
| [`04-working-log.md`](templates/04-working-log.md) | What's the current state, and what have we learned? | The agent | Constantly |

---

## What this kit is, and what it is not

This kit is a **preference layer**. Everything in it is guidance the agent reads
and follows because it was asked to. That is the right shape for what it covers
— how much to explain, when to ask, what you care about — because none of those
have a mechanical test.

It is deliberately not an enforcement layer. Nothing here can guarantee a
behavior, because nothing here is checked by anything. A file the agent is asked
to honor and a check that fails closed are different categories of thing, and
conflating them is how a document ends up believed to be a control when it is
only a request.

That distinction has one practical consequence, stated once here and repeated
where it bites:

> **An enforced control is never relaxed by a file in this kit.** Where some
> mechanism outside these documents — a tool-call denial, a required approval, a
> pipeline check, an org policy — constrains an action, that constraint holds
> regardless of what any file here says. A preference expressed in this kit may
> be *more* conservative than an enforced control. It may never be less.

So these four files own **preference, personal context, and pointers**. They do
not own team conventions other people are also bound by, process definitions
with their own required approvals, or anything a check enforces. A fact from one
of those categories that ends up in here now has two homes, and one of them is
wrong.

## Precedence

Within this kit, if more than one copy is loaded at once (e.g. a global copy
plus a project-specific copy), more specific beats more general — the same
"closest file wins" convention the AGENTS.md standard uses, and the same rule
any harness's own context-loading precedence applies between a global and a
project-level source. An explicit instruction in the conversation overrides
all four files.

Enforced controls are not part of this ordering. They sit outside it and above
all of it, including the conversation — an instruction to proceed does not
dissolve a check. When a preference here and an enforced control disagree, the
useful response is to say so plainly and stop, not to route around either one.

## One home per fact

Two documents stating the same fact are a future contradiction, because one of
them will be updated and the other will not. Within this kit, each fact lives in
exactly one of the four files. Across layers the same rule applies outward: if a
fact is already stated in a repo's own conventions, in a process definition, or
in a check's configuration, do not restate it here — point at it.

This is what keeps the kit thin enough to be worth loading every time.

## Progressive disclosure — keep every file thin

None of these four files should contain full detail. Each is a *pointer layer*:
short enough to be loaded in full, every time, cheaply. When a file would need
real depth (a specific workflow's step-by-step procedure, a full style guide, a
schema), put that depth in its own reference file and link to it from the
relevant row in [`03-workflow-index.md`](templates/03-workflow-index.md). The agent loads the reference file only
when the task actually needs it.

Rule of thumb: if any of these four files is pushing past ~150-300 lines,
something in it wants to be split out into a linked reference file instead.

## Governance metadata

Every file below opens with a small frontmatter block:

```yaml
kind: agent-context
owner: <who maintains this>
applies_to: <global | project: name | team: name>
last_reviewed: <date>
```

`last_reviewed` costs almost nothing and solves a real problem: a file with a
stale date is a signal to re-check it before trusting it, rather than silently
accumulating drift. Across several teams this matters more, not less — it's how
a new agent (or a new engineer) can tell your personal preferences from a team
standard from something nobody has looked at in months.

`kind: agent-context` is the discriminator, and it earns its keep the moment
these files live in a repo alongside anything else carrying frontmatter. Policy
documents, decision records, and schema-bearing artifacts are commonly selected
by scripts that scan frontmatter; a bare `scope:` key is exactly the sort of
field such a scanner claims, and it means different things in different schemas
(an audience here, a path glob elsewhere). Naming the audience field
`applies_to` and stamping `kind` keeps these four files inert to anything not
looking for them, and unambiguous to anything that is.

## Where these files live

`01` and `02` are natural candidates for a **global** slot — they describe you,
not any one project. `03` usually wants a project-level copy per codebase, with
a personal/global copy for cross-project workflows. `04` is inherently
per-project (or per-agent-thread) and should be treated as disposable — it is a
scratchpad with a paper trail, not a document you polish.

`04` has one location constraint the others don't. It is agent-written state, so
the agent has to be able to write it at any point in a task, including at points
where a repo restricts what may be modified. Put it on a path that
write-restriction policies treat as **agent state** rather than project content
— a dedicated scratch or state directory, excluded from those policies — or
keep it outside the repo entirely. A continuity log the agent is periodically
forbidden to write is worse than no log, because it fails silently and leaves a
partial record.

The four documents are harness-agnostic — they're just Markdown, read by
whatever mechanism your tool uses to load context. Each one lands in whatever
slot the adopter's harness actually provides — global/always-loaded,
project-level/shared, on-demand reference, or agent-written state — and which
slot that is for a given tool is exactly the kind of tool-specific detail this
blueprint does not decide: a real adoption resolves it through the harness
binding ([`profiles/user/03-harness-binding.md`](../../profiles/user/03-harness-binding.md),
[`profiles/project/04-harness-binding.md`](../../profiles/project/04-harness-binding.md)),
never through this document. For a non-normative, worked-example mapping of
these four files onto several common tools' concrete files, see
[`templates/harness/agent-context-kit-slots.md`](../../templates/harness/agent-context-kit-slots.md).

A shared project-level slot is worth one caution. That file is usually already
the home for repo conventions, commands, and architecture notes — content the
whole team is bound by. Adding `03` to it is fine; adding `01` or `02` is not,
because personal preference does not belong in a file other people inherit. If
the project slot is already occupied by team-owned content, put `03` beside it
as its own file and reference it rather than merging the two.

## Crossing a session boundary

Long tasks get split across sessions, whether by compaction, by a deliberate
boundary between stages of work, or by handing off to a different agent. In
every one of those cases the state that survives is the state that was
**written down**. Retained context is not a transport mechanism, and any process
that deliberately starts a fresh session is asserting exactly that.

[`04-working-log.md`](templates/04-working-log.md) is the transport. That is its whole job: whatever the next
session needs must be in it before the current one ends. What it must not do is
become the authoritative home for something another document owns — a decision
belonging in a durable record, a convention belonging in a repo's own
conventions file, a rule some check enforces. The log points at those; it does
not restate them.

## Maintenance loop

Periodically (weekly, or at natural checkpoints), skim [`04-working-log.md`](templates/04-working-log.md) and
ask: is anything in here durable enough to belong in `01`, `02`, or `03`
instead? If yes, promote it and delete it from the log. If no, let it age out.
This mirrors how Anthropic describes compaction and note-taking for
long-horizon agents: distill what's structurally important, discard the rest —
don't let the scratchpad become a second, uncurated instructions file.

A promotion that lands somewhere outside this kit is a good outcome, not a
failure of the loop. A recurring correction that turns out to be a team
convention belongs in the team's conventions; one that turns out to be
mechanically checkable belongs in the check. Either way it leaves the log.
