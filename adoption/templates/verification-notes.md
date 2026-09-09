*[Magentix](../../README.md) › [Adoption engine](../README.md)*

# Verification Notes — {practice-id}

What the environment showed, checked against what the profile claimed. **Read-only stage** — nothing here writes to a target path.

Filled in **before** any question is asked. Every row is a question the adopter does not have to answer.

## Profile facts checked

| Fact id | Claim | How checked | Environment showed | Outcome |
|---|---|---|---|---|
| | | | | `confirmed` / `superseded` / `could not check` |

`could not check` is the only row that becomes a question. The other two resolve without anyone's attention, which is the point of verifying before asking.

## What exists at the target locations

One row per location a blueprint element would occupy.

| Location | Element it relates to | State | Notes |
|---|---|---|---|
| | | `present` / `stale` / `unfilled` / `absent` / `undeterminable` | |

`unfilled` means a template is there with its placeholders intact — a prior adoption that did not stick. **Lead the conversation with these**; something made it not stick, and the blueprint is about to propose it again.

## What this environment can actually enforce

Determines which elements the blueprint marks `enforced` survive as enforced here. Read pessimistically.

| Mechanism | Layer | Fails closed | Bypass | Verified by violating it |
|---|---|---|---|---|
| | `local` / `pipeline` / `platform` / `process` | `yes` / `no` | `how` / `none` | `yes` / `no` |

Elements that cannot be enforced here: `<list — each becomes a demotion, a profile capability fact, and a gap entry>`

A mechanism confirmed by reading configuration is confirmed to **exist**. One confirmed by attempting the violation and being denied is confirmed to **work**. Only the second earns `fails closed`.

## Already stated elsewhere

The one-home-per-fact input. Anything here must be **pointed at**, never restated.

| Source | What it already covers |
|---|---|

## Path ownership

| Path | Claimed by | Status |
|---|---|---|
| | `<practice-id>` | `available` / `claimed` / **`collision`** |

A collision is a decision to surface, not an absence to fill. Two practices writing one file overwrite each other, and the destruction is silent in both directions.

## Harness

- Slots recorded in the profile, and whether each is `personal` or `shared`: `<list>`
- Locations the tooling actually reads: `<list — an element placed outside these is stored, not adopted>`
- Agent state path, writable at all times: `<path>`

## Could not determine

Each of these becomes a question. Do not let one become a silent assumption.

- `<what, and why it could not be observed>`
