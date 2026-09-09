*[Magentix](../README.md) › [Adoption engine](README.md)*

# The Blueprint Contract

How the loop consumes a best-practice proposal it has never seen, written by someone who has never heard of this loop.

---

## The contract is one-sided

A blueprint is required to do nothing. It does not declare a manifest, adopt a schema, carry front-matter, or follow a naming convention. It is a set of documents that proposes how some kind of work should be done, and it is read as-is.

That is deliberate, and it is what invariant 1 buys. Any requirement placed on a blueprint would exclude every blueprint written before this loop existed — which is all of them — and would make adoption of a third-party practice conditional on modifying somebody else's work.

So the whole contract lives on this side: the loop derives a structured **reading** and stores it in its own workspace. The blueprint is untouched.

## What stays generic, and what does not

This distinction is the entire design, and it is easy to get backwards.

**The shape of the reading is fixed and blueprint-agnostic.** Every blueprint reduces to elements, invariants, an out-of-scope list, an order, and a set of open slots. That is what lets one set of instructions handle an interaction-preference practice and a spec-driven delivery pipeline without special-casing either.

**The content of the reading is entirely the blueprint's own detail, in the blueprint's own terms.** The loop is not summarizing or abstracting the blueprint. It is indexing it. When a blueprint says a file should carry a specific frontmatter block, that block goes in the reading verbatim. When it names a threshold, the number goes in. When it argues for why an element exists, the argument is available to elicitation, because that reasoning is what tells the adopter whether the element is worth having.

The failure to avoid is a reading so abstracted that the generated practice could have come from any blueprint. If the practice does not carry the blueprint's specific detail into real files, the loop has produced a generic scaffold with a citation, which is worse than nothing.

---

## The reading

```yaml
blueprint:
  source: <path or URL>              # read-only, never written
  read_at: <YYYY-MM-DD>
  version_ref: <commit, date, or hash of what was read>
  self_described_as: <one line, in the blueprint's own words>
  audience: <individual | team | org | derived-per-element>

invariants:                          # the blueprint's own load-bearing rules
  - id: INV-1
    rule: <verbatim or close paraphrase>
    source_ref: <file#section>

out_of_scope:                        # the blueprint's own anti-pattern list
  - <what it explicitly says does not belong>

elements:
  - id: <stable slug, derived>
    what: <the artifact, check, step, role, or cadence the blueprint proposes>
    detail: <the blueprint's actual specification of it — structure, required
             fields, thresholds, format, whatever it states. Not a summary>
    rationale: <why the blueprint says this exists — needed at elicitation>
    authored_by: user | team | agent | script
    cadence: <how often the blueprint expects it to change>
    nature: asserted | enforced
    enforcement_mechanism: <named mechanism, or null>
    location_hint: <where the blueprint suggests it lives, if it says>
    slots:                           # what the blueprint leaves to the adopter
      - id: <slug>
        asks: <what the adopter must supply>
        blocking: true | false
    depends_on: [<element ids>]
    minimum_viable: true | false     # part of the blueprint's own MVP subset
    source_ref: <file#section>

adoption_order: [<element ids>]      # the blueprint's own sequencing, if stated

open:                                # what the blueprint does not decide
  - <question the adopter or the situation must answer>
```

### Field notes that matter

**`nature` is read from the blueprint, then re-tested in B1.** A blueprint saying an element is enforced is a claim about the blueprint's intended environment. Whether *this* environment can enforce it is a separate question, answered by the situation survey. The gap between the two is a demotion, and it gets recorded.

**`slots` are the only legitimate elicitation targets.** If the loop is asking the adopter something that is not a slot and not an unresolved `open` item, it is either asking for something it could have read or inventing scope.

**`rationale` is not decoration.** When an adopter pushes back on an element, the useful response is the blueprint's own argument for it, not a restatement of the element. Half of elicitation is the adopter deciding whether a rationale applies to them.

**`minimum_viable` and `adoption_order` prevent the most common overreach.** A blueprint that names a starting subset has told you not to instantiate all of it at once. Ignoring that produces a large, correct, unused practice.

---

## Deriving a reading

1. **Read the whole blueprint.** Cost is bounded and one-time, and the derived reading is what everything else loads instead.
2. **Find the elements.** Anything the blueprint says should *exist* or should *happen*. Tables, file inventories, and stage lists are usually a direct enumeration. Prose sections usually contain one element and several rules about it.
3. **Separate rules from elements.** "Each file opens with frontmatter" is detail on an element. "One home per fact" is an invariant that applies across all of them. Invariants become spec-validation assertions; element detail becomes generated content.
4. **Harvest the negative space.** The out-of-scope list, the known-limits section, the "what this is not" section. These are the strongest constraints in most blueprints and the most frequently ignored.
5. **Mark the slots.** Anywhere the blueprint says "your", "the adopter's", "fill this in", or leaves a template blank, that is a slot. Anywhere it presents options without choosing, that is a slot.
6. **Note the dependencies and the order.** Some elements are meaningless without another one existing first. The blueprint often says so; where it does not, derive it and mark the derivation as yours.

## Blueprints that resist

| Situation | Handling |
|---|---|
| **Thin blueprint** — a page of principles, no artifacts | Elements are the principles themselves, all `asserted`, most of the detail becomes slots. The practice will be small; that is the correct output, not a failure |
| **Contradictory blueprint** | Record both readings as one element with a `Conflict` disposition waiting in B3. Do not pick one silently |
| **Blueprint that is mostly narrative** | Elements are what survives the question "what would exist, on disk or in a process, if this were adopted?" If nothing would, there is nothing to adopt and the loop should say so plainly |
| **Blueprint that assumes a different stack** | Elements keep their intent; `location_hint` and `enforcement_mechanism` become slots resolved against this environment in B1/B2 |
| **Blueprint that overlaps another already adopted** | Reconciliation handles it in B3 — but check the existing manifests first, because a path owned by another practice is a conflict, not an absence |

---

## Worked illustration

The two proposals that prompted this design read cleanly, and reading them side by side shows why the shape holds. **This section is illustration, not configuration.** Nothing in the kit references either blueprint, and neither was modified to be readable.

| Reading field | An interaction-preference blueprint | A spec-driven delivery blueprint |
|---|---|---|
| `audience` | individual | team, with per-element authorship |
| `elements` | Four context documents, split by volatility and authorship | Roughly twenty subsystems, a spec artifact tree, a hook set, a script set |
| `nature` | Almost entirely `asserted` — the blueprint states this outright | Mixed, and the split is the blueprint's central argument |
| `enforcement_mechanism` | `null` throughout, by design | Named per element: hooks, CI checks, schema validators, branch protection |
| `slots` | Dense — nearly every section of every file is a slot | Sparse in the contracts, dense in the thresholds and the environment bindings |
| `minimum_viable` | Not stated as a subset; all four files are the minimum | Stated explicitly, both as a six-artifact spec minimum and a four-step build order |
| `adoption_order` | Not stated; derivable from authorship | Stated explicitly, and the blueprint warns against building in diagram order |
| `out_of_scope` | Stated per file, and strongly | Stated as known limits and as explicit non-goals |
| Resulting practice | A handful of filled documents at harness-specific paths | A spec tree, hook configuration, CI checks, and scripts, staged over several sittings |

Two things to notice.

**The same shape produced two very different practices**, because the content came from the blueprints. One run outputs four short documents into personal configuration. The other outputs a directory tree, executable checks, and a phased rollout. Neither required the loop to know which it was reading.

**The `nature` column is where the loop earns its keep.** A blueprint that is honest about being unenforceable produces a practice that makes no false claims. A blueprint whose enforcement depends on hooks and CI produces a practice where every one of those is installed and then tested by violating it — or demoted, on the record, when this environment cannot run it.

---

## The one thing a blueprint can add

Nothing is required. But a blueprint author who wants to make adoption sharper can do exactly one thing that helps more than any schema: **state the minimum viable subset and the adoption order explicitly.**

Almost every blueprint's real failure in the field is being adopted whole, at once, by someone who then abandons it. A blueprint that names its own starting point converts that from a judgment call into a lookup.
