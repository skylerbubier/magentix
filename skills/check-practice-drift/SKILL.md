---
name: check-practice-drift
description: Use when checking whether a live, adopted practice needs to re-enter the adoption loop — "has this practice drifted", "is anything overdue for review", "re-check this manifest" — before touching a materialized artifact, or on a schedule. Runs the drift script and translates its findings into a response.
argument-hint: "[path to practice-manifest.json]"
---

Normative source: [drift-check.md](${CLAUDE_PLUGIN_ROOT}/adoption/checks/drift-check.md) and the script it implements, [`${CLAUDE_PLUGIN_ROOT}/scripts/Test-PracticeDrift.ps1`](${CLAUDE_PLUGIN_ROOT}/scripts/Test-PracticeDrift.ps1).

This skill produces a **drift report** for one practice manifest — which artifacts still match, which need attention, and which stage of [/magentix:adopt-practice](../adopt-practice/SKILL.md) each finding re-enters at — without fixing anything itself.

## Procedure

1. **Locate the manifest.** One `practice-manifest.json`, written by Step 10 of [/magentix:adopt-practice](../adopt-practice/SKILL.md).

2. **Run the script exactly:**

   ```
   pwsh ${CLAUDE_PLUGIN_ROOT}/scripts/Test-PracticeDrift.ps1 -Manifest <path-to-practice-manifest.json> [-Root <path>] [-WithinDays <n>]
   ```

   Documented parameters, read from the script itself:
   - **`-Manifest`** (mandatory, string) — path to `practice-manifest.json`.
   - **`-Root`** (optional, string) — base for resolving relative artifact paths. Defaults to the manifest's own directory.
   - **`-WithinDays`** (optional, int, default `0`) — also report reviews falling due within this many days, in addition to ones already elapsed.

   Documented exit codes, read from the script itself:
   - **`0`** — everything matches and nothing is due.
   - **`1`** — attention needed: at least one `DRIFTED`, `MISSING`, `REVIEW DUE`, `STALE`, or `PROFILE STALE` finding.
   - **`2`** — the manifest could not be read (missing file, or invalid JSON).

3. **Read the reported states exactly as the script emits them** — do not paraphrase or reclassify:

   | State | Meaning | How the script detects it |
   |---|---|---|
   | `DRIFTED` | A materialized artifact's SHA-256 no longer matches the manifest | Re-hash the file at the resolved path and compare to `artifacts[].sha256` |
   | `MISSING` | An artifact in the manifest is not on disk at all | The resolved path does not exist |
   | `REVIEW DUE` | An artifact's `review_by` date has elapsed | `review_by` parses as a date on or before today |
   | `REVIEW SOON` | An artifact's `review_by` falls within `-WithinDays` days from now | Only emitted when `-WithinDays > 0`; **not part of the state set this skill's brief names — see Ambiguities below** |
   | `STALE` | The blueprint changed since it was read | Recomputed tree hash of `blueprint.source` ≠ `blueprint.version_ref` |
   | `PROFILE STALE` | The profile changed since it was read | Recomputed tree hash of `profile.source` ≠ `profile.version_ref` |
   | `OK` | Reported once, as a count: `<n> artifact(s) match` | Every artifact whose hash matched and had no elapsed review |
   | `DEFERRED` | Listed verbatim from `manifest.deferred[]`, one line per entry with its trigger | Not computed — the script only echoes what the manifest already recorded |

   The report also prints a header (`Practice:`, `Blueprint:` source @ version, `Profile:` source @ version, artifact count, phase) and a footer naming the single nearest `review_by` date across all artifacts, or `Next review: none scheduled`.

   **`STALE` and `PROFILE STALE` are only computable when the corresponding `version_ref` is a 64-character hex string** — i.e. a SHA-256. The script treats a tree (a directory) as one hash: every file's path relative to the tree, joined with its own SHA-256 by `:`, all such lines sorted and newline-joined, then hashed. If `version_ref` is a commit id, a date, or anything else non-hash-shaped, blueprint/profile staleness is silently not checked — that is not a bug in your run, it is the documented limit of what the script can do. Say so rather than assuming the input is fresh.

4. **Apply the response, never fix anything directly:**

   | Finding | Response |
   |---|---|
   | `DRIFTED` | **Never silently overwrite it.** Drift is a signal, not a violation — a hand-edit usually means the adopter improved it. Route to `/magentix:adopt-practice` Step 4 (Reconcile), with the edit as an input: promote it into the spec, revert it deliberately with the adopter's knowledge, or — if the change is unrelated to this practice — treat it as a path-ownership conflict |
   | `MISSING` | The most severe form of drift. Treat as a deletion to reconcile at Step 4, never as an absence to silently regenerate |
   | `REVIEW DUE` | Route to Step 2 (Profile Reading & Verification): re-check the facts the artifact traces to before asking anybody anything. Only escalate to elicitation if verification cannot settle it |
   | `REVIEW SOON` | Informational — nothing re-enters yet. Useful for scheduling the next pass |
   | `STALE` | Route to Step 1 (Blueprint Reading), then Step 4 for the elements that actually changed — not the whole practice |
   | `PROFILE STALE` | Route to Step 4 (Reconcile), for the entries tracing to the superseded or retired fact only |
   | `DEFERRED` | Evaluate whether the recorded trigger has fired. If it has, route to Step 4 for that element alone. An element still deferred after two re-entries should be retired explicitly, not carried indefinitely |
   | `OK` | No action |

5. **Scope the re-entry to what changed.** Only artifacts whose element or traced facts actually changed re-enter drafting; everything else keeps its manifest entry untouched. This is what keeps maintenance minutes rather than a second full sitting.

## Without PowerShell

If `pwsh` is not available, perform the same comparisons manually against `practice-manifest.json`:

1. For each entry in `artifacts[]`: resolve `path` against `-Root` (or the manifest's directory if unset), compute its SHA-256, and compare to `sha256`. No file → `MISSING`. Hash mismatch → `DRIFTED`. Match → counts toward `OK`.
2. For each entry with a `review_by` that is a real date (not `never` or a placeholder): compare to today. On or before today → `REVIEW DUE`, with the elapsed day count and `owner`.
3. For `blueprint.version_ref` and `profile.version_ref`, only if each is exactly 64 hex characters: recompute the tree hash of its `source` (every file's path-relative-to-the-tree, joined to its own SHA-256 with `:`, all lines sorted, newline-joined, SHA-256 of the whole) and compare. Mismatch → `STALE` / `PROFILE STALE` respectively. If `version_ref` is not a 64-hex string, staleness of that input is not computable — say so.
4. List `deferred[]` entries verbatim, each with its `trigger`.
5. Report the single soonest `review_by` across all artifacts, or that none is scheduled.

## Do not

- Do not reclassify a `DRIFTED` finding as a violation to correct unilaterally — it routes to a reconciliation decision, not a fix.
- Do not overwrite a drifted artifact, even to "restore" it to the manifest's hash. That is the single mistake this check exists to prevent triggering.
- Do not treat a `MISSING` artifact as an absence to silently regenerate — it is a deletion to reconcile.
- Do not claim blueprint or profile staleness was checked when `version_ref` is not a recomputable hash.
- Do not regenerate the whole practice for one changed fact or element — only what traces to the change re-enters.
- Do not skip the script (or the manual equivalent) and guess at drift from memory.

## Ambiguities worth flagging to the operator

- **`REVIEW SOON` is not in the documented state set.** [drift-check.md](${CLAUDE_PLUGIN_ROOT}/adoption/checks/drift-check.md)'s own report format lists `DRIFTED`, `MISSING`, `REVIEW DUE`, `STALE`, `PROFILE STALE`, `OK`, and `DEFERRED`. The script additionally emits `REVIEW SOON` whenever `-WithinDays` is greater than zero and a review falls within that window in the future. Treat it as informational, not as one of the seven triggers that re-enter the loop.
- **The script does not implement capability-changed detection.** [drift-check.md](${CLAUDE_PLUGIN_ROOT}/adoption/checks/drift-check.md)'s trigger table lists "Capability changed" as detected by "Capability re-verification *(script)*," but `Test-PracticeDrift.ps1` contains no logic that reads or re-verifies capability facts. If this trigger matters, it currently has to be checked by hand against the profile's capability inventory — the script's silence on it is a real gap between the documented design and the implemented tool, not an oversight in this skill.
