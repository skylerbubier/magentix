# Review checklist

Run after the rewrite and before delivery. Answer each honestly; a "no" is a defect to fix or a note for the change summary, not a reason to skip.

## Fidelity
- [ ] Every `HARD`, `HEURISTIC`, `FACT`, and `EXAMPLE` line in the intent inventory maps to a location in the output.
- [ ] No behavior was added that the source did not have, unless the user asked for it and the summary labels it as new.
- [ ] No `HEURISTIC` was silently promoted to `HARD`, and no `HARD` was silently demoted.
- [ ] Literal strings (commands, paths, flags, field names, regexes, template variables, tool names) match the source character for character.
- [ ] Safety, security, permission, and data-handling clauses are present and at least as strong.
- [ ] `name`, file path, and externally referenced identifiers are unchanged.

## Precision
- [ ] Each fragile or irreversible step names the exact action and its success condition.
- [ ] Each output format the artifact requires is shown as a template or example, not described in prose.
- [ ] No instruction relies on context the reader will not have (a subagent starts cold; a skill body cannot see the description's reasoning).
- [ ] Conflicts between instructions are resolved or explicitly ordered ("X overrides Y when…").
- [ ] Ambiguous scope words are gone or bounded: "always/never" say when; "the tests" say which; "recent" says how recent.

## Economy
- [ ] No definitions of things a capable model knows.
- [ ] No sentence restates another sentence.
- [ ] No preamble, sign-off, or motivational framing.
- [ ] One term per concept throughout.
- [ ] Emphasis markers (`ALWAYS`, `NEVER`, `CRITICAL`, bold) appear only on items that are truly `HARD`, and sparingly.
- [ ] Content not needed on most runs lives in a reference file, linked once with a "read when…" condition; references are one level deep.
- [ ] Reference files over ~100 lines open with a contents list.
- [ ] Always-loaded text (descriptions, CLAUDE.md, system prompt) has been cut hardest.

## Openness
- [ ] Judgment calls state the goal and the reason, not a decision tree.
- [ ] Rules that exist to pre-empt unobserved failures were questioned or removed.
- [ ] The reader has an action for every prohibition.

## Format and host
- [ ] Frontmatter fields are valid for the host (see `artifact-formats.md`); none were dropped.
- [ ] Description is third person and includes both what and when.
- [ ] Forward-slash paths only.
- [ ] MCP tools use `Server:tool_name`.
- [ ] Scripts are marked as run vs read.
- [ ] No dated or "as of" statements outside a collapsed *Old patterns* section.

## Process
- [ ] `scripts/measure.py` was run on before and after; remaining flags were reviewed and either fixed or accepted with a reason.
- [ ] The result was read once cold, as the target model, and nothing required guessing.
- [ ] Every `UNKNOWN` was either answered by the user or listed under *Assumptions made*.
- [ ] The change summary lets the user audit every deletion without a diff.
- [ ] If an eval harness exists, it was run or explicitly offered.
