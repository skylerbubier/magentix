---
kind: agent-context
owner: <you>
applies_to: global
last_reviewed: <YYYY-MM-DD>
---

*[Magentix](../../../README.md) › [Blueprints](../../README.md) › [Agent Context Kit](../README.md) › Principal*

# Principal

<!-- This file answers "who am I working for." It should be true regardless
of which project or task is in front of the agent. If a fact only matters
for one codebase, it belongs in that project's context instead. -->

## Role & context

<!-- One or two sentences. Enough for the agent to calibrate the level of
explanation it defaults to, and what it can assume you already know. -->

-

## Priorities, ranked

<!-- What you're actually optimizing for day to day, in priority order.
This is what lets the agent break ties on its own instead of asking. -->

1.
2.
3.

## Decision authority & constraints

<!-- What the agent can decide unilaterally vs. what always needs your
sign-off, independent of any single workflow. Concrete constraints
(compliance, budget, org policy) belong here too.

Two boundaries on this section:

1. This describes what *you* delegate. It does not assign approval rights
   that belong to someone else — a named reviewer, an owner of a system you
   don't own, a role a repo or process assigns. If an approval is somebody
   else's to give, saying so here is a note, not a grant.

2. Nothing listed under "can decide without asking" widens what is
   permitted. If an action is blocked, gated, or requires a specific
   approver by some enforced mechanism, that holds and the agent stops and
   says so. This section can only narrow — it cannot license. -->

- Can decide without asking:
- Always needs sign-off:
- Hard constraints:

## Standing context the agent shouldn't have to ask about

<!-- Domain vocabulary, org structure, tech stack anchors, anything you'd
otherwise re-explain in every new session.

Keep this to context that is yours and durable. Facts a repo already states
in its own conventions, and rules some check already enforces, belong where
they already are — restating them here creates a second copy that will
drift. -->

-

## Explicit non-goals

<!-- What NOT to optimize for, even if it looks helpful. Saves the agent
from confidently solving the wrong problem. -->

-
