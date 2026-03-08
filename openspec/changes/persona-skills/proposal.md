# Proposal: Persona Skills for Claude Code

## Summary

Create a set of Claude Code skills and commands (`/teambuild:*`) that guide users through building a team of opinionated agent personas for their projects. Each persona is a self-contained system prompt file written to `.claude/agents/` and used via `claude --system-prompt-file` or as a sub-agent.

## Motivation

When using Claude Code on a project, different tasks benefit from different expert perspectives — requirements analysis, architecture, design, implementation, testing, review. Today, users either write system prompts from scratch or work without them. Teambuilder provides opinionated, project-aware personas that embody these different expert roles, with a guided creation flow that asks the right questions for each.

## How It Works

### Init → Build → Use

1. **`/teambuild:init`** — Gathers project context (name, description, organization, business goals, constraints) and writes `_project.md` and `_team.md` to `.claude/agents/`. Prompts the user to continue with the Analyst.

2. **`/teambuild:{role}` (e.g., `/teambuild:analyst`)** — A skill that:
   - Reads `_project.md` and any existing artifacts from prior personas
   - Asks the user targeted questions for that role (domain expertise, focus areas, etc.)
   - Generates a self-contained persona file at `.claude/agents/{role}.md`
   - Updates `_team.md` with the new team member
   - Inlines shared context (`_project.md`, `_team.md`) directly into the persona file

3. **User runs the persona** — `claude --system-prompt-file .claude/agents/analyst.md` — does their work, produces artifacts.

4. **Next persona** — User returns and runs `/teambuild:architect`. The skill reads the requirements artifacts the Analyst produced and asks *smarter, more specific questions* informed by that output.

### Sequential, Iterative Flow

Personas are best created one at a time in a natural order, because each persona's output shapes the next:

```
init → analyst → architect → designer → programmer(s) → tester → reviewer
```

The requirements change how you define the Architect. The architecture and design change how you define the Engineers. This isn't enforced — you can create any persona at any time — but the skills are designed to leverage whatever artifacts already exist.

### Variants

Some roles may need multiple variants. A project with an iOS app and a REST API needs two programmer personas. The naming convention is `{role}-{variant}.md`:

- `/teambuild:programmer ios` → `programmer-ios.md`
- `/teambuild:programmer api` → `programmer-api.md`

The skill can also suggest variants based on architecture artifacts it finds.

## Core Personas

| Persona | Role | Knows | Deliberately Ignores |
|---------|------|-------|---------------------|
| Analyst | Requirements & problem space | Domain, users, business goals | Tech stack, implementation |
| Architect | System design & tech decisions | Domain, tech landscape, requirements | UI specifics, test strategy |
| Designer | UX/UI & interaction design | Users, platform conventions, requirements | Backend details |
| Programmer | Implementation | Tech stack, architecture, specs | Business strategy |
| Tester | Quality & verification | Requirements, architecture, edge cases | Implementation details |
| Reviewer | Code review & quality gates | Everything upstream | — |

## Opinionated vs. Customizable

Each persona has a fixed core identity (role, stance, boundaries, output expectations) defined by teambuilder. The variable parts (domain expertise, project-specific context, conventions) are gathered through the skill's question flow.

**Example — Analyst:**
- **Fixed:** Ask before assuming. Structure requirements as user stories. Flag ambiguity. Never suggest technology choices. Never write code.
- **Variable:** Domain expertise (healthcare, fintech, gaming...). Application type (web, mobile, embedded...). User base. Regulatory constraints.

## Generated File Structure

```
.claude/agents/
├── _project.md          ← project & org context (shared source of truth)
├── _team.md             ← team roster with role summaries
├── analyst.md           ← self-contained persona (inlines shared context)
├── architect.md
├── designer.md
├── programmer-ios.md
├── programmer-api.md
├── tester.md
└── reviewer.md
```

## Project Structure

```
teambuilder/
├── commands/            ← Claude Code command definitions
│   ├── teambuild-init.json
│   ├── teambuild-analyst.json
│   ├── teambuild-architect.json
│   ├── teambuild-designer.json
│   ├── teambuild-programmer.json
│   ├── teambuild-tester.json
│   └── teambuild-reviewer.json
│
├── skills/              ← Skill prompts (the opinionated question flows)
│   ├── teambuild-init.md
│   ├── teambuild-analyst.md
│   ├── teambuild-architect.md
│   ├── teambuild-designer.md
│   ├── teambuild-programmer.md
│   ├── teambuild-tester.md
│   └── teambuild-reviewer.md
```

## Non-goals (for now)

- Auto-regenerating personas when shared context changes (prompt the user instead)
- A plugin/extension system for community personas (keep it simple: fork and add)
- Enforcing the sequential creation order
- Managing the artifacts that personas produce (that's the user's domain)
