# Contributing to Magentix

Magentix is a Claude Code plugin whose whole repository is the plugin —
`.claude-plugin/plugin.json` sits at the root, so `${CLAUDE_PLUGIN_ROOT}`
resolves here. Before opening a PR, know which of the four layers your
change belongs to; putting content in the wrong layer is the most common
way a contribution gets sent back.

## The four layers, and where a contribution goes

| Layer | What it is | Names a tool? | Lives in |
|---|---|---|---|
| **Blueprint** | A normative best-practice document — how some kind of work should be done, in general terms | Never | `blueprints/<name>/` |
| **Profile** | Situated fact — what is actually true for one person or one project | Only in its one harness-binding file | `profiles/user/`, `profiles/project/` |
| **Engine** | The adoption loop that compiles a blueprint against a profile into a working practice | N/A — the engine itself is tool-agnostic | `adoption/` |
| **Skills** | The executable surface an agent actually invokes to run the loop | Yes — this is where tool specifics belong | `skills/` |

A change that reads like "this blueprint should mention Claude Code" is a
sign the fact belongs in a harness binding instead
(`profiles/user/03-harness-binding.md`,
`profiles/project/04-harness-binding.md`), not in the blueprint. A change
that reads like "this profile should explain how to do the work" is a sign
it belongs in a blueprint instead. If you're not sure which layer a change
belongs in, say so in the PR description rather than guessing — a
misplaced fact is cheap to fix in review and expensive to fix once other
content points at it.

## Adding a blueprint

A blueprint needs no Magentix-specific front matter and needs never to have
heard of Magentix — that's the point, per
[`blueprints/README.md`](blueprints/README.md). What it does need is to be
**readable** into
[`adoption/templates/blueprint-reading.yaml`](adoption/templates/blueprint-reading.yaml):
named elements with their own rationale, authorship, and enforcement nature;
its own invariants, stated precisely enough to become a spec-validation
assertion; an out-of-scope list; the slots it deliberately leaves open; an
adoption order if it states one; and a minimum viable subset. Draft the
reading as part of the PR so reviewers can see the blueprint is actually
blueprint-shaped, not just narrative prose with headers.

A blueprint that assumes a specific tool, restates something a check
already enforces, or never says who it's for (`individual | team | org`) is
a defect in the blueprint, not something adoption will route around later.

## Adding a harness template pack

A pack for a new agent tool goes in `templates/harness/<tool>/`, following
[`templates/harness/README.md`](templates/harness/README.md): map the five
abstract slots (project context, on-demand reference, automation, personal
overlay, agent state) onto that tool's real files, state its context and
settings precedence, and say plainly which of its mechanisms fail closed
and which don't — see `templates/harness/claude-code/README.md` for a
worked example of that last part. A pack is inert reference material,
copied elsewhere and adapted; never wire it into this repository's own
configuration.

## Authoring a skill

Skills are the executable surface — the one layer where naming a tool is
expected. Conventions:

- Directory name is kebab-case, under `skills/`.
- The frontmatter `description` states when to use the skill in "Use
  when…" terms specific enough that the right moment is unambiguous.
- Keep the skill's main body under roughly 500 lines. Detail that would
  push it past that — full schemas, worked examples, edge cases — goes in
  `references/` inside the skill's own directory, linked from the body
  rather than inlined.
- A skill that wraps part of the adoption loop should point at the
  relevant stage doc in `adoption/` rather than restating it.

## Before opening a PR

Run, from the repository root, what CI runs
([`.github/workflows/validate.yml`](.github/workflows/validate.yml)):

```
claude plugin validate .claude-plugin/marketplace.json --strict
claude plugin validate .claude-plugin/plugin.json
```

The second command validates every component the plugin ships — skills,
agents, and the root `CLAUDE.md`. It is not run with `--strict` locally
because that `CLAUDE.md` draws a deliberate warning (it governs work on
this repository and is not shipped as plugin context). CI reads the same
report as JSON, accepts exactly that warning, and fails on any other — so a
new warning you see locally will fail there. If you change
`scripts/Test-PracticeDrift.ps1`, CI also exercises its three documented
exit codes.

Beyond validation: if you touched a blueprint, confirm its reading in
`adoption/templates/blueprint-reading.yaml` terms; if you touched a
profile format, confirm existing examples in that profile's `templates/`
still match; if you touched a skill, confirm its body is still thin and
its detail is still in `references/`.

## Everything else

Small fixes — typos, broken links, a stale date — don't need any of the
above ceremony. Open a PR directly. If you're unsure whether a change is
small, it probably isn't; say what layer you think it touches and a
maintainer will redirect you if it's wrong.
