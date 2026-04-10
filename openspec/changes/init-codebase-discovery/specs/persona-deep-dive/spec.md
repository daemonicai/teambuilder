## ADDED Requirements

### Requirement: Persona skills read relevant shared context files before asking questions
Each persona skill SHALL read the shared context files relevant to its role before beginning its question flow, when those files exist.

| Skill | Reads |
|-------|-------|
| analyst | `_project.md`, `_team.md` |
| architect | `_project.md`, `_team.md`, `_stack.md` |
| designer | `_project.md`, `_team.md` |
| programmer | `_project.md`, `_team.md`, `_stack.md`, `_standards.md` |
| tester | `_project.md`, `_team.md`, `_stack.md`, `_testing.md` |
| reviewer | `_project.md`, `_team.md`, `_stack.md`, `_standards.md`, `_testing.md` |

#### Scenario: Shared context files exist
- **WHEN** a persona skill runs and the relevant shared context files exist
- **THEN** the skill reads them and uses their contents to inform its questions and reduce redundancy

#### Scenario: Shared context files do not exist
- **WHEN** a persona skill runs and no shared context files exist (greenfield or pre-init)
- **THEN** the skill proceeds with its standard question flow without modification

---

### Requirement: Programmer and tester skills perform targeted codebase investigation
The programmer and tester skills SHALL perform a targeted investigation of the parts of the codebase relevant to their role, beyond what init recorded in the shared context files.

Programmer investigates: actual code files for conventions not captured in config (naming patterns, module structure, idioms), architecture patterns in use.
Tester investigates: test file structure, test naming conventions, coverage configuration, CI pipeline test steps.

#### Scenario: Programmer deep-dive on existing code
- **WHEN** the programmer skill runs on an existing repo with `_stack.md` present
- **THEN** the skill reads representative source files to verify and extend what `_standards.md` records

#### Scenario: Tester deep-dive on existing tests
- **WHEN** the tester skill runs on an existing repo with `_testing.md` present
- **THEN** the skill reads test files to understand naming conventions, test structure, and coverage patterns

---

### Requirement: Skills update shared context files with their section
After completing their investigation, programmer and tester skills SHALL update the relevant shared context file with their findings.

For a skill run without a variant argument: write the findings directly to the file body (no section header).
For a skill run with a variant argument: write findings under a `## <Variant>` section header (title-cased variant arg).

Re-running a skill MUST replace only its own section, leaving other sections untouched.

#### Scenario: Single programmer, no variant
- **WHEN** `/teambuild:programmer` runs (no variant arg) and completes its investigation
- **THEN** `_standards.md` is updated with the programmer's findings as the file body

#### Scenario: Programmer with variant
- **WHEN** `/teambuild:programmer frontend` runs and completes its investigation
- **THEN** `_standards.md` gains or replaces a `## Frontend` section with the programmer's findings

#### Scenario: Two programmer variants, sequential runs
- **WHEN** `/teambuild:programmer frontend` runs, then `/teambuild:programmer backend` runs
- **THEN** `_standards.md` contains both `## Frontend` and `## Backend` sections

#### Scenario: Re-running a variant
- **WHEN** `/teambuild:programmer frontend` is re-run after already having written a `## Frontend` section
- **THEN** the `## Frontend` section is replaced; the `## Backend` section (if present) is unchanged

---

### Requirement: Skills flag discrepancies between shared context and live codebase
When a persona skill finds that the live codebase contradicts what a shared context file records, it SHALL surface the discrepancy to the user and ask whether to update.

#### Scenario: Stack entry is stale
- **WHEN** `_stack.md` records Jest but the skill finds Vitest in the package manifest
- **THEN** the skill notes: "_stack.md records Jest, but I found Vitest — this may have changed since init ran. Update _stack.md?" and offers Yes/No

#### Scenario: No discrepancy found
- **WHEN** the skill's findings match what the shared context files record
- **THEN** the skill proceeds without surfacing any discrepancy message

#### Scenario: User declines update
- **WHEN** the skill asks about a discrepancy and the user says No
- **THEN** the skill uses the live value for its own section and leaves the shared context file unchanged
