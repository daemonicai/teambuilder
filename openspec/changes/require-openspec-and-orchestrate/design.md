## Context

Teambuilder is a collection of Claude Code skills that generate opinionated agent personas (Analyst, Architect, Designer, Programmer, Tester, Reviewer) into `.claude/agents/`. It currently treats OpenSpec as an optional add-on — skills and persona templates carry `if openspec/ exists…` branches, and users who do adopt OpenSpec get a `CLAUDE.md` routing block mapping `/opsx:*` commands to personas.

This change drops the optional framing. OpenSpec becomes a required prerequisite, and `/opsx:apply` — currently a simple task implementation skill — is replaced with a subagent-driven dispatch loop modelled on the ideas in Superpowers' `subagent-driven-development` skill, but implemented in-house so Teambuilder does not gain a second external dependency.

## Goals / Non-Goals

**Goals:**
- Require OpenSpec as a prerequisite; bootstrap the workspace in `/teambuild:init` when missing; fail loudly with an install link when the `openspec` binary is absent.
- Replace `/opsx:apply` with a controller loop that dispatches each pending task in `tasks.md` to the appropriate implementer persona in a **fresh subagent**, with only the task text and pointers to relevant spec/design files.
- Add a per-change Reviewer gate that runs at archive time over the full change (proposal, design, specs, tasks, diff) and surfaces non-blocking findings.
- Preserve inline persona invocation ("use the programmer") as a documented off-workflow path.
- Prune all OpenSpec conditionals from persona templates, teambuild skills, and generated team-level files.
- Rewrite the README so OpenSpec is a prerequisite, not an integration chapter.

**Non-Goals:**
- Introducing two-stage review (spec compliance + quality). Teambuilder's Reviewer owns a single holistic gate; splitting it adds coordination cost without a matching win given OpenSpec specs are already structured artifacts the Reviewer can read directly.
- Per-task or per-phase Reviewer invocation. Considered and rejected as noisy and expensive relative to a single change-boundary review. Revisitable if drift becomes a pattern.
- Model tiering per subagent (cheap model for mechanical tasks, expensive for architecture). Out of scope; the orchestrator does not pick models.
- Blocking archival on Reviewer findings. User remains in the driver's seat — findings are surfaced, not enforced.
- Automating fix loops. If the Reviewer flags issues, the user decides what to do. Fix cycles are user-driven, not controller-driven.
- Building orchestration for non-OpenSpec workflows. Inline invocation stays a hand-driven path; there is no plan to generalize the dispatcher to ad-hoc tasks.

## Decisions

### Decision 1: OpenSpec becomes a required install prerequisite

`/teambuild:init` probes for `openspec` on `PATH`. If the binary is missing, init exits with a message pointing the user to https://openspec.dev and does not proceed. If the binary is present but `openspec/` is absent, init runs `openspec init` in the project root before continuing with its existing steps (project context, team file, CLAUDE.md routing).

**Alternatives considered:**
- *Keep OpenSpec optional.* Rejected — the conditional branches in persona templates and skills are the largest source of hedged, less-sharp prompts; we want to delete them.
- *Vendor a minimal subset of OpenSpec into Teambuilder.* Rejected — duplicates effort, creates drift with the upstream tool the user already has.
- *Warn but continue without OpenSpec.* Rejected — half-required isn't required; we'd still need the conditional branches.

### Decision 2: `/opsx:apply` is a subagent-driven dispatch loop

The rewritten skill follows this shape:

1. **Load change.** Read `tasks.md`, `proposal.md`, `design.md`, and the list of files under `specs/` for the active change.
2. **Enumerate pending tasks.** A pending task is an unchecked checklist item (`- [ ]`) in `tasks.md`. Completed tasks (`- [x]`) are skipped.
3. **Classify each task.** Classification uses the `tasks.md` section the task lives under (see Decision 3).
4. **Dispatch in a fresh subagent.** For each pending task, in order: invoke the matching persona (Designer / Programmer / Tester) via the Agent tool, passing a prompt containing (a) the task text verbatim, (b) paths to `proposal.md`, `design.md`, and relevant spec files as pointers, and (c) the explicit instruction to self-verify and mark the task complete when done. No session history is inherited.
5. **Check persona output.** On return, verify the task is marked complete in `tasks.md`. If not, surface the subagent's final message to the user and stop the loop — do not advance to the next task.
6. **Loop.** Repeat until no pending tasks remain, then exit with a summary.

There is deliberately **no** Reviewer step in this loop. The Reviewer gate lives at archive time (Decision 4).

**Alternatives considered:**
- *Full Superpowers-style controller with status protocol (DONE / DONE_WITH_CONCERNS / NEEDS_CONTEXT / BLOCKED) and automated fix loops.* Rejected for now — adds meaningful surface area and requires disciplined subagent output formatting. The simpler loop above captures the core value (fresh context per task) without the coordination machinery. Can be added later if the simple loop proves insufficient.
- *Dispatch all tasks in parallel.* Rejected — OpenSpec tasks often have implicit ordering (e.g., create the type before using it), and parallel dispatch risks write conflicts on `tasks.md`.

### Decision 3: Task classification is section-based

`tasks.md` is structured by section. The convention we adopt: the section heading a task lives under determines the persona. Heuristic defaults:

- Section headings matching `/design|ux|ui/i` → Designer
- Section headings matching `/test/i` → Tester
- Everything else (including unheadered tasks, `Implementation`, `Code`, etc.) → Programmer

If `tasks.md` has no section structure, every task goes to Programmer. If a task's classification is ambiguous, the controller prompts the user interactively before dispatching.

**Alternatives considered:**
- *Keyword-based classification on task text.* Rejected as fragile — "write a test for X" matches but "add a field" doesn't give a signal. Section headings are reliably authored.
- *Explicit persona tags in tasks.md* (e.g., `- [ ] (designer) do X`). Rejected — requires us to dictate `tasks.md` format, which OpenSpec controls upstream. We match OpenSpec's existing structure instead.
- *Ask the user per task.* Rejected — too interactive for a loop that may have many tasks.

### Decision 4: Reviewer runs at archive time, inside `/opsx:archive`

The Reviewer gate lives inside `/opsx:archive` (not at the end of `/opsx:apply`). Before archival proceeds, the skill invokes the Reviewer persona in a subagent with access to the whole change directory and a diff of the code changes the apply loop produced. The Reviewer returns findings; the skill surfaces them to the user and asks whether to proceed with archival or not. Findings are non-blocking.

**Why inside archive rather than at the end of apply:**
- `/opsx:apply` may be run multiple times as work progresses; triggering review at every partial run is noise.
- `/opsx:archive` is the canonical "I'm done" gate — it already represents user intent to seal the change.
- Archive-time review catches changes regardless of how tasks were completed (orchestrated apply, inline invocation, or manual edits).
- Matches the mental model: "before I seal this change, is it any good?"

**Alternatives considered:**
- *At the end of `/opsx:apply` when all tasks hit done.* Rejected per above — applies run incrementally, and decoupling review from archive leaves a gap if tasks are completed outside apply.
- *Inside the Reviewer persona as a standalone skill invocation.* Rejected — the gate should fire automatically at archive to be load-bearing; a standalone skill people forget to run isn't a gate.

### Decision 5: Inline persona invocation stays, documented as the off-workflow path

Users can still say "use the programmer on this bug" for ad-hoc work. No enforcement prevents it. Documentation in the README explicitly presents two paths:
- **Orchestrated** (default for non-trivial work): explore → propose → apply → archive, with personas dispatched automatically.
- **Inline** (for small or off-workflow tasks): invoke personas directly by name.

**Alternatives considered:**
- *Remove inline invocation to force the orchestrated path.* Rejected — adds friction for small tasks and contradicts the user's stated preference.

### Decision 6: Reviewer fixed core gains a named duty

The Reviewer persona's fixed core (defined in `/teambuild:reviewer`) gains an explicit duty: "per-change review at archive time, across the full change directory and code diff." This makes the role concrete in the generated persona file rather than relying only on skill-level prompts.

### Decision 7: Prune OpenSpec conditionals

Every `if openspec/ exists…` branch in persona templates, teambuild skills, and the generated `_project.md` / `_team.md` templates is removed. Personas are written assuming the OpenSpec workflow exists.

## Risks / Trade-offs

- **Users without OpenSpec are now blocked.** → Mitigation: `/teambuild:init` gives a clear install link; README puts OpenSpec in the prerequisites section, not buried. Existing users who already have OpenSpec see no disruption.
- **Subagent context window pressure on large changes.** Fresh-per-task dispatch still passes proposal/design/spec file paths; if spec files grow large, subagents may spend budget on reading them. → Mitigation: pass only the spec files relevant to the task's capability (the spec directory under `specs/`), not every spec in the repo.
- **Section-based classification breaks if users change `tasks.md` structure.** → Mitigation: the controller falls back to prompting the user when classification is ambiguous; defaulting unknown sections to Programmer handles the common case.
- **Reviewer findings are non-blocking, so a user can archive broken work.** → Accepted trade-off: Teambuilder's stance is to give users opinionated tools, not automate around them. A blocking gate would turn the Reviewer into a bottleneck and undermine user agency.
- **Drift from OpenSpec upstream if it changes `tasks.md` format.** → Mitigation: classification is the only piece that reads structure; keep it isolated in the `/opsx:apply` skill so upstream changes only affect one file.
- **The dispatch loop is sequential and may be slow for long task lists.** → Accepted: OpenSpec task ordering often matters, and sequential dispatch is simpler to reason about. Parallelism is out of scope for this change.

## Migration Plan

- **Existing users with OpenSpec installed and initialized**: No action required. Re-running `/teambuild:init` is idempotent; it will detect OpenSpec and proceed as before. Re-running persona skills updates the persona files (they already pre-fill prior answers).
- **Existing users without OpenSpec**: Re-running `/teambuild:init` will refuse with an install message. Users install OpenSpec, then re-run `/teambuild:init` which bootstraps the workspace before continuing.
- **New users**: Install OpenSpec (linked from README prerequisites), then install Teambuilder, then `/teambuild:init`.

Rollback is trivial: the change does not touch runtime code. If the dispatch loop misbehaves, reverting the commit restores the prior `/opsx:apply` behavior.

## Open Questions

None remaining. The original open question (Reviewer gate location — apply vs. archive) is resolved in Decision 4.
