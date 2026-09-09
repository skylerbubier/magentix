---
kind: agent-context
maintained_by: agent
applies_to: <project or thread>
last_reviewed: <YYYY-MM-DD — when a human last skimmed this for promotion/pruning>
---

*[Magentix](../../../README.md) › [Blueprints](../../README.md) › [Agent Context Kit](../README.md) › Working Log*

# Working Log

<!-- This file is written by the agent, not curated by you. Its job is
continuity across sessions/compactions — the equivalent of the notes an
agent takes on itself during a long task. It's expected to be messier and
more disposable than the other three files. Skim it periodically; anything
durable gets promoted into 01/02/03 and deleted from here, everything else
ages out. Don't let this quietly become a second, uncurated instructions
file. -->

## Where this file lives

<!-- This is agent state, not project content. The agent must be able to
write it at any point in a task, so it belongs on a path that any
write-restriction policy in the repo excludes — a scratch or state
directory — or outside the repo entirely.

Two consequences worth stating, because both are easy to get wrong:

- A write to this file is not a change to the project. It should never
  count against a declared set of files a piece of work intends to touch,
  and it should never be what a reviewer is looking at.
- If writing it is ever denied, the log silently goes partial and the next
  session inherits a half-record. Fix the path, don't work around it. -->

## What belongs here, and what doesn't

<!-- Belongs here: state, in-flight context, and interaction-level
learnings — how this particular collaboration is going.

Does not belong here: anything another document owns. A durable decision
belongs in whatever record holds decisions; a team convention belongs in
the team's conventions; a mechanically checkable rule belongs in the check.
This file may *point* at any of those. It is never their authoritative
copy, because a copy here is the one nobody will update. -->

## Current focus

<!-- What's actively being worked on, and where it stands. -->

## Standing decisions

<!-- Decisions already made, with a one-line "why," so they aren't
re-litigated every session. Local and provisional by nature — a decision
that turns out to be durable gets promoted out of here into its real home,
and this row becomes a pointer or disappears. -->

| Decision | Rationale | Date |
|---|---|---|

## Corrections log

<!-- Mistakes made once, and the fix — so the same mistake doesn't repeat
across sessions.

Scope this to interaction and approach: a misread instruction, a wrong
assumption about what you wanted, a habit that wasted a turn. A correction
that is really a project convention, or really something a check should
catch, gets promoted to that home and leaves this table. Recurrence is the
signal: the same entry appearing a third time means it belongs somewhere
more permanent than a log. -->

| What went wrong | What to do instead | Date |
|---|---|---|

## Open threads / handoff notes

<!-- Anything left mid-flight that the next session (or a different agent)
needs to pick up. Write these as if the reader has none of the current
context, because that is the case whenever a session boundary is
deliberate: the next reader gets this file, not the conversation. State
what was being attempted, what is verified vs. assumed, and the next
concrete action. -->
