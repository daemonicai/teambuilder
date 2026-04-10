## Why

When `/teambuild:init` runs on an existing repo, it asks four questions and stops — leaving users to manually figure out what personas they need and what variants make sense. It misses a significant opportunity: the codebase already contains most of what it needs to know about the project's stack, standards, and test infrastructure.

## What Changes

- `/teambuild:init` gains a codebase discovery phase for existing repos (greenfield projects skip it entirely)
- Discovery reads package files and config files (not source code) to detect languages, frameworks, packages, standards tooling, and test infrastructure
- Init writes three new shared context files: `_stack.md`, `_standards.md`, `_testing.md` — high-level summaries, not exhaustive docs
- Init writes `_recommendations.md` when the codebase suggests non-standard team composition (e.g. multiple programmer or tester variants)
- Each persona skill gains a targeted deep-dive phase: it reads the relevant shared context files, investigates the parts of the codebase that matter to its role, updates the shared file with its findings (using section headers when multiple variants exist), and flags any discrepancies between what init recorded and what it finds now
- Persona skills use their variant argument as the section header name (e.g. `/teambuild:programmer frontend` → `## Frontend` in `_standards.md`)

## Capabilities

### New Capabilities

- `init-discovery`: Init sweeps the codebase on existing repos — detects stack, standards tooling, test infrastructure — and writes `_stack.md`, `_standards.md`, `_testing.md`, and `_recommendations.md`
- `persona-deep-dive`: Each persona skill reads relevant shared context files, performs a targeted codebase investigation, updates the shared file with its section, and flags drift from what init recorded

### Modified Capabilities

- `init-flow`: The init command flow gains a new discovery phase between "gather answers" and "write output" for existing repos; output now includes additional files beyond `_project.md` and `_team.md`

## Impact

- `commands/teambuild/init.md` — primary change, new discovery + recommendation logic
- `commands/teambuild/analyst.md` — reads `_project.md`, `_team.md` (no change needed, analyst is requirements-only)
- `commands/teambuild/architect.md` — reads `_stack.md`, drills into structure and service boundaries
- `commands/teambuild/programmer.md` — reads `_stack.md` + `_standards.md`, updates `_standards.md`, flags drift
- `commands/teambuild/tester.md` — reads `_stack.md` + `_testing.md`, updates `_testing.md`, flags drift
- `commands/teambuild/reviewer.md` — reads all shared context files
- `commands/teambuild/designer.md` — no significant change (designer role is UX-focused, not code-focused)
