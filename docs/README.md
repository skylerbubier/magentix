*[Magentix](../README.md) › Docs*

# Docs

This directory is cross-cutting reference, not one of the three bodies of content this repository
organizes. Read here for the conceptual model and the shared vocabulary; read a section's own
landing page for its substance.

## The two documents

- [`architecture.md`](architecture.md) — the authoritative statement of the four-role model
  (Blueprint, Profile, Engine, Artifacts), how they compose, the precedence order when sources
  disagree, and the split between what's mechanical and what's judged. Read this first, and before
  touching `blueprints/`, `profiles/`, or `adoption/`.
- [`glossary.md`](glossary.md) — every named term across the five bodies of work, alphabetized,
  with explicit disambiguation wherever two documents reuse the same word for different things
  (`audience`, `scope`, `conflict`, `manifest`, `precedence`, `SPEC`...). Read this when a term
  looks reused and you're not sure whether it means the same thing in both places.

## Diagrams (`diagrams/`)

Six `.excalidraw` files, each a companion to one document rather than a standalone artifact:

| Diagram | Shows | Companion to |
|---|---|---|
| [`agentic-ecosystem.excalidraw`](diagrams/agentic-ecosystem.excalidraw) | The two blueprint families and two profile kinds feeding one adoption loop, producing user-scoped and project-scoped artifacts, plus the agent-agnostic boundary | [`adoption/README.md`](../adoption/README.md) |
| [`adoption-loop.excalidraw`](diagrams/adoption-loop.excalidraw) | The loop's own stages in detail — DRAFT through the approval gate, FREEZE, APPLY, and re-entry | [`adoption/README.md`](../adoption/README.md) |
| [`agent-context-kit.excalidraw`](diagrams/agent-context-kit.excalidraw) | How the four Agent Context Kit documents interact — precedence when more than one is loaded, one request's turn through them, and the maintenance loop | [`blueprints/agent-context-kit/README.md`](../blueprints/agent-context-kit/README.md) |
| [`ai-sdlc-flow.excalidraw`](diagrams/ai-sdlc-flow.excalidraw) | The two-phase spec-driven pipeline — conversation, specification, and implementation planes against the control plane, freeze through promotion | [`blueprints/ai-sdlc/overview.md`](../blueprints/ai-sdlc/overview.md) |
| [`user-profile.excalidraw`](diagrams/user-profile.excalidraw) | The criterion unit, the collection's categories and four moves, and why a correction outweighs a stated preference | [`profiles/user/README.md`](../profiles/user/README.md) |
| [`project-profile.excalidraw`](diagrams/project-profile.excalidraw) | The fact unit, plurality across projects and practices, and the capability inventory's fail-closed test | [`profiles/project/README.md`](../profiles/project/README.md) |

## The three bodies of content

Docs describes them; it isn't one of them. Start at the section's own landing page:

- [`blueprints/README.md`](../blueprints/README.md) — the best practices on offer
- [`profiles/README.md`](../profiles/README.md) — situated fact, personal and project
- [`adoption/README.md`](../adoption/README.md) — the loop that compiles one against the other
