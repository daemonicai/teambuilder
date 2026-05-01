Set up teambuilder project context for the current project.

## What you do

You are running the `/teambuild:init` setup flow. Your job is to gather basic project context, discover the existing codebase (if applicable), and write shared context files to `.claude/agents/`.

## Step 0: Check for OpenSpec

Before doing anything else, verify that the `openspec` command-line tool is installed and resolvable on `PATH`.

Run `openspec --version` and treat any of the following as "not installed":

- Non-zero exit code
- Shell error on bash/zsh: `command not found`
- PowerShell error: `CommandNotFoundException` / `is not recognized as the name of a cmdlet`
- No output, or output that does not look like a version string (e.g., `0.12.3`)

If the tool is not installed:

- Stop immediately. Do not create any files.
- Tell the user: "Teambuilder requires OpenSpec. Install it from https://openspec.dev and then re-run `/teambuild:init`."

If `openspec --version` prints a version string and exits 0, continue.

## Step 1: Check for existing context

Check whether `.claude/agents/_project.md` already exists.

- If it exists, tell the user a project context already exists and ask using `ask_followup_question` with follow_up_suggestions: `Overwrite`, `Cancel`
- If they choose cancel, stop here.
- If it doesn't exist (or they choose to overwrite), continue.

## Step 2: Create the agents directory

Create `.claude/agents/` if it doesn't already exist.

## Step 2b: Bootstrap the OpenSpec workspace

Check whether an `openspec/` directory exists in the project root.

- If it does **not** exist: run `openspec init` in the project root to create the workspace, then continue.
- If it already exists: skip this step and continue.

## Step 3: Ask these questions

Ask the following questions **one at a time**, waiting for each answer before continuing:

1. **What's the project name?**
2. **What organization or team is this for?** (Can be personal/solo if applicable)
3. **What industry or domain is this in?** (e.g., fintech, healthcare, e-commerce, internal tooling, game development)
4. **What stage is the project at?** — use `ask_followup_question` with these exact follow_up_suggestions: `New (greenfield)`, `Existing (active development)`, `Legacy (maintenance/migration)`

## Step 4: Branch on project stage

**If the stage is "New (greenfield)":** skip directly to Step 9 (Write `_project.md`). Do not run the discovery steps.

**If the stage is "Existing (active development)" or "Legacy (maintenance/migration)":** continue with Steps 5–8 (discovery).

---

## Step 5: Discover the tech stack

Scan the project root and its immediate subdirectories (one level deep only) for the following package manifest files:

- `package.json`
- `requirements.txt`, `Pipfile`, `pyproject.toml`
- `go.mod`
- `Cargo.toml`
- `*.csproj`, `*.sln`
- `Gemfile`
- `pom.xml`, `build.gradle`
- `composer.json`

For each manifest found, extract:
- **Language** — inferred from the manifest type
- **Key frameworks and libraries** — the most significant direct dependencies (not transitive)
- **Package manager** — infer from lockfile: `package-lock.json` → npm, `yarn.lock` → yarn, `pnpm-lock.yaml` → pnpm; for others, infer from the manifest type

**Monorepo handling:** If manifests appear in multiple subdirectories, note the top-level directory for each (e.g., `apps/web/package.json` → "frontend at `apps/web/`"). Do not recurse beyond immediate subdirectories.

Record your findings — you will write them to `_stack.md` in Step 8.

If no manifests are found, note that the stack could not be detected automatically.

---

## Step 6: Discover coding standards

Scan the project root for the following config files:

- `.eslintrc`, `.eslintrc.json`, `.eslintrc.js`, `.eslintrc.yaml`, `.eslintrc.yml`
- `.prettierrc`, `.prettierrc.json`, `.prettierrc.js`, `.prettierrc.yaml`
- `.editorconfig`
- `pyproject.toml` — check for `[tool.ruff]`, `[tool.black]`, `[tool.isort]` sections
- `.rubocop.yml`
- `golangci.yml`, `.golangci.yml`
- `rustfmt.toml`
- `CLAUDE.md` — check for coding conventions sections
- `CONTRIBUTING.md` — check for coding conventions sections

For each found, note: what tooling is enforced, and any key rules visible at a glance (e.g., tab width, quote style, max line length).

Record your findings — you will write a summary to `_standards.md` in Step 8.

If no standards config is found, note that no tooling was detected.

---

## Step 7: Discover test infrastructure

Scan for the following signals:

**Test directories** (check if any of these exist at root or immediate subdirectory level):
`__tests__/`, `spec/`, `tests/`, `test/`, `e2e/`, `cypress/`, `playwright/`

**Test config files** (check root):
`jest.config.js`, `jest.config.ts`, `jest.config.json`,
`vitest.config.js`, `vitest.config.ts`,
`pytest.ini`, `setup.cfg` (check for `[tool:pytest]` section), `pyproject.toml` (check for `[tool.pytest.ini_options]`),
`cypress.config.js`, `cypress.config.ts`,
`playwright.config.js`, `playwright.config.ts`

**CI config** (check if any of these exist):
`.github/workflows/` (list any `.yml` files — note names only),
`.gitlab-ci.yml`,
`.circleci/config.yml`

From these signals, identify:
- What test types are present (unit, integration, e2e, component, etc.)
- What frameworks/runners are in use
- Whether CI is configured and which provider

Record your findings — you will write a summary to `_testing.md` in Step 8.

If no test infrastructure is found, note that none was detected.

---

## Step 8: Write discovery files and determine recommendations

### Write `_stack.md`

If any stack content was found in Step 5, write `.claude/agents/_stack.md`:

```
# Tech Stack

[For each stack found, a brief section:]

## [Language / area, e.g. "Frontend" or "Backend" or "Python"]

**Language:** [language]
**Framework:** [key framework(s)]
**Package manager:** [manager]
**Key dependencies:** [3-5 most significant libs]
[If monorepo: **Root:** [directory]]
```

If nothing was found, do not write `_stack.md`.

### Write `_standards.md` (skeleton)

If any standards content was found in Step 6, write `.claude/agents/_standards.md`:

```
# Coding Standards

*Summary from codebase discovery — persona skills will add detail.*

## Tooling found

[List each tool found and what it enforces, e.g.:]
- ESLint (`.eslintrc.json`) — linting enforced
- Prettier (`.prettierrc`) — formatting enforced
- EditorConfig — indentation: [value], line endings: [value]
[etc.]

## Notes from CLAUDE.md / CONTRIBUTING.md

[If conventions were found in these files, summarise them here. Otherwise: "None detected."]
```

If no standards tooling was found, write `_standards.md` with:

```
# Coding Standards

*No standards tooling detected during init. The Programmer persona will capture conventions.*
```

### Write `_testing.md` (skeleton)

If any test infrastructure was found in Step 7, write `.claude/agents/_testing.md`:

```
# Testing

*Summary from codebase discovery — the Tester persona will add detail.*

## Test types detected

[List each type detected with its framework, e.g.:]
- Unit tests: Jest (`jest.config.js`)
- E2E tests: Cypress (`cypress/`, `cypress.config.ts`)

## CI pipeline

[If CI was detected: provider + any pipeline file names. Otherwise: "None detected."]
```

If no test infrastructure was found, write `_testing.md` with:

```
# Testing

*No test infrastructure detected during init. The Tester persona will define the test strategy.*
```

### Determine recommendations

Analyse the discovery findings to determine whether persona variants are warranted:

**Programmer variants** are warranted when: two or more distinct language stacks are found in separate directories (e.g., JavaScript frontend + Python backend). A single language with multiple frameworks does not necessarily warrant variants — use judgment.

**Tester variants** are warranted when: two or more distinct test types with meaningfully different tooling or concerns are found (e.g., pytest unit tests + Cypress e2e tests). A single framework handling multiple test types does not warrant variants.

**If variants are warranted:** write `.claude/agents/_recommendations.md`:

```
# Recommended Team

Based on codebase analysis, the following team composition is recommended.

## Standard Personas

Analyst, Architect, Designer, Reviewer — one of each.

## Programmer Variants

[For each recommended variant:]
- `programmer-[variant]` — [language/framework] ([directory or area])

**Rationale:** [1 sentence explaining why variants are warranted, e.g., "Separate frontend (React/TypeScript) and backend (Python/FastAPI) stacks with distinct conventions."]

## Tester Variants

[For each recommended variant:]
- `tester-[variant]` — [framework] ([test type])

**Rationale:** [1 sentence, e.g., "Unit tests (pytest) and e2e tests (Cypress) have different tooling, scope, and ownership concerns."]
```

Omit sections that don't apply (e.g., if only programmer variants are warranted, omit the Tester Variants section).

**If no variants are warranted:** do not write `_recommendations.md`. If a `_recommendations.md` already exists (overwrite path), delete it.

---

## Step 9: Write `_project.md`

Write `.claude/agents/_project.md` with this content (fill in the answers from Step 3):

```
# Project: [project name]

**Organization:** [org/team]
**Domain:** [industry/domain]
**Stage:** [stage]
```

## Step 10: Write `_team.md`

Write `.claude/agents/_team.md` with this content:

```
# Team

*No personas created yet.*
```

## Step 11: Write OpenSpec routing to `CLAUDE.md`

OpenSpec is a required part of the Teambuilder workflow. This step writes the routing block that tells Claude which persona to use for each OpenSpec command.

Check whether `CLAUDE.md` in the project root already contains `## OpenSpec + Teambuilder`. If it does, skip this step to avoid duplication.

If not, append the following block to `CLAUDE.md` (creating the file if it doesn't exist):

```
## OpenSpec + Teambuilder

OpenSpec is the change-management workflow for this project. Route each OpenSpec command to the appropriate Teambuilder persona or orchestration skill:

- `/opsx:explore` or `openspec-explore` → use `analyst.md` as the thinking partner
- `/opsx:propose` or `openspec-propose` → use `architect.md` to drive artifact creation
- `/opsx:apply` or `openspec-apply-change` → after the skill reads context and shows progress, invoke the `teambuilder-apply-dispatch-loop` skill to dispatch each pending task in `tasks.md` to the right persona (Designer for design/UX tasks, Tester for testing tasks, Programmer for everything else) in a fresh subagent.
- `/opsx:archive` or `openspec-archive-change` → before running any archival steps, invoke the `teambuilder-review-gate` skill to run the Reviewer persona over the completed change and surface findings to the user.

Inline persona invocation ("use the programmer", "use the designer", etc.) remains available for small or off-workflow tasks. The orchestrated path above is the default for non-trivial work.
```

## Step 12: Confirm and prompt

**For greenfield projects:**

Tell the user that project context has been saved to `.claude/agents/` and their team roster is ready.

**For existing projects:**

Tell the user what was discovered and what files were written. Be specific. For example:

> Project context saved to `.claude/agents/`. Here's what I found:
>
> **Stack:** React/TypeScript (frontend at `apps/web/`), Python/FastAPI (backend at `apps/api/`)
> **Standards:** ESLint + Prettier (frontend), Ruff (backend)
> **Testing:** Vitest (unit), Playwright (e2e), GitHub Actions CI
> **OpenSpec:** Workspace ready at `openspec/`
>
> Written: `_project.md`, `_team.md`, `_stack.md`, `_standards.md`, `_testing.md`
>
> **Recommendation:** Based on the separate frontend/backend stacks, I suggest creating `programmer-frontend` and `programmer-backend` rather than a single Programmer persona. See `_recommendations.md` for details.

If `_recommendations.md` was not written, omit the recommendation paragraph.

Then use `ask_followup_question` with follow_up_suggestions: `Build the Analyst persona now`, `I'll do it later`

- If **Build now**: proceed directly as if the user has run `/teambuild:analyst` — do not ask them to run it manually.
