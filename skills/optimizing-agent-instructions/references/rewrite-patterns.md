# Rewrite patterns

Before/after pairs for the moves named in SKILL.md. Each pair shows the unit tag from the intent inventory and the reasoning. Apply the reasoning, not the exact words.

## Contents
- Delete filler
- Collapse duplicates
- Fix the description field
- Make fragile steps exact
- Loosen over-specified judgment calls
- Replace edge-case lists with canonical examples
- Add the missing "why"
- Pair negatives with positives
- Remove time-bound wording
- Push bulk down a tier
- Structure a cold-start subagent
- Compress a CLAUDE.md
- What not to touch

---

## Delete filler

Tag: `FILLER`. The model already knows this.

Before (≈70 tokens):
> Markdown is a lightweight markup language that is widely used for documentation. When you write documentation, it is important that you use Markdown correctly so that it renders well. Please make sure to use proper heading levels and to format code with code fences.

After (≈12 tokens):
> Docs are Markdown. Use `##` for sections and fenced code blocks.

Kept: heading level convention and fencing (`HEURISTIC`). Dropped: definition of Markdown, motivation.

## Collapse duplicates

Tag: two `HARD` units saying the same thing in different words.

Before:
> Always run the tests before committing.
> …
> Never commit code without first making sure the test suite passes.
> …
> Remember: tests must pass before any commit.

After:
> Run `npm test` before every commit; do not commit on failure.

One statement, one location, with the literal command the source implied but never named (ask if the command is not evident).

## Fix the description field

Tag: `HARD` (triggering surface). Third person, what + when, specific nouns.

Before:
> I can help you work with spreadsheets and do various data tasks.

After:
> Analyzes Excel and CSV files: pivots, charts, cleanup, formula repair. Use when the user mentions spreadsheets, .xlsx, .csv, tabular data, or asks to chart or summarize numbers.

Do not shorten a description that repeats trigger phrases on purpose. Verbosity here is a feature if it fixes under-triggering; ask before cutting.

## Make fragile steps exact

Tag: `HEURISTIC` in the source that should have been `HARD` (irreversible operation, observed failure, or literal string).

Before:
> Run the migration script with backup enabled and check it worked.

After:
> Run exactly:
> ```bash
> python scripts/migrate.py --verify --backup
> ```
> Do not add or change flags. Proceed only if the output ends with `OK`.

The exact flags and success condition came from the source's bundled script; if they are not discoverable, this is a clarifying question.

## Loosen over-specified judgment calls

Tag: `HARD` in the source that should be `HEURISTIC` (brittle if-else over a matter of taste).

Before:
> If the function is longer than 20 lines, split it. If it has more than 3 parameters, use an options object. If nesting exceeds 2 levels, extract a helper. If a comment is longer than 80 characters, wrap it.

After:
> Prefer small functions with few parameters and shallow nesting; split or extract when a reader would otherwise need to hold more than one idea at a time. Wrap comments at 80 columns.

The line-length rule stayed exact (a formatter would enforce it); the rest became a goal with a reason. Confirm with the user that the numeric thresholds were illustrative, not contractual, before loosening.

## Replace edge-case lists with canonical examples

Tag: `EXAMPLE` / `HEURISTIC`. Twelve rules become three examples that imply the rules.

Before:
> Commit messages must start with a type. Types are feat, fix, chore, docs, refactor, test. After the type, an optional scope in parentheses. Then a colon and a space. Then a summary under 72 characters in imperative mood, no trailing period. Then a blank line. Then a body explaining why…

After:
> Commit messages follow these examples:
> ```
> feat(auth): add JWT refresh endpoint
>
> Tokens expired mid-session; refresh keeps users logged in.
> ```
> ```
> fix(reports): use UTC in date bucketing
>
> Local-time bucketing double-counted rows at midnight.
> ```
> ```
> chore: bump lodash to 4.17.21
> ```
> Types: feat, fix, chore, docs, refactor, test. Summary ≤72 chars, imperative, no period.

The allowed types and the 72-char limit are `HARD` and stay explicit; everything else is carried by the examples.

## Add the missing "why"

Tag: `HEURISTIC` with no rationale, so the model cannot generalize.

Before:
> Do not use `SELECT *`.

After:
> Name columns explicitly in `SELECT`; `*` breaks callers when the schema changes and hides which fields a query depends on.

Slightly longer, materially better: the model now also avoids `RETURNING *` and unnamed destructuring, which the original never mentioned.

## Pair negatives with positives

Tag: `HARD`. A bare prohibition leaves the model without an action.

Before:
> Never use `PyPDF2`.

After:
> Use `pdfplumber` for text extraction (`pypdf` for page manipulation). Do not use `PyPDF2`; it is unmaintained.

## Remove time-bound wording

Tag: `FACT` that will rot.

Before:
> As of March we're on the new API. If you're working before the cutover, use `/v1/messages`; afterwards use `/v2/messages`.

After:
> Endpoint: `api.example.com/v2/messages`.
>
> <details><summary>Old patterns</summary>
> `/v1/messages` — retired; do not use.
> </details>

## Push bulk down a tier

Tag: `FACT` / `EXAMPLE` that is not needed on most runs.

Before (in SKILL.md): 180 lines of table schemas for six datasets.

After (in SKILL.md):
> Datasets and their schemas live in `references/`. Read only the one the task needs:
> - Finance (revenue, billing) → `references/finance.md`
> - Sales (pipeline, accounts) → `references/sales.md`
> - Product (usage, features) → `references/product.md`

Each reference file starts with a short contents list. SKILL.md drops from 240 lines to 60; the schemas cost nothing until read.

## Structure a cold-start subagent

Tag: mixed. A subagent body that assumes shared context will fail because it has none.

Before:
> You are a code reviewer. Review the changes and report back.

After:
> You review a git diff for correctness, security, and adherence to `CLAUDE.md` conventions. You start with no context: run `git diff --staged` (or the range given in the prompt) first.
>
> Return exactly:
> ```
> ## Blocking
> - <file:line> — <issue> — <fix>
> ## Should fix
> - ...
> ## Notes
> - ...
> ```
> Return an empty section rather than omitting it. Do not modify files.

## Compress a CLAUDE.md

Tag: mixed; always-loaded tier, so cut hardest.

Before (excerpt, 30 lines):
> Welcome to the project! This is a monorepo containing our frontend and backend. We use TypeScript everywhere because we believe in type safety. The frontend is React and the backend is NestJS. Please always write clean, maintainable code and follow best practices. We care a lot about testing. Run tests often. Use `pnpm` not `npm`. Our CI runs lint, so please lint before pushing. …

After (8 lines):
> ## Commands
> - Install: `pnpm i` (never `npm`)
> - Test: `pnpm test` — run before every commit
> - Lint: `pnpm lint` — CI fails on lint errors
>
> ## Layout
> - `apps/web` React (Vite) · `apps/api` NestJS · `packages/shared` types used by both
> - Conventions per area: see `apps/web/CLAUDE.md`, `apps/api/CLAUDE.md`

Dropped: welcome, philosophy, "clean code", "best practices" (the model already tries). Kept every literal command and the one fact the model cannot infer (which package manager). Area-specific rules moved to subdirectory files that load only when relevant.

---

## What not to touch

- Literal strings: commands, flags, paths, field names, regexes, template variables, tool names. Copy exactly. Ask about apparent typos.
- Safety, security, permission, and data-handling clauses. Tighten wording, never scope.
- Deliberate repetition in descriptions or at the end of long bodies that exists to fight under-triggering or mid-context forgetting. Confirm before removing.
- The artifact's `name`, path, and any identifiers other files reference.
- Sections the user marked as final or negotiated.
