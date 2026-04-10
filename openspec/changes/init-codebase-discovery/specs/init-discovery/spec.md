## ADDED Requirements

### Requirement: Detect project stack from manifests
Init SHALL scan the project root and immediate subdirectories for package manifests and derive the tech stack from their contents.

Manifests to scan: `package.json`, `requirements.txt`, `Pipfile`, `pyproject.toml`, `go.mod`, `Cargo.toml`, `*.csproj`, `*.sln`, `Gemfile`, `pom.xml`, `build.gradle`, `composer.json`.

For each manifest found, init SHALL extract: language, key frameworks/libraries, package manager.

#### Scenario: Single-stack project
- **WHEN** init finds a single `package.json` with React and Express dependencies
- **THEN** `_stack.md` records: language TypeScript/JavaScript, frameworks React + Express, package manager npm/yarn/pnpm (from lockfile)

#### Scenario: Multi-stack project
- **WHEN** init finds both `package.json` (frontend) and `requirements.txt` (backend) in separate subdirectories
- **THEN** `_stack.md` records both stacks with their root directories noted

#### Scenario: No manifests found
- **WHEN** init finds no recognised package manifests
- **THEN** `_stack.md` is not written, and init notes that stack could not be detected automatically

---

### Requirement: Detect standards tooling from config files
Init SHALL scan for standards enforcement config files and summarise what tooling is in use.

Config files to scan: `.eslintrc*`, `.prettierrc*`, `.editorconfig`, `pyproject.toml` (ruff/black/isort sections), `.rubocop.yml`, `golangci.yml`, `rustfmt.toml`, `CLAUDE.md`, `CONTRIBUTING.md`.

#### Scenario: ESLint and Prettier found
- **WHEN** init finds `.eslintrc.json` and `.prettierrc`
- **THEN** `_standards.md` notes: lint enforced via ESLint, formatting via Prettier

#### Scenario: CLAUDE.md contains conventions
- **WHEN** init finds a `CLAUDE.md` with a coding conventions section
- **THEN** `_standards.md` includes a summary of those conventions

#### Scenario: No standards tooling found
- **WHEN** init finds no standards config files
- **THEN** `_standards.md` notes that no standards tooling was detected; persona skills should ask about conventions during their flows

---

### Requirement: Detect test infrastructure from test directories and CI config
Init SHALL detect what testing frameworks and test types are present.

Signals to look for: directories named `__tests__`, `spec`, `tests`, `test`, `e2e`, `cypress`, `playwright`; config files `jest.config*`, `vitest.config*`, `pytest.ini`, `cypress.config*`, `playwright.config*`; CI workflow files in `.github/workflows/`, `.gitlab-ci.yml`, `.circleci/`.

#### Scenario: Unit and e2e tests detected
- **WHEN** init finds `jest.config.js` and a `cypress/` directory
- **THEN** `_testing.md` records: unit testing via Jest, e2e via Cypress

#### Scenario: CI pipeline detected
- **WHEN** init finds `.github/workflows/ci.yml`
- **THEN** `_testing.md` notes CI is configured via GitHub Actions

#### Scenario: No test infrastructure found
- **WHEN** init finds no test directories or config files
- **THEN** `_testing.md` notes that no test infrastructure was detected

---

### Requirement: Write `_recommendations.md` when variants are warranted
Init SHALL write `_recommendations.md` when codebase analysis indicates that one or more standard personas should be split into variants.

Triggers for programmer variants: multiple distinct tech stacks in separate directories (e.g. React frontend + Python backend).
Triggers for tester variants: multiple distinct test frameworks or test types (e.g. unit tests + e2e tests).

#### Scenario: Frontend and backend stacks detected
- **WHEN** init finds distinct frontend and backend stacks
- **THEN** `_recommendations.md` lists `programmer-frontend` and `programmer-backend` as recommended variants with their respective stacks noted

#### Scenario: Multiple test types detected
- **WHEN** init finds both a unit test framework and an e2e framework
- **THEN** `_recommendations.md` lists separate tester variants (e.g. `tester-unit` and `tester-e2e`)

#### Scenario: Standard single-stack project
- **WHEN** init finds a single coherent tech stack with one test framework
- **THEN** `_recommendations.md` is NOT written

#### Scenario: Re-running init on a standard project
- **WHEN** a user re-runs init (overwrite path) and the project no longer warrants variants
- **THEN** any existing `_recommendations.md` is deleted
