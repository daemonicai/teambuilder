## ADDED Requirements

### Requirement: Persona files are valid Claude Code agent files
Generated persona files SHALL be valid Claude Code agent files, readable by Claude Code as sub-agents from `.claude/agents/`.

#### Scenario: Persona file has required frontmatter
- **WHEN** a persona file is generated
- **THEN** the file SHALL contain a YAML frontmatter block delimited by `---`
- **THEN** the frontmatter SHALL include `name` (string), `description` (string), and `model` (string)

### Requirement: Persona files include a `teambuilder` frontmatter key
Generated persona files SHALL include a `teambuilder` key in the YAML frontmatter containing the persona type, generation date, and the answers provided during the question flow.

#### Scenario: Frontmatter includes teambuilder metadata
- **WHEN** a persona file is generated
- **THEN** `teambuilder.persona` SHALL be the persona type (e.g., `analyst`)
- **THEN** `teambuilder.generated` SHALL be the ISO 8601 date of generation (e.g., `2026-03-26`)
- **THEN** `teambuilder.answers` SHALL be a map of question keys to the user's answers

### Requirement: Persona files have a prose body used as the agent system prompt
The content below the frontmatter SHALL be the agent's system prompt — the fixed role identity, boundaries, and variable context inlined from project and team artifacts.

#### Scenario: Prose body is the system prompt
- **WHEN** a persona file is used as a Claude Code sub-agent
- **THEN** the prose body SHALL serve as the system prompt
- **THEN** the prose body SHALL include the persona's fixed identity and boundaries
- **THEN** the prose body SHALL include inlined content from `_project.md` and `_team.md`

### Requirement: Persona files live in project-level `.claude/agents/`
Generated persona files SHALL be written to `.claude/agents/` relative to the project root, not to `~/.claude/agents/`.

#### Scenario: Output path is project-level
- **WHEN** a persona skill generates a file
- **THEN** the file SHALL be written to `<project-root>/.claude/agents/<persona>.md`
- **THEN** the file SHALL be committable to the project's git repository
