## Why

Teambuilder currently treats OpenSpec as an optional integration, forcing persona templates, skills, and generated artifacts to carry `if openspec/ exists…` conditionals and hedged prompts. At the same time, Teambuilder generates a team of personas but says nothing about how the top-level Claude Code session should dispatch work to them — users end up invoking personas ad-hoc with no orchestration discipline.

Making OpenSpec a required dependency lets us prune the conditional branches, use `tasks.md` as a canonical task source, and build a first-party subagent dispatch loop inside `/opsx:apply` without adding a second external dependency.

## What Changes

- **BREAKING**: OpenSpec becomes a required dependency of Teambuilder. `/teambuild:init` runs `openspec init` if `openspec/` is missing; if the `openspec` binary is not installed, it stops and instructs the user to install from https://openspec.dev.
- `/opsx:apply` becomes a subagent-driven dispatch loop: read pending tasks from `tasks.md`, classify each, dispatch to the appropriate implementer persona (Designer / Programmer / Tester) in a **fresh subagent** with only that task's text and pointers to relevant spec/design files. The dispatched persona self-verifies and marks the task complete.
- The Reviewer persona gains a named duty: **per-change review at archive time**. A new gate before `/opsx:archive` finalizes runs the Reviewer across the whole change (proposal, design, specs, tasks, code diff). Findings are surfaced to the user but **non-blocking** — the user decides whether to address before archiving.
- Inline persona invocation ("use the programmer") is preserved for ad-hoc work outside the orchestrated path.
- All OpenSpec conditionals are pruned from persona templates, teambuild skills, and generated `_project.md` / `_team.md`. Personas are written assuming the workflow.
- README is rewritten: OpenSpec moves from an integration section to a required prerequisite; the "how it works" flow becomes init → build personas → use via opsx commands (orchestrated) or inline invocation (ad-hoc).

## Capabilities

### New Capabilities

- `openspec-dependency`: Teambuilder requires OpenSpec to be installed; `/teambuild:init` validates and bootstraps the OpenSpec workspace, failing loudly with install instructions when the binary is missing.
- `persona-orchestration`: `/opsx:apply` dispatches tasks from `tasks.md` to implementer personas in fresh per-task subagents; implementers self-verify and mark tasks complete; inline persona invocation is preserved as an off-workflow path.
- `change-review`: The Reviewer persona performs a single per-change review at archive time over the full change artifacts and diff; findings are reported to the user but do not block archival.

### Modified Capabilities

<!-- None; no existing specs in openspec/specs/. -->

## Impact

- **Skills**: `/teambuild:init` (bootstrap OpenSpec), `/opsx:apply` (replaced with dispatch loop), `/opsx:archive` (or end of `/opsx:apply` — see design) gains Reviewer gate. All `/teambuild:*` persona skills lose OpenSpec conditional branches.
- **Persona templates**: Analyst, Architect, Designer, Programmer, Tester prompts lose OpenSpec conditionals. Reviewer fixed core gains the per-change review duty.
- **Generated artifacts**: `_project.md` and `_team.md` templates lose OpenSpec conditionals.
- **Dependencies**: OpenSpec is now a required install prerequisite, not optional. Users without OpenSpec cannot use Teambuilder until they install it.
- **Documentation**: README restructured — OpenSpec is a prerequisite in install/setup, and the orchestrated vs. inline invocation paths are documented explicitly.
- **No runtime code**: Teambuilder is a collection of Claude Code skills; there is no compiled code to change. All changes are to skill definitions, persona templates, and markdown.
