*[Magentix](../../README.md) › [Profiles](../README.md) › [Project profile](README.md) › Harness binding*

# The Harness Binding

The one part of this collection that knows which agent tooling the project carries.

---

## Why it is confined to one file

Same reason as at personal scope, with a sharper edge: a project outlives the tooling used on it, and a project profile is shared. If a fact anywhere in the collection assumes a particular agent's file layout, then a team adopting a different agent has to re-survey a project they already surveyed.

So: **no fact names an agent tool, a config path, or a product feature.** Facts describe the project. Where agent-facing artifacts go, and in what format, resolves here.

The binding is also where the collection records something the user-scope binding never has to: **which slots are shared.** At personal scope that field prevents a preference leaking into a team file. Here, nearly everything is shared, and the field's job inverts — it identifies the small number of slots that are *not*, so that per-person artifacts are not written into the repository.

## What the binding holds

```yaml
kind: project-harness-binding
project: <project id>
owner: <one named person>
last_verified: <YYYY-MM-DD>

harnesses:
  - id: <slug>
    tool: <what it is>
    adoption: <required | supported | tolerated>
    slots:
      # Shared, always-loaded project context. Inherited by everyone.
      project_context:
        path: <path>
        scope: shared
        format: <markdown | yaml | product-specific>
        owned_by_practice: <practice-id, or unclaimed>
      # Deeper reference material loaded on demand.
      on_demand:
        path: <path or directory>
        format: <…>
        owned_by_practice: <practice-id, or unclaimed>
      # Deny-only or advisory automation the tool supports.
      automation:
        path: <path or directory>
        kind: <hook | check | task>
        fails_closed: <true | false>
        owned_by_practice: <practice-id, or unclaimed>
      # Per-person, NOT committed. Personal artifacts go here or nowhere.
      personal_overlay:
        path: <path>
        scope: personal
        committed: false
      # Agent working state. Always writable, never project content,
      # never reviewed, never part of any declared write-set.
      agent_state:
        path: <path>
    capabilities:
      reads_project_context: <true | false>
      supports_on_demand_reference: <true | false>
      supports_automation: <true | false>
      automation_fails_closed: <true | false>
      automation_bypassable: <how, or none>
    precedence: <how this tool resolves multiple context sources, in its own terms>
```

## The fields that matter

**`owned_by_practice`** is the path-ownership rule made concrete at the slot level. A project running several practices has several claimants for the main context file, and this field records which one owns it. The rest contribute through paths that file references. Leaving it `unclaimed` on a slot that two practices write is exactly the collision the index reports.

**`automation_fails_closed` and `automation_bypassable`** connect this file to the capability inventory. An agent tool's hooks are usually deny-only at best and routinely bypassable — a write through a shell redirect is not a tool call, so a path-based rule never sees it. Recording that here keeps a generator from treating tool-level automation as a control when it is fast local feedback. Where something must actually hold, it routes through a pipeline or platform capability instead, and the inventory says which exist.

**`personal_overlay`** is the boundary with the [user profile](../user/README.md). It is the only slot in a project's binding where per-person artifacts may be written, and it is uncommitted by construction. If a tool has no such slot, then personal artifacts have no home in this project — which is correct, and is not solved by writing them into a shared file.

**`agent_state`** must be writable at every point in a task, including under whatever write restrictions a practice imposes. A practice whose own path rules can deny an agent's note-taking produces an agent that cannot hand off work across a session boundary.

**`adoption`** exists because teams are rarely uniform. `required` means everyone uses it and artifacts can be relied upon. `tolerated` means somebody uses it and artifacts should not be assumed present.

---

## Several harnesses on one project

Common, and it changes what should be generated.

Where different people use different tools on the same repository, the shared slots have to be generated for each tool that is `required` or `supported`. That produces several artifacts stating the same project facts in different formats — which is acceptable **only** because all of them are generated from one source and regenerated together. Hand-maintaining two of them would guarantee divergence.

One rule keeps this from getting out of hand: **shared artifacts are generated per harness; the facts they express are identical.** If two harnesses' artifacts say different things about the project, one of them was edited by hand and the drift check will find it.

## Migration

1. Add the new harness with its slots, capabilities, and `adoption`.
2. Move `owned_by_practice` claims to the new tool's equivalent slots.
3. Regenerate every live practice's artifacts for the new harness.
4. Verify each landed artifact is actually read by the tool, and re-test any automation by violating it.
5. Mark the old harness retired and remove its artifacts.

No fact is touched. Step 5 matters more than it looks: a retired tool's context file left in the repository keeps being loaded by anyone still running that tool, and it will be stale.

## What this file is not

- **Not a capability inventory.** It records what the agent tooling can do. What the *project* can enforce lives in the capability facts, and pipeline and platform controls are almost always stronger than anything in this file.
- **Not a place for conventions.** It records where things go, never what should be in them.
- **Not per-person.** One binding per project, describing the tooling the project carries. A person's own setup is a separate collection.
