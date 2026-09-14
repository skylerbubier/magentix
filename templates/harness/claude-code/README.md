*[Magentix](../../../README.md) › Templates › [Harness](../README.md) › Claude Code*

# Claude Code Harness Pack

Which real Claude Code file fills each of the five abstract slots from
[`../README.md`](../README.md), and — the part this pack exists to make
explicit — which of those files can actually fail closed and which cannot.
Nothing in this directory is wired into Magentix's own configuration; it is
a template pack to copy into a project or a user's own setup and adapt.

## Slot mapping

| Slot | Real file(s) | Committed? |
|---|---|---|
| Project context (shared, always-loaded) | `./CLAUDE.md` at the project root | Yes |
| Personal, always-loaded (user scope) | `~/.claude/CLAUDE.md` | N/A — lives outside any repo |
| On-demand reference | `.claude/skills/<name>/SKILL.md`, plus any `CLAUDE.md` in a subdirectory (loaded only once a file under it is read) | Yes |
| Automation | `.claude/settings.json` (`hooks` key) or a plugin-provided `hooks.json` | Yes |
| Personal overlay (project scope) | `.claude/settings.local.json` | **No — gitignored** |
| Agent state | No dedicated built-in file. Designate a scratch/state path (e.g. `.claude/state/`) and exclude it from any write-restricting rule, or keep it outside the repo entirely | Project's choice |

Two honest gaps worth naming rather than papering over:

- Claude Code has no dedicated **personal, always-loaded project-scope**
  file distinct from settings. A person's own preference about *how* they
  want to be worked with on this project routes through their user-scope
  `~/.claude/CLAUDE.md` instead (see
  [`../../../profiles/user/03-harness-binding.md`](../../../profiles/user/03-harness-binding.md)),
  not through anything committed to this repository. Do not invent a
  project-local personal context file to work around this — an absent slot
  is a correct answer, per
  [`../../../profiles/project/04-harness-binding.md`](../../../profiles/project/04-harness-binding.md).
- There is no built-in agent-state file either. `04-working-log.md`-style
  continuity notes (see
  [`../../../blueprints/agent-context-kit/README.md`](../../../blueprints/agent-context-kit/README.md))
  need a path a project's own settings never deny — see
  [`CLAUDE.md`](CLAUDE.md) in this pack for where that's marked.

## What can fail closed, and what cannot

**`permissions.deny` in settings (any scope) fails closed only for the exact
tool-call shape it matches.** A `Read` deny on a path blocks that path
through the `Read` tool; it does nothing to a `Bash` call that reads the
same path with `cat`, unless `Bash` is separately restricted. This is the
same warning
[`../../../profiles/project/04-harness-binding.md`](../../../profiles/project/04-harness-binding.md)
makes about tool-level automation generally: a write through a shell
redirect is not a mediated tool call, and a path-based rule never sees it.

**Hooks fail closed only for the specific invocation they actually run
against**, and only according to their exit code — see the contract below.
A hook is a process the harness spawns and trusts to answer honestly; it can
be bypassed by anything that skips the matcher (a tool the matcher doesn't
name, a differently-shaped call to the same effect) or by disabling the hook
in a settings file with enough precedence to do so.

**`CLAUDE.md`, skills, and any other markdown context never fail closed.**
They are the preference layer — an agent reads them and follows them because
it was asked to, exactly as
[`../../../blueprints/agent-context-kit/README.md`](../../../blueprints/agent-context-kit/README.md)
describes. Nothing in this row is checked by anything.

**Managed settings, deployed outside any repository by an organization, are
the strongest layer here** — nothing a project or a person commits can
override them. If a project profile's capability inventory
([`../../../profiles/project/03-capability-inventory.md`](../../../profiles/project/03-capability-inventory.md))
needs something to actually hold, prefer a pipeline or platform control over
anything in this pack; this pack is fast local feedback, not a substitute for
that inventory.

## Settings precedence

Highest precedence first:

1. Managed settings (deployed by an organization, outside any repository)
2. Command-line `--settings`
3. Project local `.claude/settings.local.json` (personal, not committed)
4. Shared project `.claude/settings.json` (committed, team-wide)
5. User `~/.claude/settings.json`

List-valued keys — `permissions.allow`, `permissions.ask`,
`permissions.deny`, `permissions.additionalDirectories` among them — **merge
across files** rather than the higher-precedence file overriding the lower
one wholesale. A deny added at any level stays in effect; it is not silently
dropped by a lower-precedence file that doesn't mention it.

`permissions.defaultMode` values `acceptEdits` and `plan` may be set from a
project file. **`auto` and `bypassPermissions` only take effect when set
from user or managed settings — never from a project file.** A committed
`.claude/settings.json` that sets either of those has no effect from that
location.

## Hooks: the exit-code contract

See [`hooks.json`](hooks.json) for the shape. A hook is a command Claude
Code runs and reads the result of:

- **Exit 0** — no objection. Anything the hook printed to stdout is shown to
  the user but does not change what happens.
- **Exit 2** — blocks the action and feeds stderr back to the model as
  feedback, for `PreToolUse` (blocks the tool call before it runs) and other
  blocking events.
- **Structured JSON on stdout with exit 0** — lets a `PreToolUse` hook
  return a `permissionDecision` explicitly (e.g. `allow`, `deny`, `ask`)
  instead of relying on the exit code alone.

Matchers on `PreToolUse` / `PostToolUse` match **tool names**: `Bash`,
`Edit|Write`, `mcp__.*`, and so on — not file paths. A hook that needs to
restrict *which paths* a tool acts on has to parse that out of the tool call
itself; the matcher alone only ever selects by tool.

## Files in this pack

- [`settings.json`](settings.json) — a project-scope settings skeleton
  showing `permissions`, `env`, and `outputStyle`, with obviously-placeholder
  values.
- [`hooks.json`](hooks.json) — an **example** hooks file. It is not wired
  into this plugin or any project; it exists to show the real shape of a
  hooks group and the deny / observe pattern above.
- [`example-hooks/`](example-hooks/) — the two scripts `hooks.json` names:
  [`deny-secrets-read.sh`](example-hooks/deny-secrets-read.sh) (the deny
  half — exit 2 on a shell command that names a well-known secret file) and
  [`log-file-change.sh`](example-hooks/log-file-change.sh) (the observe
  half — appends to `.claude/state/file-changes.log`, never blocks). Both
  are POSIX `sh`, use `jq` when present and fall back to `grep` when not,
  and are illustrative of the exit-code contract, not security controls:
  each fails closed only for the exact command shape it matches.
- [`CLAUDE.md`](CLAUDE.md) — a skeleton project-context file: the Agent
  Context Kit's four documents collapsed into Claude Code's one shared,
  always-loaded project slot, with pointers out to on-demand detail.
