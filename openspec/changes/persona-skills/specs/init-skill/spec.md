## ADDED Requirements

### Requirement: Init skill gathers project context
The `/teambuild:init` skill SHALL ask the user for project name, organization, industry/domain, and project stage (new / existing / legacy).

#### Scenario: User completes init flow
- **WHEN** a user runs `/teambuild:init` and answers all questions
- **THEN** the skill SHALL write `.claude/agents/_project.md` containing the project summary
- **THEN** the skill SHALL write `.claude/agents/_team.md` as an empty team roster
- **THEN** the skill SHALL prompt the user to continue with `/teambuild:analyst`

### Requirement: Init skill creates agents directory if absent
The `/teambuild:init` skill SHALL create `.claude/agents/` if it does not already exist.

#### Scenario: Directory does not exist
- **WHEN** a user runs `/teambuild:init` and `.claude/agents/` does not exist
- **THEN** the skill SHALL create the directory before writing any files

### Requirement: Re-running init offers to overwrite
If `_project.md` already exists, the init skill SHALL ask the user whether to overwrite it or abort.

#### Scenario: Existing project context
- **WHEN** a user runs `/teambuild:init` and `.claude/agents/_project.md` already exists
- **THEN** the skill SHALL notify the user that a project context already exists
- **THEN** the skill SHALL ask whether to overwrite or cancel
- **WHEN** the user chooses to cancel
- **THEN** the skill SHALL exit without modifying any files
