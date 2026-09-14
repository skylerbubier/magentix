# CLAUDE.md

This file governs an agent working **on Magentix's own source** — it is not a profile, not an
example artifact, and not one of the generated files this repository teaches others to produce. If
you were about to fill in a blueprint template or write a project profile fact, stop: that's
[`adoption/README.md`](adoption/README.md)'s job, not this one. This document is for changes to the
repository itself.

## What this repo is

Magentix is a Claude Code plugin — the whole repository is the plugin, `.claude-plugin/plugin.json`
sits at the root, and `${CLAUDE_PLUGIN_ROOT}` resolves here. It ships best-practice blueprints,
profile schemas, an adoption engine that compiles the two into working artifacts, and the skills
and subagents that run that loop — but it ships **no active hooks of its own**. Everything
downstream of a change here is either a normative document someone reads, a schema someone's facts
conform to, or a skill an agent invokes; nothing in this repo mutates a session's tool permissions
on its own.

| Role | What it is | Owned by | Lives in |
|---|---|---|---|
| **Blueprint** | Normative best practice — general, read-only | Its author, elsewhere | `blueprints/` |
| **Profile** | Situated fact about one person or project | The adopter | `profiles/` |
| **Engine** | Compiles a blueprint against a profile into a practice | Nobody in particular | `adoption/` |
| **Artifacts** | Generated instructions, hooks, checks | Nobody — regenerable | Wherever the harness binding says |

## Where a change belongs

| If the change is... | It belongs in... |
|---|---|
| A normative best practice — how some kind of work should be done | `blueprints/` |
| A fact-collection schema change — a new field, category, or record shape | `profiles/` |
| A change to how blueprints and profiles are compiled — a stage, a check, a template | `adoption/` |
| The executable surface — a new skill, a change to how one runs | `skills/` |
| Tool-specific material — a mapping onto one concrete agent tool | `templates/harness/<tool>/` only |

`templates/harness/<tool>/` is the **only** place a tool name may appear outside a harness binding
(`profiles/user/03-harness-binding.md`, `profiles/project/04-harness-binding.md`). If you're about
to write "Claude Code," "Cursor," or any other product name into a blueprint, a profile record, or
an adoption-engine document, stop — that fact belongs in one of those two files instead.

## Invariants a contributor must not break

Quoted, not paraphrased — paraphrase is where they erode (see [`docs/architecture.md`](docs/architecture.md),
[`adoption/01-loop.md`](adoption/01-loop.md)):

- **"The blueprint is read, never written."** An awkward element gets a recorded conflict and an
  escalation, never an edited blueprint.
- **"Drafting is wide, materialization is narrow."** Target locations are read-only until a spec is
  approved and frozen, writable only at the declared paths afterward.
- **"Asserted and enforced are never conflated."** An artifact claiming enforcement must name a
  mechanism that fails closed, or it is demoted and the demotion recorded.
- **"One home per fact."** Reconcile against what already states a fact and point at it — two
  documents stating the same fact are a future contradiction.
- **"Authorship determines location."** An element authored by one person never materializes into a
  location the whole team inherits.
- **"A path belongs to exactly one practice."** Two practices writing the same file silently
  destroy one output; a collision is a human decision, never a merge.

## Conventions

- **Section layout.** Numbered documents inside a section (`adoption/01-loop.md` ..
  `05-profile-contract.md`), with a `README.md` as that section's landing page.
- **Breadcrumb.** The literal first line of a document is an italic breadcrumb:
  `*[Magentix](../README.md) › Section*`. Exception: the four agent-context-kit templates carry YAML
  frontmatter, which must stay the literal first bytes of the file — the breadcrumb goes
  immediately after the closing `---` there, not before it.
- **Cross-references** are real relative Markdown links, never bare backticked filenames.
- **Templates** live in a `templates/` directory beside the document that defines their schema
  (e.g. `profiles/user/templates/`, `blueprints/agent-context-kit/templates/`).
- **Diagrams** live in `docs/diagrams/`, cross-linked from the document each one illustrates.

## Skill-authoring conventions

- Kebab-case directory under `skills/`, containing `SKILL.md`.
- Frontmatter `description` leads with "Use when…" and carries the phrases a person would actually
  say, not a paraphrase of the mechanism.
- Body under roughly 500 lines; push full schemas, worked examples, and edge cases into
  `references/` inside the skill's own directory, linked rather than inlined.
- Reference this repo's own documents as `${CLAUDE_PLUGIN_ROOT}/…`; reference skill-local files as
  `${CLAUDE_SKILL_DIR}/…`.

## Do not

- **Do not add active hooks to this plugin.** A plugin's hooks fire on enable, and this repo must
  not silently intercept anyone's tool calls — hook material is example-only, under
  `templates/harness/`.
- **Do not introduce an org name, a person's name, or a specific repo layout** into a blueprint or a
  profile document. Both must stay portable across whoever adopts them.
- **Do not restate a fact that already has a home elsewhere.** Link to it instead.

## Before opening a PR

1. Run what CI runs ([`.github/workflows/validate.yml`](.github/workflows/validate.yml)) — it is
   the one check this repository enforces rather than asserts:

   ```
   claude plugin validate .claude-plugin/marketplace.json --strict
   claude plugin validate skills --strict
   claude plugin validate agents --strict
   claude plugin validate .claude-plugin/plugin.json
   ```

   The last one is not run with `--strict` because this file, `CLAUDE.md` at the plugin root,
   draws a deliberate warning: it governs work on the repository and is not shipped as plugin
   context. CI accepts exactly that warning and fails on any other. If you touch
   `scripts/Test-PracticeDrift.ps1`, CI also checks its three documented exit codes.
2. Check that every relative link you touched actually resolves.
3. Confirm [`docs/glossary.md`](docs/glossary.md) covers any new term you introduced.
