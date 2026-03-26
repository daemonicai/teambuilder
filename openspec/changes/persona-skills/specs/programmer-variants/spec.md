## ADDED Requirements

### Requirement: Programmer skill accepts an optional variant argument
The `/teambuild:programmer` skill SHALL accept an optional variant argument (e.g., `ios`, `api`, `web`). When a variant is provided, the output file SHALL be named `programmer-<variant>.md`.

#### Scenario: No variant argument
- **WHEN** a user runs `/teambuild:programmer` with no argument
- **THEN** the skill SHALL generate `.claude/agents/programmer.md`

#### Scenario: Variant argument provided
- **WHEN** a user runs `/teambuild:programmer ios`
- **THEN** the skill SHALL generate `.claude/agents/programmer-ios.md`

### Requirement: Variant skill inherits cross-cutting conventions from base programmer
When generating a variant persona and `programmer.md` already exists, the variant skill SHALL read `programmer.md` and use its `teambuilder.answers` as defaults for cross-cutting convention questions (error handling, logging, dependency philosophy, etc.), asking only variant-specific questions.

#### Scenario: Base programmer exists before variant
- **WHEN** a user runs `/teambuild:programmer ios` and `programmer.md` already exists
- **THEN** the skill SHALL read cross-cutting conventions from `programmer.md`'s `teambuilder.answers`
- **THEN** the skill SHALL present those conventions as defaults, not re-ask them from scratch
- **THEN** the skill SHALL ask only iOS-specific questions

#### Scenario: No base programmer when variant is requested
- **WHEN** a user runs `/teambuild:programmer ios` and `programmer.md` does not exist
- **THEN** the skill SHALL warn the user that running `/teambuild:programmer` first is recommended
- **THEN** the skill SHALL offer to proceed anyway (running the full question set) or cancel

### Requirement: Variant programmer updates `_team.md` noting the variant
When a variant programmer persona is generated, it SHALL update `_team.md` with a role summary that identifies the variant (e.g., "Programmer (iOS)").

#### Scenario: Team roster reflects variant
- **WHEN** `programmer-ios.md` is generated
- **THEN** `_team.md` SHALL be updated with a "Programmer (iOS)" entry
