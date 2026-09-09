*[Magentix](../../README.md) › [Adoption engine](../README.md)*

# Materialization Check

Runs after writing. Three questions, in order, none optional.

---

## 1 · Did it land?

| # | Assertion |
|---|---|
| L1 | Every declared path exists |
| L2 | Every path's content matches its spec entry |
| L3 | Nothing outside the declared set was modified |
| L4 | Every overwritten file's prior state was preserved before the write, and the location is recorded |

L3 is worth checking rather than assuming. A write that routed around the declared set — through a shell redirect, an editor, a tool that touches an adjacent file — will not announce itself.

## 2 · Does it load?

| # | Assertion |
|---|---|
| D1 | Every asserted entry sits in a location the harness actually reads |
| D2 | Anything with a required format parses |
| D3 | Anything referenced by another artifact resolves |

**D1 is the silent one.** A context document in a directory nothing scans is stored, not adopted, and it produces no error at any point. Verify against the locations recorded in the situation survey, not against where the blueprint suggested putting it.

## 3 · Does it hold?

| # | Assertion |
|---|---|
| E1 | **Every enforced entry has been tested by violating it, and produced a denial** |
| E2 | The denial names the rule, so a future reader knows what stopped them |
| E3 | Any entry whose violation test did not deny is demoted to asserted, in the manifest and the adoption record |

This is the most-skipped step in the loop and the one that decides whether invariant 3 held in reality or only on paper.

**A check that has never failed is not known to be a check.** Attempt the exact thing the mechanism exists to prevent, confirm the denial, and record what you attempted. An entry that cannot be tested by violation is, for the purposes of this practice, asserted — regardless of what the blueprint called it.

---

## Evidence

Record the actual output, not a claim about it:

```
ENTRY-NN  <path>
  landed:  yes — <how confirmed>
  loads:   yes — <how confirmed>
  holds:   yes — attempted <the violation>, denied by <mechanism>
                 <the denial output>
```

Terseness applies to commentary about the work, never to the record of its result. However brief the agent has been asked to be, the output substantiating an "in place and holding" claim stays in full.

---

## On failure

| Failure | Response |
|---|---|
| L1 / L2 | Re-run materialization for that entry. If the content cannot be written as specified, that is a spec defect — return to drafting, not an improvisation |
| L3 | Revert the undeclared write. Investigate how it happened before continuing |
| L4 | Stop. Recover the prior state if possible, and record the loss if not |
| D1 | The entry's path is wrong. Return to drafting — do not guess a new location at write time |
| E1 / E3 | Demote, record, and add the missing capability to the backlog in the adoption record |
