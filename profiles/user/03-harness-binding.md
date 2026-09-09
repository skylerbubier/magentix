*[Magentix](../../README.md) › [Profiles](../README.md) › [User profile](README.md) › Harness binding*

# The Harness Binding

The one part of this collection that knows which agent tooling is in use. Everything else is portable.

---

## Why it is confined to one file

The claim this collection makes is that a person's criteria outlive their tooling. That claim is only true if the tooling is named in exactly one place.

The moment a criterion says something like "put this in the global instructions file," the criterion has become tool-specific, and switching tools means re-reading every criterion to find the ones that quietly assumed the old setup. Confining the binding to one file makes tool migration a single edit followed by a regeneration.

So the rule is absolute: **no criterion names a tool, a file path, a configuration key, or a product feature.** A criterion states a fact about the person. Where that fact gets written, and in what format, is resolved here.

## What the binding holds

```yaml
kind: user-harness-binding
owner: <the person>
last_confirmed: <YYYY-MM-DD>

harnesses:
  - id: <slug>
    tool: <what it is>
    role: primary | secondary | occasional
    slots:
      # Where this tool reads personal, always-loaded context from.
      always_loaded:
        path: <path>
        scope: personal | shared      # shared means DO NOT put criteria here
        format: <markdown | yaml | json | product-specific>
      # Where it reads deeper reference material loaded on demand.
      on_demand:
        path: <path>
        format: <…>
      # Where response-shape or presentation settings live, if separate.
      presentation:
        path: <path>
        format: <…>
      # Where the agent may write its own state. Must always be writable.
      agent_state:
        path: <path>
    capabilities:
      reads_personal_context: true | false
      supports_on_demand_reference: true | false
      supports_presentation_config: true | false
      can_enforce: true | false        # almost always false at personal scope
    precedence: <how this tool resolves multiple context sources, in its own terms>
```

## The fields that matter

**`scope: personal | shared`** is the most important field in this collection outside the criteria themselves. A slot marked `shared` is one other people inherit, and no criterion may ever be materialized into it. Getting this wrong is how a personal preference silently becomes a colleague's rule — and it is a mistake that is invisible until somebody else is confused by an instruction they never wrote.

When a tool's only always-loaded slot is shared, the correct answer is that this tool has no personal slot, and criteria are not materialized for it. Not "put them there anyway."

**`can_enforce`** is almost always `false` here. Personal context layers ask; they do not check. Recording it explicitly keeps a generator from producing an artifact that presents a preference as a control.

**`agent_state`** must be a path that is writable at any point in a task, including where other write restrictions apply. A profile that can be read but not corrected mid-task decays, because the moment a preference becomes visible is exactly the moment writing it down is inconvenient.

**`role`** exists because most people use more than one agent. A criterion renders into every harness that has a suitable slot; `role` decides which one gets the fuller treatment when they differ in capability.

---

## Multiple harnesses

One profile, several tools, is the normal case rather than the exception.

The criteria are shared across all of them. The binding lists each tool and its slots, and generation produces one artifact set per harness. That is the payoff of separating facts from documents: the same thirty criteria render into whatever shape each tool actually reads, and adding a new tool costs one binding entry and a regeneration — no interview.

Where harnesses differ in capability, the binding is what records it:

- A tool with no on-demand reference slot gets a more compressed artifact, and the generator knows to compress rather than to drop.
- A tool with no presentation slot gets presentation criteria folded into its always-loaded artifact instead.
- A tool with no personal slot at all gets nothing, and that is recorded rather than worked around.

## Migration

Changing tools is the case this design exists for. The procedure:

1. Add the new harness to the binding, with its slots and capabilities.
2. Regenerate. Every criterion renders into the new shape.
3. Verify each generated artifact actually loads where the binding says it will — an artifact in a location the tool does not read is stored, not adopted, and this fails silently.
4. Retire the old harness entry when it is no longer in use, and remove its artifacts.

No criterion is read, edited, or re-confirmed at any point in that sequence. If a migration requires touching criteria, something tool-specific leaked into one of them, and that is the bug.

## What this file is not

- **Not a place for preferences.** It records where things go, never what should be in them.
- **Not a copy of anyone's documentation.** Record the paths and capabilities this collection depends on; point at the tool's own docs for everything else.
- **Not a claim of enforcement.** `can_enforce: true` at personal scope would be unusual and should be justified by naming the mechanism, not asserted.
- **Not shared.** This binding describes one person's setup. A project's tooling capability is a different fact in a different collection with a different owner.
