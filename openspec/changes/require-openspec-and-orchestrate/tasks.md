## 1. Enforce OpenSpec dependency in `/teambuild:init`

- [ ] 1.1 Add an `openspec` binary probe at the start of `/teambuild:init` that exits with an install-instruction message pointing to https://openspec.dev when the binary is not resolvable on `PATH`
- [ ] 1.2 Add an `openspec/` workspace bootstrap step that runs `openspec init` in the project root when the directory is missing, and skips the call when it already exists
- [ ] 1.3 Make the `CLAUDE.md` OpenSpec routing block unconditional in `/teambuild:init` (remove the "if openspec/ exists" branch)
- [ ] 1.4 Update the codebase-discovery step in `/teambuild:init` to treat `openspec/` as an expected directory rather than a conditional one

## 2. Prune OpenSpec conditionals from persona skills and templates

- [ ] 2.1 Remove OpenSpec-conditional prose from `/teambuild:analyst`; rewrite its OpenSpec-aware guidance as unconditional
- [ ] 2.2 Remove OpenSpec-conditional prose from `/teambuild:architect`; rewrite its OpenSpec-aware guidance as unconditional
- [ ] 2.3 Remove OpenSpec-conditional prose from `/teambuild:designer`; rewrite its OpenSpec-aware guidance as unconditional
- [ ] 2.4 Remove OpenSpec-conditional prose from `/teambuild:programmer`; rewrite its OpenSpec-aware guidance as unconditional
- [ ] 2.5 Remove OpenSpec-conditional prose from `/teambuild:tester`; rewrite its OpenSpec-aware guidance as unconditional
- [ ] 2.6 Remove OpenSpec-conditional prose from `/teambuild:reviewer`; rewrite its OpenSpec-aware guidance as unconditional
- [ ] 2.7 Remove OpenSpec-conditional prose from the `_project.md` template used by `/teambuild:init`
- [ ] 2.8 Remove OpenSpec-conditional prose from the `_team.md` template used by `/teambuild:init`

## 3. Update Reviewer persona fixed core

- [ ] 3.1 Add "per-change review at archive time" as a named duty in the Reviewer persona's fixed core in `/teambuild:reviewer`
- [ ] 3.2 Specify in the duty description that review scope is the full change directory (proposal, design, specs, tasks) plus the code diff, and that findings are non-blocking

## 4. Rewrite `/opsx:apply` as a subagent-driven dispatch loop

- [ ] 4.1 Implement pending-task enumeration that reads `tasks.md` for the active change and collects every `- [ ]` checklist item in source order
- [ ] 4.2 Implement section-based task classification: headings matching `/design|ux|ui/i` → Designer, headings matching `/test/i` → Tester, all other sections and unheadered tasks → Programmer
- [ ] 4.3 Implement per-task dispatch via the Agent tool, passing a prompt that contains the task text verbatim and absolute paths to `proposal.md`, `design.md`, and the change's `specs/` directory — without embedding the contents of those files
- [ ] 4.4 Add missing-persona detection: when the classified persona's `.claude/agents/<persona>.md` is absent, stop the loop and tell the user which `/teambuild:<persona>` skill to run
- [ ] 4.5 Add post-dispatch verification: after each subagent returns, confirm the dispatched task is now `- [x]` in `tasks.md`; if not, halt the loop and surface the subagent's final message
- [ ] 4.6 Handle the empty-state case (no pending tasks) with an immediate exit message, and emit a completion summary when the loop finishes

## 5. Add Reviewer gate to `/opsx:archive`

- [ ] 5.1 Invoke the Reviewer persona via the Agent tool at the start of `/opsx:archive`, before any archival steps run
- [ ] 5.2 Construct the Reviewer prompt with paths to the active change's `proposal.md`, `design.md`, `specs/`, `tasks.md`, and a diff of the code changes produced during the change
- [ ] 5.3 Handle the missing-Reviewer case: if `.claude/agents/reviewer.md` is absent, stop archival with a message instructing the user to run `/teambuild:reviewer` first
- [ ] 5.4 Display Reviewer findings to the user and ask whether to proceed with archival; proceed if the user confirms, pause if they decline
- [ ] 5.5 Handle empty findings: when the Reviewer returns no findings, proceed with archival without prompting the user

## 6. Documentation

- [ ] 6.1 Rewrite the README install section to list OpenSpec as a required prerequisite with a link to https://openspec.dev
- [ ] 6.2 Remove the standalone "OpenSpec integration" section from the README and fold its contents into the "How it works" flow, treating OpenSpec as assumed rather than optional
- [ ] 6.3 Document the two invocation paths in the README: orchestrated (via opsx commands, the default for non-trivial work) and inline ("use the programmer", for small or off-workflow tasks)
- [ ] 6.4 Audit the "What gets generated" section for references to conditional OpenSpec behavior and remove any "if you use OpenSpec" hedging

## 7. Manual testing and verification

- [ ] 7.1 Verify `/teambuild:init` exits with the install message when the `openspec` binary is not on `PATH` and does not create any files
- [ ] 7.2 Verify `/teambuild:init` runs `openspec init` and then continues its remaining steps when the binary is present but `openspec/` is missing
- [ ] 7.3 Verify `/teambuild:init` is idempotent and does not re-run `openspec init` when `openspec/` already exists
- [ ] 7.4 Verify `/opsx:apply` dispatches tasks under Design / UX / UI headings to the Designer, tasks under Test headings to the Tester, and other tasks to the Programmer
- [ ] 7.5 Verify `/opsx:apply` halts with a clear message when a required persona file is missing from `.claude/agents/`
- [ ] 7.6 Verify `/opsx:apply` halts when a subagent returns without marking its task complete, and surfaces the subagent's final message
- [ ] 7.7 Verify `/opsx:archive` invokes the Reviewer, surfaces findings, and proceeds only when the user confirms
- [ ] 7.8 Verify `/opsx:archive` proceeds without prompting when the Reviewer returns no findings
- [ ] 7.9 Verify inline invocation ("use the programmer") still works outside any opsx command
