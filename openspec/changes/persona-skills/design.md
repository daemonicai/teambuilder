## Context

Teambuilder is a Claude Code skill system that guides users through creating a team of opinionated agent personas. Each persona is a `.md` file in `.claude/agents/` — a standard Claude Code sub-agent. The system consists of:

- **Commands** (`.json`) — Claude Code command definitions that invoke skills
- **Skills** (`.md`) — Prompt files containing the question flows and generation logic
- **Install scripts** (`install.sh` / `install.ps1`) — Distribution mechanism

The persona question flows and per-skill requirements are fully specified in `REQUIREMENTS.md`. The TBD design questions are resolved in `TBD.md`. This document covers the technical implementation decisions.

Current state: no code exists. This is a greenfield implementation.

## Goals / Non-Goals

**Goals:**
- Implement all seven `/teambuild:*` skills (`init`, `analyst`, `architect`, `designer`, `programmer`, `tester`, `reviewer`)
- Implement install scripts that clone the `release` branch into `~/.claude/teambuilder/`
- Implement update/regen flow: detect existing persona, offer update (pre-fill) or start fresh
- Generate valid Claude Code agent files with dual-purpose frontmatter

**Non-Goals:**
- Automatic persona regeneration (file watching, change detection)
- Extensibility/plugin system for community personas
- Enforcing sequential creation order
- Managing artifacts produced by personas

## Decisions

### 1. Skill files are markdown prompts, not code

Skills are `.md` files — plain prose instructions for Claude to execute. There is no runtime code (Node, Python, shell) inside a skill. The skill prompt tells Claude what questions to ask, what files to read, and what to write.

**Why over scripted approach:** Teambuilder runs inside Claude Code. The "runtime" is Claude itself. Writing skills as prompts means they are easy to read, modify, and fork. No build step, no language runtime dependency.

**Implication:** Skills rely on Claude's ability to read files (via `cat`/Read tool), write files (via Write tool), and follow structured instructions. The skill prompt must be precise about file paths and output format.

---

### 2. Persona file format: Claude agent frontmatter + `teambuilder` key

Generated personas are standard Claude Code agent files with YAML frontmatter extended by a `teambuilder` block:

```yaml
---
name: analyst
description: Business analyst persona for [project name]
model: claude-opus-4-6
teambuilder:
  persona: analyst
  generated: 2026-03-26
  answers:
    domain: fintech
    stakeholders: ["product", "compliance", "eng"]
    ...
---

[generated prose — the agent's system prompt]
```

- Claude Code reads `name`, `description`, `model`
- Teambuilder reads `teambuilder.answers` for the regen/update flow
- The prose body is regenerated on regen; the frontmatter `answers` block is the source of truth for prior answers
- Users may freely edit the prose body and standard agent fields without breaking regen

**Why not a separate answers file:** Keeping answers co-located with the persona means it's one file to commit, share, and track. No risk of answers/persona getting out of sync.

---

### 3. Regeneration: detect-and-ask, pre-fill from frontmatter

When a skill runs and `[persona].md` already exists:

1. Skill reads existing file, extracts `teambuilder.answers` from frontmatter
2. Asks: "A persona already exists — update it or start fresh?"
3. **Update:** Re-runs question flow with prior answers as defaults; user presses enter to keep or types to change
4. **Start fresh:** Ignores existing file, runs full question flow

**Why manual only:** Automatic regeneration (on file change) is fragile and surprising. Users should control when personas are rebuilt. The update flow makes re-running low-friction.

---

### 4. Installation via shell scripts cloning `release` branch

`install.sh` (bash) and `install.ps1` (PowerShell) — curl-pipeable or download-and-run:

```bash
# First install
git clone --depth 1 --branch release https://github.com/rendle/teambuilder ~/.claude/teambuilder

# Re-run (update)
cd ~/.claude/teambuilder && git pull
```

Scripts detect existing install and switch to update mode automatically.

**Post-clone step:** Scripts symlink `~/.claude/teambuilder/commands/teambuild/` into `~/.claude/commands/teambuild/`. This makes all `/teambuild:*` commands available system-wide. On re-run, the symlink is verified (recreated if missing) after `git pull`.

**Why `release` branch:** Stable installs track `release`; development happens on `main`. Users get updates by re-running the install script.

---

### 5. Variants via optional argument (`/teambuild:programmer ios`)

The programmer skill accepts an optional variant argument. The command definition passes the argument through to the skill. The skill:

- With no argument: generates `programmer.md`
- With argument `ios`: generates `programmer-ios.md`, reads `programmer.md` if it exists and inherits cross-cutting conventions as defaults

**Why not separate commands per variant:** Variants are open-ended (any platform/domain). A single parameterised command scales to any variant without new files.

---

### 6. Shared context inlined, not referenced

Each persona file inlines the content of `_project.md` and `_team.md` (and relevant upstream persona outputs) directly into its prose body. It does not `@include` or reference them at runtime.

**Why:** Personas are designed to be self-contained and usable as sub-agents. A sub-agent only sees its own system prompt. If context were referenced externally, it would be invisible when the persona is invoked as a sub-agent.

**Implication:** When upstream context changes (new team member, updated requirements), personas must be regenerated to pick up the change. This is acceptable — the update flow makes regeneration low-friction.

## Risks / Trade-offs

**Skill prompts depend on Claude following precise instructions** → Mitigate by writing skills with explicit, structured output sections and validating with real Claude Code sessions during development.

**Frontmatter YAML parsing is done by Claude, not a parser** → Mitigate by keeping `teambuilder.answers` structure simple (flat or one-level nested), with consistent formatting in the generation prompt.

**Install script path resolution for Claude Code skills is unconfirmed** → Mitigate by confirming the exact mechanism early (first implementation task) before writing the install scripts.

**Inlined shared context grows stale** → Known and accepted. The update flow addresses this. Could add a warning in `_team.md` noting which personas may need regenerating when it changes — low-cost mitigation.

## Migration Plan

No existing installation to migrate. Greenfield.

Distribution path: merge to `release` branch → users run install script. No deployment infrastructure required.

## Open Questions

None — all design questions resolved.
