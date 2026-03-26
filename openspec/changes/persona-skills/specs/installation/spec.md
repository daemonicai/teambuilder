## ADDED Requirements

### Requirement: Install script clones release branch
The install script (`install.sh` on Unix/macOS, `install.ps1` on Windows) SHALL clone the `release` branch of the teambuilder repository into `~/.claude/teambuilder/` using a shallow clone (`--depth 1`).

#### Scenario: Fresh install on Unix/macOS
- **WHEN** a user runs `install.sh` and `~/.claude/teambuilder/` does not exist
- **THEN** the script SHALL perform `git clone --depth 1 --branch release <repo-url> ~/.claude/teambuilder/`
- **THEN** the script SHALL print a success message indicating the install location

#### Scenario: Fresh install on Windows
- **WHEN** a user runs `install.ps1` and `~/.claude/teambuilder/` does not exist
- **THEN** the script SHALL perform the equivalent git clone into `$HOME/.claude/teambuilder/`
- **THEN** the script SHALL print a success message indicating the install location

### Requirement: Re-running install script performs an update
If the install directory already exists, the install script SHALL update the existing installation rather than re-cloning.

#### Scenario: Update existing install
- **WHEN** a user runs the install script and `~/.claude/teambuilder/` already exists
- **THEN** the script SHALL run `git pull` in that directory
- **THEN** the script SHALL print a message indicating an update was performed

### Requirement: Install script is curl-pipeable
The `install.sh` script SHALL be safe to pipe from curl (i.e., `curl -fsSL <url> | bash`) without requiring interactive input under normal conditions.

#### Scenario: Piped execution completes without prompts
- **WHEN** the script is executed non-interactively via curl pipe
- **THEN** the script SHALL complete successfully without blocking on user input
- **THEN** the script SHALL exit with code 0 on success and non-zero on failure
