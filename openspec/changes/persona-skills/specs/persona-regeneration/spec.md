## ADDED Requirements

### Requirement: Skill detects existing persona and offers update or fresh start
When a persona skill runs and the target `.claude/agents/<persona>.md` already exists, the skill SHALL ask the user whether to update the existing persona or start fresh.

#### Scenario: Existing persona — user chooses update
- **WHEN** a user runs a persona skill and the target persona file already exists
- **THEN** the skill SHALL notify the user that a persona already exists
- **THEN** the skill SHALL ask: update it or start fresh?
- **WHEN** the user chooses update
- **THEN** the skill SHALL read `teambuilder.answers` from the existing file's frontmatter
- **THEN** the skill SHALL re-run the question flow with prior answers presented as defaults
- **THEN** the user SHALL be able to accept a prior answer by pressing enter or type a new answer to override it

#### Scenario: Existing persona — user chooses start fresh
- **WHEN** a user runs a persona skill and the target persona file already exists
- **WHEN** the user chooses start fresh
- **THEN** the skill SHALL run the full question flow with no pre-filled defaults
- **THEN** the skill SHALL overwrite the existing persona file completely

### Requirement: Updated persona preserves user-edited prose unless regenerated
When the update flow regenerates the prose body, it SHALL use the current answers (updated or confirmed) to generate new prose. It SHALL NOT attempt to preserve hand-edits to the prose body.

#### Scenario: User had hand-edited the prose body
- **WHEN** a user updates a persona they had previously hand-edited
- **THEN** the skill SHALL regenerate the prose body from the current answers
- **THEN** the skill SHALL NOT attempt to diff or merge the hand-edited prose

### Requirement: Regenerated persona updates the `teambuilder.generated` timestamp
When a persona is regenerated (update or fresh), the skill SHALL update `teambuilder.generated` in the frontmatter to the current date.

#### Scenario: Regen updates timestamp
- **WHEN** a persona is regenerated
- **THEN** `teambuilder.generated` in the frontmatter SHALL reflect the date of regeneration
