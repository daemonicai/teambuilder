# Teambuilder Dev Log

## 2026-03-11 — Project kickoff and initial design

### What is this?

Teambuilder is a set of Claude Code skills and commands (`/teambuild:*`) that guide users through building a team of opinionated agent personas for their projects. Each persona is a self-contained `.md` system prompt file written to `.claude/agents/` and used via `claude --system-prompt-file`.

### Design decisions made

**Core flow:** `init -> analyst -> architect -> designer -> programmer(s) -> tester -> reviewer`

Each persona skill reads artifacts from prior personas, asks targeted questions, and generates a self-contained persona file. The sequential order isn't enforced but is designed to be most useful — requirements shape the architect, architecture shapes the programmer, etc.

**Persona structure:** Each persona has a fixed core (role identity, stance, boundaries, output expectations) defined by teambuilder, plus variable parts (domain expertise, project context, conventions) gathered through the skill's question flow.

**Variants:** Some roles need multiple instances. `/teambuild:programmer ios` produces `programmer-ios.md`. The skill can also suggest variants based on architecture artifacts.

**File layout:**
```
.claude/agents/
├── _project.md          # shared project context
├── _team.md             # team roster
├── analyst.md           # one file per persona
├── architect.md
├── ...
```

**Foundational architecture principle:** The Architect persona chooses the best technology for the requirements, not the most familiar. Assumes AI-assisted development where the team can work in any language.

### Artifacts produced

- `openspec/changes/persona-skills/proposal.md` — full design document
- `openspec/changes/persona-skills/REQUIREMENTS.md` — detailed question flows for init, analyst, and architect
- `openspec/changes/persona-skills/NEXT.md` — remaining work tracker
- `openspec/changes/persona-skills/TBD.md` — open questions on installation, extensibility, regeneration, persona file format

### What's next

1. Define question flows for Designer, Programmer, Tester, and Reviewer
2. Resolve open questions in TBD.md (installation, extensibility, regeneration, persona file format)
3. Start implementation
