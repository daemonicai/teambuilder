## ADDED Requirements

### Requirement: OpenSpec binary is required

Teambuilder SHALL require the `openspec` command-line tool to be installed and resolvable on the user's `PATH`. `/teambuild:init` MUST verify the binary is available before proceeding with any other initialization work.

#### Scenario: `openspec` binary is missing

- **WHEN** a user runs `/teambuild:init` on a machine where the `openspec` binary is not on `PATH`
- **THEN** `/teambuild:init` stops before modifying the repository
- **AND** it prints a message instructing the user to install OpenSpec from https://openspec.dev
- **AND** it exits without creating `_project.md`, `_team.md`, or any persona files

#### Scenario: `openspec` binary is present

- **WHEN** a user runs `/teambuild:init` on a machine where the `openspec` binary is resolvable on `PATH`
- **THEN** `/teambuild:init` proceeds with its remaining steps (workspace bootstrap, project context, team file, CLAUDE.md routing)

### Requirement: `/teambuild:init` bootstraps the OpenSpec workspace when missing

`/teambuild:init` SHALL ensure an `openspec/` workspace exists at the project root. If the directory is missing, init MUST run `openspec init` to create it before writing any Teambuilder artifacts.

#### Scenario: `openspec/` directory does not exist

- **WHEN** a user runs `/teambuild:init` in a project that has the `openspec` binary available but no `openspec/` directory
- **THEN** `/teambuild:init` runs `openspec init` in the project root
- **AND** it continues with its remaining initialization steps once `openspec/` exists

#### Scenario: `openspec/` directory already exists

- **WHEN** a user runs `/teambuild:init` in a project that already has an `openspec/` directory
- **THEN** `/teambuild:init` does not re-run `openspec init`
- **AND** it proceeds directly to its remaining initialization steps

### Requirement: Persona templates and skills assume OpenSpec

All Teambuilder persona templates, teambuild skills, and generated team-level artifacts (`_project.md`, `_team.md`) SHALL be written assuming the OpenSpec workflow is present. They MUST NOT contain conditional branches that check whether `openspec/` exists.

#### Scenario: Persona generation after init

- **WHEN** a user runs any `/teambuild:<persona>` skill after `/teambuild:init` has succeeded
- **THEN** the generated persona file references OpenSpec artifacts and commands unconditionally
- **AND** the file contains no "if OpenSpec exists" conditional prose

### Requirement: README documents OpenSpec as a prerequisite

The README SHALL present OpenSpec as a required prerequisite in the install/setup section. It MUST NOT describe OpenSpec as an optional integration.

#### Scenario: User reads the README to install Teambuilder

- **WHEN** a user reads the install section of the README
- **THEN** OpenSpec is listed as a required prerequisite with a link to https://openspec.dev
- **AND** there is no "OpenSpec integration" section describing OpenSpec as optional
