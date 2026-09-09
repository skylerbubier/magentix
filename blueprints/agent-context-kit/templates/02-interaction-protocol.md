---
kind: agent-context
owner: <you>
applies_to: global
last_reviewed: <YYYY-MM-DD>
---

*[Magentix](../../../README.md) › [Blueprints](../../README.md) › [Agent Context Kit](../README.md) › Interaction Protocol*

# Interaction Protocol

<!-- This file answers "how should the agent behave with me, in the moment."
Unlike 01-principal.md, expect to revise this as trust is established —
research on agent communication consistently finds people want more
visibility early and less over time, and that stakes should shift verbosity
even for the same person. Tune, don't set-and-forget. -->

## Terms used here

<!-- Two words in this file are used elsewhere with different meanings.
Pinned here so nothing conflates them:

- **Escalation** means surfacing something to *you* — pausing to get a
  human in the loop. It does not mean routing an issue up a process, and
  it is not a stage in any workflow.
- **Done** means this file's completion report. Whether a piece of work
  actually qualifies as complete is decided by the task's own acceptance
  criteria, not by this file. This file governs how completion is
  *communicated*. -->

## Scope of this file

<!-- Everything below governs the **conversation**: what the agent says to
you, how much, when it pauses, how it reports state.

It does not govern the content of anything the agent produces. A committed
document, a review report, test output, a required record — each of those
has its own required content, and a preference for brevity here never
trims one of them. "Be terse with me" is an instruction about the chat, not
a licence to write a thinner artifact. -->

## Output format defaults

<!-- Length, structure, prose vs. code, when to use tables/lists vs.
paragraphs. Be concrete — "concise" means different things to different
people. -->

- Default length/depth:
- Preferred structure:
- When to deviate from these defaults:

## Verbosity calibration

<!-- The core finding here: uniform verbosity fails almost everyone,
because the important signal gets buried at either extreme (silent vs.
dense log). Calibrate by situation, not once and for all. -->

| Situation | Desired verbosity |
|---|---|
| Routine / low-stakes task | |
| High-stakes / hard-to-reverse action | |
| Long-running / multi-step task | |
| Something went wrong | |

<!-- One floor sits under every row: evidence that a claim depends on is
never compressed away. If "the tests pass" is the claim, the output that
shows it stays, at any verbosity setting. Terse means fewer words about
the work, not fewer facts about the result. -->

## Autonomy & when to bring me in

<!-- Borrowing a useful vocabulary: for each class of action, name the level
of autonomy you actually want — observer (report only), consultant
(recommend, you decide), collaborator (act, but check in), approver (ask
before acting), operator (act and inform after). Different action classes
usually deserve different levels.

These levels express a preference *within what is already permitted*. Where
an action is constrained by an enforced mechanism — a denied tool call, a
required approval, a pipeline check, an org policy — that constraint wins,
and no level named here loosens it. "Operator" on a class of action that
some check gates means: act freely up to the gate, then stop at it and say
so. A level here can be stricter than the enforced floor; it is never
looser. -->

| Action class | Autonomy level | Notes |
|---|---|---|
| Read / investigate / analyze | | |
| Draft / propose changes | | |
| Modify things directly | | |
| Irreversible or external-facing actions | | |

## Progress signaling

<!-- How to represent state during longer tasks, and — critically — how to
distinguish these three from each other rather than presenting one uniform
stream: -->

- What "done" looks like / how completion should be reported:
- What "blocked" looks like / what to do when stuck:
- What "uncertain, proceeding anyway" looks like / how confidence should be flagged:

<!-- A fourth state is worth naming separately from "blocked," because the
response differs: **stopped at a control** — the agent hit something it is
not permitted to do rather than something it cannot figure out. That is not
a failure to report apologetically and not a problem to work around; it is
a decision that needs you. Say what was attempted, what stopped it, and what
you would have to decide. -->

## Clarification policy

<!-- When to ask vs. proceed on a reasonable assumption. Most people want a
default toward proceeding on low-stakes ambiguity and asking on high-stakes
ambiguity — state where your line is. -->

- Ask before proceeding when:
- Pick a reasonable default and state the assumption when:
