## MODIFIED Requirements

### Requirement: Init command flow for existing repos
Init SHALL follow a branched flow based on the project stage answer.

For **greenfield** projects (stage = "New (greenfield)"):
- Ask 4 questions
- Write `_project.md` and `_team.md`
- Skip discovery entirely — no `_stack.md`, `_standards.md`, `_testing.md`, or `_recommendations.md`
- Prompt user to continue with Analyst

For **existing** projects (stage = "Existing (active development)" or "Legacy (maintenance/migration)"):
- Ask 4 questions
- Perform codebase discovery (see `init-discovery` spec)
- Write `_project.md`, `_team.md`
- Write `_stack.md`, `_standards.md`, `_testing.md` if content was found
- Write `_recommendations.md` if variants are warranted
- Tell the user what was found and what files were written
- Prompt user to continue with Analyst (or the first recommended persona)

#### Scenario: Greenfield project init
- **WHEN** user selects "New (greenfield)" as the project stage
- **THEN** init writes only `_project.md` and `_team.md` — no discovery files

#### Scenario: Existing project init
- **WHEN** user selects "Existing (active development)" or "Legacy (maintenance/migration)"
- **THEN** init performs codebase discovery and writes applicable shared context files before confirming completion

#### Scenario: Existing project with clear variant signals
- **WHEN** discovery finds signals warranting persona variants
- **THEN** init writes `_recommendations.md` and surfaces the recommendations to the user before prompting to continue

#### Scenario: Re-running init on an existing project (overwrite path)
- **WHEN** a user confirms overwrite on an existing `_project.md`
- **THEN** init re-runs discovery, overwrites all shared context files, and deletes `_recommendations.md` if variants are no longer warranted
