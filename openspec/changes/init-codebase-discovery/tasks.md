## 1. Init — Branched Flow by Stage

- [x] 1.1 Add stage-check branch in `init.md`: after step 3 (asking questions), branch on stage answer — greenfield skips discovery, existing/legacy continues to discovery
- [x] 1.2 Greenfield path: write only `_project.md` and `_team.md` (current behaviour, no change needed beyond confirming the branch)

## 2. Init — Codebase Discovery

- [x] 2.1 Write discovery instructions in `init.md`: scan for package manifests (`package.json`, `requirements.txt`, `pyproject.toml`, `go.mod`, `Cargo.toml`, `*.csproj`, `Gemfile`, `pom.xml`, `build.gradle`, `composer.json`) in root and immediate subdirectories
- [x] 2.2 Write stack extraction instructions: from each manifest, extract language, key frameworks/libraries, package manager (infer from lockfile: `package-lock.json` → npm, `yarn.lock` → yarn, `pnpm-lock.yaml` → pnpm)
- [x] 2.3 Write standards detection instructions: scan for `.eslintrc*`, `.prettierrc*`, `.editorconfig`, `pyproject.toml` (ruff/black sections), `.rubocop.yml`, `golangci.yml`, `rustfmt.toml`, `CLAUDE.md`, `CONTRIBUTING.md`
- [x] 2.4 Write test infrastructure detection instructions: scan for test directories (`__tests__`, `spec`, `tests`, `test`, `e2e`, `cypress`, `playwright`) and config files (`jest.config*`, `vitest.config*`, `pytest.ini`, `cypress.config*`, `playwright.config*`) and CI configs (`.github/workflows/`, `.gitlab-ci.yml`, `.circleci/`)
- [x] 2.5 Write output instructions for `_stack.md`: format, what to include, what to omit, how to handle monorepos (summarise by top-level directory, cap depth)
- [x] 2.6 Write output instructions for `_standards.md` skeleton: list tooling found; note where no tooling was detected
- [x] 2.7 Write output instructions for `_testing.md` skeleton: list test types, frameworks, and CI pipeline found; note gaps

## 3. Init — Recommendations

- [x] 3.1 Write recommendation logic instructions: programmer variant trigger (multiple distinct stacks in separate directories), tester variant trigger (multiple distinct test frameworks/types)
- [x] 3.2 Write `_recommendations.md` output instructions: format, what to include (variant names, rationale, stack/framework associations)
- [x] 3.3 Write suppression logic: do not write `_recommendations.md` for standard single-stack projects
- [x] 3.4 Write overwrite-path cleanup instructions: delete `_recommendations.md` if re-running init and variants are no longer warranted

## 4. Init — Updated Confirmation Step

- [x] 4.1 Update step 6 (confirm and prompt) in `init.md`: for existing repos, summarise what was discovered and what files were written before offering to continue
- [x] 4.2 If `_recommendations.md` was written, surface the recommendations to the user in the confirmation step

## 5. Persona Skills — Read Shared Context

- [x] 5.1 Update `architect.md`: add step to read `_stack.md` before the question flow begins (if it exists)
- [x] 5.2 Update `programmer.md`: add step to read `_stack.md` and `_standards.md` before the question flow begins (if they exist)
- [x] 5.3 Update `tester.md`: add step to read `_stack.md` and `_testing.md` before the question flow begins (if they exist)
- [x] 5.4 Update `reviewer.md`: add step to read all shared context files before the question flow begins (if they exist)

## 6. Persona Skills — Targeted Deep Dive

- [x] 6.1 Update `programmer.md`: add a targeted investigation step — read representative source files to verify and extend `_standards.md` findings (naming patterns, module structure, idioms)
- [x] 6.2 Update `tester.md`: add a targeted investigation step — read test files to understand naming conventions, test structure, and coverage patterns

## 7. Persona Skills — Update Shared Context Files

- [x] 7.1 Update `programmer.md`: after investigation, write findings to `_standards.md` — body-only if no variant arg, `## <Variant>` section if variant arg present; replace only own section on re-run
- [x] 7.2 Update `tester.md`: after investigation, write findings to `_testing.md` — body-only if no variant arg, `## <Variant>` section if variant arg present; replace only own section on re-run

## 8. Persona Skills — Discrepancy Detection

- [x] 8.1 Update `programmer.md`: after investigation, compare findings against `_stack.md` and `_standards.md`; if discrepancies found, surface them to the user with an update prompt (Yes/No)
- [x] 8.2 Update `tester.md`: after investigation, compare findings against `_stack.md` and `_testing.md`; if discrepancies found, surface them to the user with an update prompt (Yes/No)
- [x] 8.3 Update `architect.md`: lightweight discrepancy check — if `_stack.md` contents conflict with what the architect finds in structure/manifests, note the discrepancy

## 9. Verification

- [ ] 9.1 Verify init on a greenfield project: only `_project.md` and `_team.md` written, no discovery files
- [ ] 9.2 Verify init on an existing single-stack project: `_stack.md`, `_standards.md`, `_testing.md` written; no `_recommendations.md`
- [ ] 9.3 Verify init on a multi-stack project (e.g. JS frontend + Python backend): `_recommendations.md` written with correct programmer variant suggestions
- [ ] 9.4 Verify init on a project with multiple test types: `_recommendations.md` includes tester variant suggestions
- [ ] 9.5 Verify programmer skill on existing repo: reads `_stack.md` + `_standards.md`, updates `_standards.md` with findings
- [ ] 9.6 Verify programmer variants: two runs (`frontend`, `backend`) produce two sections in `_standards.md`; re-running `frontend` replaces only that section
- [ ] 9.7 Verify tester skill on existing repo: reads `_testing.md`, updates it with deep-dive findings
- [ ] 9.8 Verify discrepancy flagging: engineer a mismatch between `_stack.md` and live codebase; confirm skill surfaces it and respects user's Yes/No choice

<!-- Verification tasks (9.x) require live testing against real projects — to be completed manually -->
