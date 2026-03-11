# Teambuilder

Build a team of opinionated AI agent personas for your project.

Teambuilder is a set of Claude Code skills that guide you through creating specialized agent personas — an Analyst, Architect, Designer, Programmer, Tester, and Reviewer — each with a distinct role, expertise, and perspective. Each persona is a self-contained system prompt file you can use with `claude --system-prompt-file`.

## Why?

Different tasks benefit from different expert perspectives. A requirements conversation needs a different mindset than a code review. But writing good system prompts from scratch is tedious, and most people just skip it.

Teambuilder gives you opinionated, project-aware personas through a guided creation flow that asks the right questions for each role.

## How it works

### 1. Initialize your project

```
/teambuild:init
```

Gathers basic project context (name, org, domain, stage) and sets up the `.claude/agents/` directory.

### 2. Build your team, one persona at a time

```
/teambuild:analyst
/teambuild:architect
/teambuild:designer
/teambuild:programmer
/teambuild:tester
/teambuild:reviewer
```

Each skill asks you targeted questions for that role and generates a persona file. The order matters — each persona's output informs the next. The Analyst's requirements shape the Architect. The architecture shapes the Programmer. This isn't enforced, but it's how you get the best results.

### 3. Use your personas

```bash
claude --system-prompt-file .claude/agents/analyst.md
```

Each persona file is fully self-contained. No dependencies, no runtime config. Just a system prompt that knows your project and has a clear role.

### Variants

Some roles need multiple instances. A project with an iOS app and a REST API needs two programmers:

```
/teambuild:programmer ios
/teambuild:programmer api
```

This produces `programmer-ios.md` and `programmer-api.md`.

## The team

| Persona | Focus | Deliberately ignores |
|---------|-------|---------------------|
| **Analyst** | Requirements, problem space, users, stakeholders | Tech stack, implementation details |
| **Architect** | System design, technology choices, structure | UI specifics, test strategy |
| **Designer** | UX/UI, interaction design, platform conventions | Backend details |
| **Programmer** | Implementation, code, conventions | Business strategy |
| **Tester** | Quality, verification, edge cases | Implementation details |
| **Reviewer** | Code review, quality gates, standards | — |

Each persona has a **fixed core** (role identity, stance, boundaries) defined by Teambuilder, plus **variable parts** (domain expertise, project context, conventions) gathered from your answers.

## What gets generated

```
.claude/agents/
├── _project.md          # Project context (shared source of truth)
├── _team.md             # Team roster with role summaries
├── analyst.md           # Self-contained persona files
├── architect.md
├── designer.md
├── programmer-ios.md
├── programmer-api.md
├── tester.md
└── reviewer.md
```

## Status

Teambuilder is in early design. See [DEVLOG.md](DEVLOG.md) for progress.

## License

TBD
