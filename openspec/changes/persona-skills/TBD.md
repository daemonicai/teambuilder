# TBD — Open Questions

## The Actual Questions Each Skill Asks

**RESOLVED** — see REQUIREMENTS.md for all persona question flows.

---

## Installation & Configuration

**RESOLVED**

- `install.sh` / `install.ps1` — curl-pipeable or download-and-run
- Clones the `release` branch (shallow: `--depth 1 --branch release`) into `~/.claude/teambuilder/`
- Re-running the script detects an existing install and runs `git pull` instead
- No separate uninstall for v1 — deleting `~/.claude/teambuilder/` is sufficient
- **Open during implementation:** confirm exact Claude Code path for skill resolution, and whether install script needs to symlink/copy files into `~/.claude/commands/`

---

## Extensibility for Community Personas

Deferred — not in scope for v1.

---

## Persona Regeneration

**RESOLVED**

- Manual only — no automatic file-watching or change detection
- Re-running a persona command detects an existing `.claude/agents/<persona>.md` and asks: **update** or **start fresh**
- **Update flow:** re-asks questions but pre-fills answers from the existing persona's `teambuilder.answers` frontmatter — user only corrects what's changed
- **Start fresh:** wipes the file and runs the full question flow

---

## Persona File Format

**RESOLVED**

Generated personas are Claude agent files (`.claude/agents/<persona>.md`) with standard Claude Code agent frontmatter plus a `teambuilder` key for regen data:

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
    tone: direct
    ...
---

[generated persona prose — the agent's system prompt]
```

- Claude Code reads the standard keys (`name`, `description`, `model`, etc.)
- Teambuilder reads `teambuilder.answers` for update/regen
- Users can freely edit the prose body and standard agent fields
- Teambuilder only touches what it owns (the `teambuilder` block and the prose body on regen)
- Generated personas live in **project-level** `.claude/agents/` — committed to the repo and shared with the team
