## ADDED Requirements

### Requirement: Persona skills read upstream artifacts
Each persona skill SHALL read `_project.md` and `_team.md` before asking questions. Skills with upstream persona dependencies (e.g., architect reads analyst output) SHALL read those artifacts if they exist and use their content to inform adaptive questions.

#### Scenario: Upstream artifact exists
- **WHEN** a persona skill runs and a relevant upstream artifact exists (e.g., `analyst.md` exists when running `/teambuild:architect`)
- **THEN** the skill SHALL read that artifact
- **THEN** the skill SHALL ask adaptive follow-up questions informed by the artifact's content

#### Scenario: Upstream artifact does not exist
- **WHEN** a persona skill runs and an expected upstream artifact does not exist
- **THEN** the skill SHALL proceed with its baseline question set without error
- **THEN** the skill MAY notify the user that certain questions could be more specific with the upstream persona present

### Requirement: Persona skills write self-contained agent files
Each persona skill SHALL write a self-contained `.claude/agents/<persona>.md` file that inlines all relevant context (from `_project.md`, `_team.md`, and relevant upstream personas) into the prose body.

#### Scenario: Persona file is generated
- **WHEN** a user completes a persona skill's question flow
- **THEN** the skill SHALL write `.claude/agents/<persona>.md`
- **THEN** the file SHALL contain valid YAML frontmatter with `name`, `description`, `model`, and `teambuilder` keys
- **THEN** the file's prose body SHALL include inlined content from `_project.md` and `_team.md`
- **THEN** the skill SHALL update `_team.md` with a summary of the new persona

### Requirement: Persona skill questions follow the flows defined in REQUIREMENTS.md
Each persona skill's question flow SHALL match the questions and adaptive logic specified in REQUIREMENTS.md for that persona.

#### Scenario: Analyst skill question flow
- **WHEN** a user runs `/teambuild:analyst`
- **THEN** the skill SHALL ask all questions listed under `/teambuild:analyst` in REQUIREMENTS.md
- **THEN** the skill SHALL use answers to populate the variable sections of `analyst.md`

#### Scenario: Architect skill adapts to requirements
- **WHEN** a user runs `/teambuild:architect` and `analyst.md` exists
- **THEN** the skill SHALL ask adaptive questions informed by the requirements captured in `analyst.md` (e.g., real-time needs, multi-platform, data-heavy)
