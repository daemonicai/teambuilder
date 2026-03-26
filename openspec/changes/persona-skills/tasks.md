## 1. Verify Claude Code Skill Resolution

- [x] 1.1 Confirm the exact directory and file format Claude Code uses to resolve `/teambuild:*` commands and skills
- [x] 1.2 Confirm whether install script needs to symlink/copy files into `~/.claude/commands/` or whether the cloned path can be registered in `settings.json`
- [x] 1.3 Document the confirmed mechanism in design.md (resolve the open question)

## 2. Project Skeleton

- [x] 2.1 Create `commands/teambuild/` directory — command files are `commands/teambuild/<name>.md`, creating `/teambuild:<name>`
- [x] 2.2 No separate skills/ directory — commands ARE the skill files
- [x] 2.3 Create a `README.md` with install instructions placeholder

## 3. Install Scripts

- [x] 3.1 Write `install.sh` — clones `release` branch into `~/.claude/teambuilder/`, detects existing install and runs `git pull` instead
- [x] 3.2 Write `install.ps1` — equivalent for Windows/PowerShell
- [x] 3.3 Add any post-clone steps confirmed in task 1.2 (symlinking, settings.json update)
- [x] 3.4 Verify `install.sh` is safe to pipe from curl (exits non-zero on failure, no interactive prompts in normal flow)

## 4. `/teambuild:init` Command and Skill

- [x] 4.1 Write `commands/teambuild/init.md` command definition
- [x] 4.2 Question flow, `_project.md` and `_team.md` output, directory creation, overwrite guard — all in init.md
- [ ] 4.3 Verify output: `_project.md` and `_team.md` written to `.claude/agents/`, prompt to continue with analyst

## 5. Persona File Format

- [x] 5.1 Define the standard YAML frontmatter template (name, description, model, teambuilder block) used by all persona skills
- [x] 5.2 Define the prose body template structure (fixed identity/boundaries section + variable context section + inlined shared context)
- [ ] 5.3 Verify a generated file is accepted by Claude Code as a valid sub-agent

## 6. `/teambuild:analyst` Command and Skill

- [x] 6.1 Write `commands/teambuild/analyst.md` command definition
- [x] 6.2 Full question flow per REQUIREMENTS.md, reads `_project.md` and `_team.md`, generates `analyst.md`, updates `_team.md`
- [x] 6.3 Detect-and-ask regen flow in the analyst skill (detect existing `analyst.md`, offer update/fresh, pre-fill from `teambuilder.answers`)
- [ ] 6.4 Verify `analyst.md` is a valid Claude Code agent and the regen flow works correctly

## 7. Remaining Persona Skills

- [x] 7.1 Write `commands/teambuild/architect.md` — reads analyst output, adaptive questions per REQUIREMENTS.md
- [x] 7.2 Write `commands/teambuild/designer.md` — reads analyst + architect output, adaptive questions per REQUIREMENTS.md
- [x] 7.3 Write `commands/teambuild/programmer.md` — variant argument support, reads architect output, adaptive language/framework questions per REQUIREMENTS.md
- [x] 7.4 Write `commands/teambuild/tester.md` — reads architect + analyst + programmer output, drill-down by test type per REQUIREMENTS.md
- [x] 7.5 Write `commands/teambuild/reviewer.md` — reads all prior artifacts, configurable blocking/warning lists per REQUIREMENTS.md

## 8. Programmer Variants

- [x] 8.1 Implement variant argument handling in `teambuild-programmer.md` — detect argument, set output filename to `programmer-<variant>.md`
- [x] 8.2 Implement base programmer inheritance — read `programmer.md` if present, use its answers as defaults for cross-cutting questions
- [x] 8.3 Implement no-base-programmer warning when variant is requested without base
- [ ] 8.4 Verify `_team.md` is updated with variant label (e.g., "Programmer (iOS)")

## 9. Regen Flow (All Personas)

- [x] 9.1 Regen pattern is consistent — all persona skills follow the same detect/ask/pre-fill pattern as analyst (by design)
- [ ] 9.2 Verify `teambuilder.generated` timestamp is updated on regen (live test)
- [ ] 9.3 Verify update flow pre-fills from `teambuilder.answers` and allows per-answer override (live test)

## 10. End-to-End Validation

- [ ] 10.1 Run full init → analyst → architect → designer → programmer → tester → reviewer flow on a test project
- [ ] 10.2 Verify all generated files are valid Claude Code sub-agents
- [ ] 10.3 Verify `_team.md` is correctly updated after each persona
- [ ] 10.4 Test install script on a clean machine (or clean `~/.claude/` state)
- [ ] 10.5 Update README.md with final install instructions and usage guide
