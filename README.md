# Teambuilder

Build a team of opinionated AI agent personas for your project.

Teambuilder is a set of Claude Code skills that guide you through creating specialized agent personas — an Analyst, Architect, Designer, Programmer, Tester, and Reviewer — each with a distinct role, expertise, and perspective on your specific project.

## Prerequisites

Teambuilder requires [OpenSpec](https://openspec.dev) to be installed. Install it first:

```bash
# macOS / Linux
curl -fsSL https://openspec.dev/install.sh | bash

# Or see https://openspec.dev for other install options
```

## Install

### macOS / Linux

```bash
curl -fsSL https://daemonicai.github.io/teambuilder/install.sh | bash
```

Re-running updates an existing installation to the latest release.

### Windows

```powershell
irm https://daemonicai.github.io/teambuilder/install.ps1 | iex
```

### Pin a version

The install scripts install the latest GitHub release by default. To pin to a specific version, set `VERSION`:

```bash
# macOS / Linux
curl -fsSL https://daemonicai.github.io/teambuilder/install.sh | VERSION=v0.2.0 bash
```

```powershell
# Windows
$env:VERSION = "v0.2.0"; irm https://daemonicai.github.io/teambuilder/install.ps1 | iex
```

Use `VERSION=main` to install the current trunk (unreleased).

---

## How it works

### 1. Initialize your project

```
/teambuild:init
```

Checks for OpenSpec (exits with an install link if missing), bootstraps the OpenSpec workspace if needed, asks for your project name, organization, domain, and stage, then writes `_project.md` and `_team.md` to `.claude/agents/`. Also writes a routing block to `CLAUDE.md` mapping OpenSpec commands to your personas.

### 2. Build your team, one persona at a time

```
/teambuild:analyst
/teambuild:architect
/teambuild:designer
/teambuild:programmer
/teambuild:tester
/teambuild:reviewer
```

Each skill asks you targeted questions for that role — with clickable options where choices are fixed — and generates a persona file. Each skill reads what the previous personas produced, so questions get smarter as you go. The Analyst's requirements shape the Architect's questions. The architecture informs the Programmer's conventions.

The order isn't enforced, but it's how you get the best results.

### 3. Use your personas

Two paths, for different types of work:

#### Orchestrated path (default for non-trivial work)

Use OpenSpec commands. Your personas are dispatched automatically for each stage:

| Command | What it does | Persona used |
|---------|-------------|--------------|
| `/opsx:explore` | Think through requirements, surface directions | Analyst |
| `/opsx:propose` | Create change with proposal, design, tasks | Architect |
| `/opsx:apply` | Implement tasks via subagent dispatch loop | Designer, Programmer, or Tester — by task type |
| `/opsx:archive` | Review and finalize the change | Reviewer, then archive |

`/opsx:apply` dispatches each task in `tasks.md` to the right persona in a fresh subagent — the Designer for design/UX tasks, the Tester for testing tasks, and the Programmer for everything else. Each persona self-verifies and marks the task complete before the next one is dispatched. `/opsx:archive` invokes the Reviewer for a full change review before sealing the change.

#### Inline path (for small or off-workflow tasks)

Say "use the analyst" (or any persona name) and Claude Code will invoke it directly. Or run standalone:

```bash
claude --system-prompt-file .claude/agents/analyst.md
```

### Variants

Some roles need multiple instances. A project with an iOS app and a REST API needs two programmers:

```
/teambuild:programmer ios
/teambuild:programmer api
```

This produces `programmer-ios.md` and `programmer-api.md`. The variant inherits cross-cutting conventions (error handling, logging, testing approach) from the base programmer persona.

### Updating a persona

Re-run any skill at any time. Teambuilder detects the existing persona and asks whether to update it (pre-filling your previous answers so you only change what's different) or start fresh.

---

## The team

| Persona | Focus | Deliberately ignores |
|---------|-------|---------------------|
| **Analyst** | Requirements, problem space, users, stakeholders | Tech stack, implementation details |
| **Architect** | System design, technology choices, structure | UI specifics, test strategy |
| **Designer** | UX/UI, interaction design, platform conventions | Backend details |
| **Programmer** | Implementation, code, conventions | Business strategy |
| **Tester** | Quality, verification, test strategy | Unit tests (that's the Programmer) |
| **Reviewer** | Conformance, quality gates, code review, per-change review at archive time | Re-litigating upstream decisions |

Each persona has a **fixed core** (role identity, stance, boundaries) defined by Teambuilder, plus **variable parts** (domain expertise, project context, conventions) gathered from your answers.

## What gets generated

```
.claude/agents/
├── _project.md          # Project context (shared source of truth)
├── _team.md             # Team roster with role summaries
├── analyst.md           # Self-contained persona files
├── architect.md
├── designer.md
├── programmer.md
├── programmer-ios.md    # Variant — inherits base conventions
├── programmer-api.md
├── tester.md
└── reviewer.md
```

Each file is a standard Claude Code agent with YAML frontmatter. Commit them to your repo and everyone on the team uses the same personas.

## License

[MIT](LICENSE)
