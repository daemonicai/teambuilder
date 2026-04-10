Set up teambuilder project context for the current project.

## What you do

You are running the `/teambuild:init` setup flow. Your job is to gather basic project context, discover the existing codebase (if applicable), and write shared context files to `.claude/agents/`.

## Step 1: Check for existing context

Check whether `.claude/agents/_project.md` already exists.

- If it exists, tell the user a project context already exists and ask using `ask_followup_question` with follow_up_suggestions: `Overwrite`, `Cancel`
- If they choose cancel, stop here.
- If it doesn't exist (or they choose to overwrite), continue.

## Step 2: Create the agents directory

Create `.claude/agents/` if it doesn't already exist.

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

Check whether `CLAUDE.md` in the project root already contains `## OpenSpec + Teambuilder`. If it does, skip this step to avoid duplication.

If not, append the following block to `CLAUDE.md` (creating the file if it doesn't exist):

```
## OpenSpec + Teambuilder

When using OpenSpec, route to project personas if they exist in `.claude/agents/`:

- `/opsx:explore` or `openspec-explore` → use `analyst.md` as the thinking partner
- `/opsx:propose` or `openspec-propose` → use `architect.md` to drive artifact creation
- `/opsx:apply` or `openspec-apply-change` → infer from pending tasks in `tasks.md`:
  - Design/UX tasks → `designer.md`
  - Implementation tasks → `programmer.md` or `programmer-<variant>.md`
  - Testing tasks → `tester.md`
  - Proceed without a persona if the relevant one doesn't exist yet
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
>
> Written: `_project.md`, `_team.md`, `_stack.md`, `_standards.md`, `_testing.md`
>
> **Recommendation:** Based on the separate frontend/backend stacks, I suggest creating `programmer-frontend` and `programmer-backend` rather than a single Programmer persona. See `_recommendations.md` for details.

If `_recommendations.md` was not written, omit the recommendation paragraph.

Then use `ask_followup_question` with follow_up_suggestions: `Build the Analyst persona now`, `I'll do it later`

- If **Build now**: proceed directly as if the user has run `/teambuild:analyst` — do not ask them to run it manually.
