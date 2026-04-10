## Context

The current `/teambuild:init` command asks four questions and writes two files (`_project.md`, `_team.md`). It treats all projects the same regardless of whether they are greenfield or existing. On existing repos, there is rich signal in the codebase — package manifests, config files, directory structure — that could inform both the shared context files and the team composition recommendations. Each persona skill currently does no codebase investigation of its own; it relies entirely on the user to answer questions accurately.

## Goals / Non-Goals

**Goals:**
- Init performs codebase discovery on existing repos (stage ≠ greenfield) before writing output files
- Discovery reads package manifests and config files — not source code
- Init writes `_stack.md`, `_standards.md`, `_testing.md` as high-level summaries
- Init writes `_recommendations.md` when the codebase signals non-standard team composition
- Each persona skill reads the relevant shared context files and performs a targeted deep dive
- Persona skills update the shared context file with their findings, using section headers for variants
- Persona skills flag discrepancies between what init recorded and what they find now

**Non-Goals:**
- Static analysis or AST parsing of source code
- Automatic persona generation (init recommends, user decides)
- Watching for codebase changes and auto-updating context files
- Discovery for greenfield projects (no codebase to read)
- Designer skill deep-dive (role is UX-focused, not code-focused)

## Decisions

### Decision: Discovery reads manifests and config, not source code

Reading `package.json`, `requirements.txt`, `go.mod`, `.eslintrc`, `pyproject.toml` etc. is reliable, fast, and well-bounded. Reading source code to infer conventions is slow, fragile, and produces low-confidence results. Standards tooling config (ESLint rules, Ruff config, EditorConfig) is authoritative — it's what the team has agreed to enforce.

**Alternative considered:** Read source files and infer conventions statistically. Rejected: too slow for init, confidence too low, and the result would need human verification anyway.

### Decision: Init writes skeleton files; persona skills add their sections

Init writes the high-level summary it can derive from manifests and config. Each persona skill then investigates its area more deeply and updates the relevant file with a focused section. This avoids duplicating investigation effort and keeps each file's content authoritative to the role that knows it best.

**Alternative considered:** Init writes comprehensive files; persona skills read-only. Rejected: init can't match the depth a persona skill achieves with targeted investigation, and files would become stale as skills ran.

### Decision: Section headers keyed to variant argument

When a persona skill is run with a variant (e.g. `/teambuild:programmer frontend`), it owns the `## Frontend` section in `_standards.md`. Without a variant, it writes the file body directly (no header). This makes the update target unambiguous and keeps the convention simple.

**Alternative considered:** Auto-detect section name from codebase. Rejected: the variant arg is already user-defined and explicit — inferring it adds complexity for no gain.

### Decision: `_recommendations.md` is written only when variants are warranted

If init detects a standard single-stack project, it recommends the standard 6 personas with no variants — and writes no `_recommendations.md`. The file only exists when there's something non-standard to say. This avoids cluttering simple projects with a file that adds no value.

**Alternative considered:** Always write `_recommendations.md`. Rejected: on a simple project it would just say "build the standard team" — noise.

### Decision: Discrepancy flagging is surfaced to the user, not auto-corrected

When a persona skill finds that `_stack.md` says Jest but the project now has Vitest, it notes the discrepancy in its output and asks the user whether to update. It does not silently rewrite init's files. The user may have intentionally left a stale entry, or the discrepancy may reflect a migration in progress.

**Alternative considered:** Auto-update shared context files when drift is detected. Rejected: silent rewrites erode trust in the shared files and may overwrite deliberate choices.

## Risks / Trade-offs

- **Manifest variety**: Package manifests vary enormously across ecosystems. Detection logic must handle missing, malformed, or unusual files gracefully. → Mitigation: treat all discovery as best-effort; init states confidence level and invites correction.
- **Monorepo complexity**: Large monorepos may have dozens of `package.json` files. Init must summarise rather than enumerate. → Mitigation: cap enumeration depth, summarise by top-level directory.
- **Stale shared files**: `_stack.md` etc. can drift from the actual codebase between init and persona skill runs. → Mitigation: persona skills flag discrepancies; user decides whether to update.
- **Greenfield misclassification**: A user may classify a project as "existing" when it has almost no code yet, or vice versa. → Mitigation: discovery is low-cost and additive; running it on a near-empty repo produces sparse but harmless files.

## Open Questions

- Should init offer to re-run discovery if the user re-runs it on an existing project (overwrite path)? Current assumption: yes, discovery re-runs and files are overwritten.
- Should `_recommendations.md` be deleted if the user re-runs init and the project now looks like a standard single-stack project? Current assumption: yes, overwrite path removes it if not warranted.
