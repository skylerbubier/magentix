---
name: optimizing-agent-instructions
description: Use when agent-facing text should be tightened, condensed, clarified, de-duplicated, restructured for progressive disclosure, or reviewed for quality — "make this prompt better", "shorten my CLAUDE.md", "clean up this skill", "why does the agent ignore this rule", or any request to audit or maintain instructions consumed by an LLM. Rewrites an existing prompt, SKILL.md, CLAUDE.md, rules file, slash command, subagent, or system prompt so it costs fewer tokens, states hard constraints unambiguously, and leaves judgment calls open; preserves every intended behavior and asks targeted clarifying questions where intent is unclear.
---

# Optimizing Agent Instructions

Take instruction text written for an agent and return a version that says the same thing with fewer, higher-signal tokens. The output is judged on three axes, in priority order:

1. **Fidelity** — no intended behavior is lost, weakened, or invented.
2. **Precision where it matters** — fragile steps, exact strings, and non-negotiables are unambiguous.
3. **Economy** — everything else is as short as it can be while still steering the model.

The reader is a capable model. Assume it knows what a PDF is, how git works, and what "be concise" means. Only tokens that change its behavior earn their place.

## Inputs to gather

From the conversation and any attached files, establish before editing:

- **The artifact** — full text, plus bundled files it references.
- **Artifact type and host** — SKILL.md, subagent, slash command, CLAUDE.md/AGENTS.md, IDE rules file, raw system prompt, API prompt template. Format rules differ; see [references/artifact-formats.md](references/artifact-formats.md).
- **Loading tier** — always-in-context (CLAUDE.md, skill descriptions, system prompts) or loaded on demand (SKILL.md body, references). Always-loaded text has the strictest token budget.
- **Target model(s)** — smaller models need more guidance; frontier models need less.
- **Observed failures**, if any — "the agent skips step 3", "it triggers on the wrong tasks". Failures tell you which sections are under-specified rather than verbose.

If the type or host is not stated and cannot be inferred from frontmatter, paths, or vocabulary, that is a clarifying question (see below), not a guess.

## Workflow

Copy this checklist into your working notes and check items off:

```
Optimization progress:
- [ ] 1. Classify artifact, host, tier, target model
- [ ] 2. Build the intent inventory
- [ ] 3. Ask clarifying questions (batched) and wait
- [ ] 4. Calibrate freedom per item
- [ ] 5. Rewrite
- [ ] 6. Verify: measure + inventory diff + checklist
- [ ] 7. Deliver artifact + change summary
```

### 1. Classify

Identify type, host, tier, and model as above. Read the matching section of [references/artifact-formats.md](references/artifact-formats.md) for frontmatter fields, length limits, and host-specific behaviors (e.g. description text drives auto-invocation; `tools:` is an allowlist).

### 2. Build the intent inventory

List every distinct unit of meaning in the source: each instruction, constraint, fact, example, template, and pointer to another file. One line per unit. Tag each:

| Tag | Meaning | Default treatment |
|---|---|---|
| `HARD` | Non-negotiable: exact command, path, format, safety guardrail, legal/compliance rule | Keep verbatim or tighten wording only; never soften |
| `HEURISTIC` | Guidance for judgment calls: style, priorities, "prefer X" | Keep the intent; compress; add the *why* if missing and non-obvious |
| `FACT` | Context the model lacks: schema, team convention, domain rule | Keep; move to a reference file if bulky and not always needed |
| `EXAMPLE` | Input/output pair or template | Keep the canonical few; drop redundant variants |
| `FILLER` | Explains what the model already knows, restates another unit, hedges, or is a preamble | Delete |
| `UNKNOWN` | Intent, scope, or precedence is unclear | Ask |

This inventory is the fidelity contract. Every `HARD`, `HEURISTIC`, `FACT`, and `EXAMPLE` line must map to a location in the rewritten output. Do it even for short artifacts; it takes a minute and is the only thing that stops silent behavior loss.

### 3. Ask clarifying questions

Ask only about `UNKNOWN` items and about decisions that change the output materially. Do not ask what the source, filenames, frontmatter, or conversation already answer. If nothing is unknown, skip this step and say so in the change summary.

Rules for the question set:

- Batch all questions into one message. One round is the target; two is the ceiling before proceeding on stated assumptions.
- For each question, state the specific text at issue, why it is ambiguous, and your proposed default. A question the user can answer with "yes, use your default" costs them nothing.
- Prefer closed options (2–4 choices) over open prompts. If an interactive option-picker tool is available, use it.
- Typical triggers: two instructions that conflict; a rule with no stated scope ("always run tests" — which tests, when); a `MUST` whose consequence of violation is unclear (fragile or just emphatic?); an example that contradicts the prose; a reference to a file, tool, or team convention that is not in view; a description that seems to under- or over-trigger.

If the user says "just do it", proceed, resolve each `UNKNOWN` toward the interpretation that preserves the most existing behavior, and list every assumption in the change summary.

### 4. Calibrate freedom per item

For each surviving unit, decide how tightly to specify it:

| Make it exact when | Leave it open when |
|---|---|
| The operation is fragile or irreversible (migrations, deletes, deploys, money) | Several approaches are valid and context picks the best one |
| Consistency across runs is the point (output schema, naming, commit format) | The model's judgment is better than any rule you could write |
| A literal string must match (paths, tool names, CLI flags, regexes, API fields) | The instruction is about tone, priority, or taste |
| The model demonstrably gets it wrong without the rule (an observed failure) | You are writing the rule to pre-empt a failure you have not seen |
| Violation has a compliance, safety, or security consequence | It is a preference, not a requirement |

Exact items get imperative sentences, literal strings in backticks, and no hedging. Open items get the goal plus the reason; a short "because" lets the model generalize to cases the rule never anticipated. Do not convert a `HEURISTIC` into a `HARD` rule to make it feel safer; that trades adaptability for brittleness the source author did not ask for.

### 5. Rewrite

Apply the patterns in [references/rewrite-patterns.md](references/rewrite-patterns.md). The core moves:

- **Delete `FILLER`.** Preambles, definitions of common terms, "it is important to note", restated rules, motivational framing.
- **One term per concept.** Pick a word and use it everywhere.
- **Imperative voice** for the body; **third person** for any description field ("Generates…", never "I can…" or "You can…").
- **Literal strings verbatim.** Never paraphrase a command, path, field name, or code block. Never fix what looks like a typo in a literal without asking.
- **Canonical examples over edge-case lists.** Three diverse examples usually beat twelve rules.
- **Front-load what governs the whole task**; put rare-case detail later or in a reference file.
- **Progressive disclosure.** Bulky `FACT`s and `EXAMPLE`s that are not needed every run move to `references/<descriptive-name>.md`, linked once from the main file with a sentence saying *when* to read it. References stay one level deep. Files over ~100 lines get a table of contents.
- **Negatives only when needed**, and paired with the positive alternative ("Use `pdfplumber`; do not use `PyPDF2`").
- **No time-bound statements.** "Since v2 use…" becomes "Use…" with a collapsed *Old patterns* section if history matters.
- **Keep guardrails.** Safety, security, permission, and data-handling clauses are `HARD` by default even when they read as verbose.
- **Preserve identity.** Same `name`, same file path, same trigger surface unless the user asks to change them.

Length is an outcome, not a target. A 40-line artifact that loses one `HARD` rule is worse than an 80-line one that keeps it.

### 6. Verify

Run the measurement script on source and result:

```bash
python ${CLAUDE_SKILL_DIR}/scripts/measure.py <original> <optimized>
```

It reports lines, words, approximate tokens, and flags: filler phrases, duplicate lines, second-person description text, time-sensitive wording, backslash paths, nested-reference chains, and ALL-CAPS directive density. Treat flags as prompts to look, not as errors.

Then:

1. Walk the intent inventory. For each non-`FILLER` line, point to where it lives now. Anything unaccounted for goes back in.
2. Read the result once as the target model would, cold, with no memory of the source. Note anything you would have to guess at. Fix or ask.
3. Run [references/review-checklist.md](references/review-checklist.md).

If an eval harness exists for the artifact (the skill-creator tooling, a team's prompt tests), offer to run it; do not claim the rewrite works without evidence when evidence is available.

### 7. Deliver

Produce two things:

**The optimized artifact**, as a file in its original format and name. If bundled references were created or changed, deliver those too.

**A change summary** in this shape:

```
## Summary
Before → after: N lines / ~T tokens → N' / ~T' (−X%)

## Removed (and why)
- <unit>: filler — model already knows this
- <unit>: duplicated by <other unit>

## Tightened
- <unit>: made exact because <fragile / literal / observed failure>

## Loosened
- <unit>: converted rule → heuristic with rationale because <reason>

## Moved
- <content> → references/<file>.md, read when <condition>

## Assumptions made
- <UNKNOWN item> resolved as <interpretation>

## Open questions / suggested evals
- ...
```

Keep the summary proportionate; three bullets for a small edit, the full shape for a large one. The user must be able to audit every deletion without diffing files.

## When not to optimize

- The artifact is already tight and the user asked for a review: say so, list any real issues, and stop. Do not manufacture changes.
- The user wants new capability, not compression. Add it, then optimize the whole, and say which parts are new.
- The text is a legal, compliance, or security policy where wording was negotiated. Flag candidates; do not rewrite without explicit approval.

## Anti-patterns

- Compressing rationale out of heuristics, leaving bare commands the model cannot generalize.
- Promoting emphasis words (`ALWAYS`, `NEVER`, `CRITICAL`) into every sentence; density destroys the signal.
- Inventing behavior the source did not have because it "seemed implied".
- Rewriting a pushy skill description into a neutral one and thereby breaking auto-invocation. Descriptions may be repetitive on purpose; check triggering intent before trimming.
- Reformatting for its own sake. Headers, tables, and XML tags earn their place only when they help the model locate something.
- Splitting a short artifact into many files. Progressive disclosure is for content that is not needed on most runs, not for tidiness.
- Asking questions the source already answers, or asking more than one round without proposing defaults.
