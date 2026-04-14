## 1. Enforce OpenSpec dependency in `/teambuild:init`

- [x] 1.1 Add an `openspec` binary probe at the start of `/teambuild:init` that exits with an install-instruction message pointing to https://openspec.dev when the binary is not resolvable on `PATH`
- [x] 1.2 Add an `openspec/` workspace bootstrap step that runs `openspec init` in the project root when the directory is missing, and skips the call when it already exists
- [x] 1.3 Make the `CLAUDE.md` OpenSpec routing block unconditional in `/teambuild:init` (remove the "if openspec/ exists" branch)
- [x] 1.4 Update the codebase-discovery step in `/teambuild:init` to treat `openspec/` as an expected directory rather than a conditional one

## 2. Prune OpenSpec conditionals from persona skills and templates

- [x] 2.1 Remove OpenSpec-conditional prose from `/teambuild:analyst`; rewrite its OpenSpec-aware guidance as unconditional
- [x] 2.2 Remove OpenSpec-conditional prose from `/teambuild:architect`; rewrite its OpenSpec-aware guidance as unconditional
- [x] 2.3 Remove OpenSpec-conditional prose from `/teambuild:designer`; rewrite its OpenSpec-aware guidance as unconditional
- [x] 2.4 Remove OpenSpec-conditional prose from `/teambuild:programmer`; rewrite its OpenSpec-aware guidance as unconditional
- [x] 2.5 Remove OpenSpec-conditional prose from `/teambuild:tester`; rewrite its OpenSpec-aware guidance as unconditional
- [x] 2.6 Remove OpenSpec-conditional prose from `/teambuild:reviewer`; rewrite its OpenSpec-aware guidance as unconditional
- [x] 2.7 Remove OpenSpec-conditional prose from the `_project.md` template used by `/teambuild:init`
- [x] 2.8 Remove OpenSpec-conditional prose from the `_team.md` template used by `/teambuild:init`

## 3. Update Reviewer persona fixed core

- [x] 3.1 Add "per-change review at archive time" as a named duty in the Reviewer persona's fixed core in `/teambuild:reviewer`
- [x] 3.2 Specify in the duty description that review scope is the full change directory (proposal, design, specs, tasks) plus the code diff, and that findings are non-blocking

## 4. Build the `teambuilder-apply-dispatch-loop` skill

- [x] 4.1 Create `skills/teambuilder-apply-dispatch-loop/SKILL.md` in the repo root (source of shippable skills) with frontmatter declaring it a Teambuilder-owned skill that the CLAUDE.md routing block invokes from `/opsx:apply`
- [x] 4.2 Implement pending-task enumeration that reads `tasks.md` for the active change and collects every `- [ ]` checklist item in source order
- [x] 4.3 Implement section-based task classification: headings matching `/design|ux|ui/i` → Designer, headings matching `/test/i` → Tester, all other sections and unheadered tasks → Programmer
- [x] 4.4 Implement per-task dispatch via the Agent tool, passing a prompt that contains the task text verbatim and absolute paths to `proposal.md`, `design.md`, and the change's `specs/` directory — without embedding the contents of those files
- [x] 4.5 Add missing-persona detection: when the classified persona's `.claude/agents/<persona>.md` is absent, stop the loop and tell the user which `/teambuild:<persona>` skill to run
- [x] 4.6 Add post-dispatch verification: after each subagent returns, confirm the dispatched task is now `- [x]` in `tasks.md`; if not, halt the loop and surface the subagent's final message
- [x] 4.7 Handle the empty-state case (no pending tasks) with an immediate exit message, and emit a completion summary when the loop finishes

## 5. Build the `teambuilder-review-gate` skill

- [x] 5.1 Create `skills/teambuilder-review-gate/SKILL.md` in the repo root (source of shippable skills) with frontmatter declaring it a Teambuilder-owned skill that the CLAUDE.md routing block invokes from `/opsx:archive` before archival steps run
- [x] 5.2 Construct the Reviewer prompt with paths to the active change's `proposal.md`, `design.md`, `specs/`, `tasks.md`, and a diff of the code changes produced during the change
- [x] 5.3 Invoke the Reviewer persona via the Agent tool using that prompt, and halt the gate if `.claude/agents/reviewer.md` is absent with a message instructing the user to run `/teambuild:reviewer` first
- [x] 5.4 Display Reviewer findings to the user and ask whether to proceed with archival; return a proceed signal to the caller if the user confirms, a halt signal if they decline
- [x] 5.5 Handle empty findings: when the Reviewer returns "No findings.", return a proceed signal to the caller without prompting the user

## 5a. Wire the new skills into the CLAUDE.md routing block

- [x] 5a.1 Expand the `## OpenSpec + Teambuilder` block that `/teambuild:init` writes to route `/opsx:apply` (and `openspec-apply-change`) through `teambuilder-apply-dispatch-loop` after context is loaded
- [x] 5a.2 Expand the same block to route `/opsx:archive` (and `openspec-archive-change`) through `teambuilder-review-gate` before archival steps run
- [x] 5a.3 Keep the inline-invocation note in the routing block so users know the orchestrated path is the default, not the only path
- [x] 5a.4 Do not modify any files owned by OpenSpec (`.claude/skills/openspec-*/SKILL.md`, `.claude/commands/opsx/*.md`); all Teambuilder logic lives in Teambuilder-owned skills referenced from CLAUDE.md

## 6. Documentation

- [x] 6.1 Rewrite the README install section to list OpenSpec as a required prerequisite with a link to https://openspec.dev
- [x] 6.2 Remove the standalone "OpenSpec integration" section from the README and fold its contents into the "How it works" flow, treating OpenSpec as assumed rather than optional
- [x] 6.3 Document the two invocation paths in the README: orchestrated (via opsx commands, the default for non-trivial work) and inline ("use the programmer", for small or off-workflow tasks)
- [x] 6.4 Audit the "What gets generated" section for references to conditional OpenSpec behavior and remove any "if you use OpenSpec" hedging

## 7. Manual testing and verification

- [x] 7.1 Verify `/teambuild:init` exits with the install message when the `openspec` binary is not on `PATH` and does not create any files
- [x] 7.2 Verify `/teambuild:init` runs `openspec init` and then continues its remaining steps when the binary is present but `openspec/` is missing
- [x] 7.3 Verify `/teambuild:init` is idempotent and does not re-run `openspec init` when `openspec/` already exists
- [x] 7.4 Verify `/opsx:apply` invokes `teambuilder-apply-dispatch-loop` and dispatches tasks under Design / UX / UI headings to the Designer, tasks under Test headings to the Tester, and other tasks to the Programmer
- [x] 7.5 Verify `teambuilder-apply-dispatch-loop` halts with a clear message when a required persona file is missing from `.claude/agents/`
- [x] 7.6 Verify `teambuilder-apply-dispatch-loop` halts when a subagent returns without marking its task complete, and surfaces the subagent's final message
- [x] 7.7 Verify `/opsx:archive` invokes `teambuilder-review-gate`, which surfaces findings and proceeds only when the user confirms
- [x] 7.8 Verify `teambuilder-review-gate` proceeds without prompting when the Reviewer returns no findings
- [x] 7.9 Verify inline invocation ("use the programmer") still works outside any opsx command
- [x] 7.10 Verify no files under `.claude/skills/openspec-*/` or `.claude/commands/opsx/` have been modified relative to upstream OpenSpec
