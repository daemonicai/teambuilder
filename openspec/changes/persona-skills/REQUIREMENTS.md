# Requirements

## /teambuild:init

Minimal project setup. Gathers just enough to orient all personas.

### Questions
- Project name
- Organization
- Industry/domain
- Project stage (new / existing / legacy)

### Output
- Writes `.claude/agents/_project.md` with a brief project summary
- Creates `.claude/agents/_team.md` (empty roster)
- Prompts user to continue with `/teambuild:analyst`

---

## /teambuild:analyst

Defines the Analyst persona — the requirements and problem space expert. This skill both configures the persona AND performs a first pass at requirements gathering; the answers become part of what the Analyst "already knows."

### Questions
- What's the project about? (description, goals, vision)
- Who are the stakeholders?
- Who are the end users? (types, personas, scale)
- What kind of application? (web, mobile, API, desktop, game, embedded...)
- Known constraints? (regulatory, budget, timeline, compliance)
- Domain expertise needed? (what should the Analyst deeply understand?)
- Existing docs or requirements to work from?
- Requirements format preference? (user stories, use cases, jobs-to-be-done, freeform)
- Communication style? (socratic, direct, structured)
- What's explicitly out of scope?

### Output
- Writes `.claude/agents/analyst.md` — self-contained persona file with:
  - Fixed: role identity, stance (ask before assuming), output expectations, boundaries (no tech choices, no code)
  - Variable: domain expertise, user/stakeholder context, constraints, format preferences, communication style
  - Inlined: `_project.md` and `_team.md` content
- Updates `_team.md` with Analyst role summary

---

## /teambuild:architect

Defines the Architect persona — the system design and technology decision maker. Reads the Analyst's output and translates requirements into architecture and tech choices.

### Foundational Principle

Choose the best technology for the requirements, not the most familiar. Assume AI-assisted development where the team can work effectively in any language. Only constrain technology choices based on genuine technical requirements, not team comfort.

### Questions

Always ask:
- Scale expectations (users, data volume, growth trajectory)
- Deployment environment (cloud, on-prem, edge, hybrid)
- Integration points (existing systems, APIs, databases)
- Non-functional priorities — rank: performance, availability, security, cost
- Hard technical constraints? (must use X because of existing contract/infra/regulatory requirement)
- Technologies to explicitly avoid, and why?
- Budget/cost sensitivity for infrastructure?

Informed by requirements (adaptive):
- Real-time needs → event/messaging architecture preferences
- Multi-platform → native vs. cross-platform tradeoffs
- Data-heavy → storage, processing, pipeline questions
- User-facing → API design philosophy
- Regulated → compliance architecture patterns

Architect persona configuration:
- Documentation style? (C4 diagrams, ADRs, informal sketches)
- Decision approach? (opinionated/decisive vs. present-options-and-tradeoffs)
- How opinionated about patterns and conventions?

### Output
- Writes `.claude/agents/architect.md` — self-contained persona file with:
  - Fixed: role identity, the foundational principle (best tech for requirements, not most familiar), boundaries (no implementation, no UI specifics)
  - Variable: scale context, deployment environment, integration landscape, constraint awareness, documentation style, decision approach
  - Inlined: `_project.md` and `_team.md` content
- Updates `_team.md` with Architect role summary

---

## /teambuild:designer

Defines the Designer persona — the UX/UI expert. Reads Architect output to understand platform and any component library constraints. Reads Analyst output for user/stakeholder context.

### Boundaries (deliberately ignores)

- Business/product strategy — redirects to Analyst
- Technical feasibility and implementation — redirects to Architect
- Frontend framework choice (React, Vue, Svelte, etc.) — redirects to Programmer
- Backend details of any kind
- Test strategy

**Exception:** The Designer is aware of component libraries and design systems (e.g., Material UI, Shadcn, HIG) as constraints on what's designable — but ignores how those components are implemented.

### Questions

Always ask:
- Branding inputs — colors, typefaces, logos, existing style guides or brand guidelines
- Existing design system or component library constraints? (e.g., Material UI, Shadcn, Apple HIG, custom)
- Accessibility requirements? (WCAG level — A, AA, AAA — and any specific needs)
- Primary documentation outputs? (wireframes, user flow diagrams, design guidelines, CSS specs — multiple can apply)
- How opinionated should the Designer be? (push back on bad UX vs. present options without judgment)
- Verbosity preference for documentation? (detailed specs vs. high-level guidance)

Informed by Analyst (adaptive):
- Pull user types and personas — ask if there are any design-specific user research inputs beyond what the Analyst captured
- If multiple distinct user types → ask about per-audience UX concerns

Informed by Architect (adaptive):
- Pull platform choices and confirm surfaces needing design (web, iOS, Android, desktop, etc.)
- Web → responsive strategy, breakpoints, browser support constraints
- iOS → HIG adherence level (strict / informed / custom), native vs. custom components
- Android → Material Design adherence, custom theming approach
- Cross-platform → consistency-first vs. platform-native conventions per surface
- Component library present → confirm which components are in scope vs. custom

### Output
- Writes `.claude/agents/designer.md` — self-contained persona file with:
  - Fixed: role identity, boundaries (no tech implementation, no framework choices, no backend, no business strategy), output format expectations (wireframes, user flows, guidelines, CSS specs as applicable)
  - Variable: branding context, design system/component library constraints, accessibility requirements, platform-specific conventions, documentation verbosity, opinionatedness level
  - Inlined: `_project.md` and `_team.md` content, relevant Analyst user/stakeholder summary, Architect platform choices
- Updates `_team.md` with Designer role summary

---

## /teambuild:programmer [variant]

Defines a Programmer persona — the implementation expert for a specific platform, language, or domain. Reads Architect output for tech choices and Analyst output for requirements context. If a base `programmer.md` already exists and this is a variant invocation, reads that too and inherits cross-cutting conventions as defaults.

**Variant behaviour:** Running `/teambuild:programmer ios` produces `programmer-ios.md`. The skill checks for an existing `programmer.md` — if found, cross-cutting conventions (logging, error handling, dependency philosophy, comment style, etc.) default to whatever was established there, and only variant-specific questions are asked. Recommended order: base programmer first, then variants.

### Boundaries (deliberately ignores)

- Business/product strategy — redirects to Analyst
- System architecture and technology selection at the infrastructure level — redirects to Architect
- UX/UI design decisions — redirects to Designer
- Integration/e2e/frontend test strategy — redirects to Tester (Programmer owns unit tests only)

### Questions

Always ask (or confirm from base `programmer.md` if variant):
- Error handling philosophy — explicit errors/result types, exceptions, panic-and-recover, etc.?
- Logging and observability — structured logging, log levels, what to log?
- Telemetry — tracing, metrics, and logs via OpenTelemetry (default); platform/language-specific SDK, sampling strategy, what operations must be instrumented?
- Dependency philosophy — minimal deps, or use libraries liberally? Any preferred sources (e.g., only well-maintained OSS)?
- Code documentation expectations — inline comments, docstrings, "self-documenting code only", README per package?
- Testing approach — test-first (TDD) or test-after? How much unit test coverage is expected?
- Patterns and paradigms to prefer or avoid — functional vs. OOP, specific design patterns, anything explicitly banned?

Language/framework resolution (adaptive, informed by Architect):
- If Architect specified language and framework → ask about conventions within that ecosystem
- If Architect specified language but not framework → present options with guidance, help user choose
- If Architect left tech open → treat as framework-unknown; ask about the domain (API, mobile app, CLI, etc.) and guide through language + framework choice, offering opinionated recommendations based on requirements
- Per chosen language, ask ecosystem-specific convention questions:
  - Go → module structure, interface conventions, context usage
  - TypeScript/JS → strict mode, module system, async patterns
  - Swift → SwiftUI vs UIKit, Combine vs async/await, Swift concurrency approach
  - Python → type hints, sync vs async, packaging approach
  - etc.

Variant-specific (when variant argument is given):
- Confirm which surface/domain this variant covers
- Ask platform-specific convention questions not covered by base programmer
- iOS → SwiftUI vs UIKit, Swift concurrency, HIG compliance in code
- Android → Compose vs Views, Kotlin coroutines approach
- Web frontend → component patterns, state management, CSS approach
- API/backend → API style (REST/GraphQL/RPC), auth patterns, database access patterns
- CLI → UX conventions, configuration approach, output formatting

Persona configuration:
- How strict about conventions? (flag any deviation vs. pragmatic/contextual)
- Proactively suggest improvements beyond the immediate task, or stay narrowly focused?

### Output
- Writes `.claude/agents/programmer.md` or `.claude/agents/programmer-{variant}.md` — self-contained persona file with:
  - Fixed: role identity, boundaries (no architecture, no UX, no integration test strategy), unit test ownership
  - Variable: language and framework context, conventions, error handling style, logging approach, dependency philosophy, documentation expectations, TDD stance, patterns to prefer/avoid, strictness level
  - Inlined: `_project.md` and `_team.md` content, Architect tech choices, relevant Analyst requirements
  - If variant: also inlines cross-cutting conventions from base `programmer.md`
- If no base `programmer.md` exists and this is a variant invocation, warns the user and recommends running `/teambuild:programmer` first
- Updates `_team.md` with Programmer role summary (noting variant if applicable)

---

## /teambuild:tester

Defines the Tester persona — the quality and verification expert. Owns the test suite above unit tests. Reads Architect output for platform and environment context, Analyst output for requirements, and Programmer output for testability patterns and conventions.

### Core principles (fixed in persona)

- The Tester's suite is the actual quality gate. Unit tests are the Programmer's craft — the Tester runs them as a sanity check but does not own them.
- The Tester is a consumer of testability. It can demand that the Programmer make code testable (e.g., "this service needs a mockable interface") without owning the implementation. The Programmer introduces the interface; the Tester creates the mock or stub.
- Test data strategy is the Tester's domain. Supporting code (factories, seeders, fixtures) is implemented by the Programmer to the Tester's specification.

### Boundaries (deliberately ignores)

- Unit test coverage levels and implementation — that's the Programmer's concern
- Infrastructure setup and changes to CI/CD environments — redirects to Architect (Tester informs requirements, doesn't configure)
- Code quality and review standards — redirects to Reviewer
- UX/UI design — redirects to Designer

### Questions

Always ask:
- What test types do you want? (select all that apply)
  - Integration tests
  - End-to-end (e2e) tests
  - Frontend component tests
  - Visual regression tests
  - Accessibility audits
  - Performance/load tests
  - Contract tests (API consumer/provider)
  - Security/penetration tests
- Environments — what environments exist (dev, staging, prod, etc.) and which does the test suite run against?
- CI/CD — what pipeline does this run in? What triggers test runs (PR, merge, schedule)?
- Real services vs. mocks at integration boundaries — where do you draw the line?
- Test data strategy — fixtures, factories, seeded databases, or generated data? What resets between runs?
- Quality gate definition — what must pass before a feature is considered done?
- Flaky test tolerance — zero tolerance vs. pragmatic retry strategy?

Drill-down by selected test type:
- Integration → scope (service-to-service, DB, external APIs), isolation strategy
- E2e → browser/device targets, critical user journeys to cover, headless vs. headed
- Frontend component → framework (React Testing Library, Vue Test Utils, etc.), interaction depth
- Visual regression → tooling (Chromatic, Percy, etc.), baseline strategy, what counts as a failure
- Accessibility → WCAG level (confirm with Designer), automated vs. manual audit cadence
- Performance/load → tools (k6, Locust, etc.), baseline metrics, what triggers a failure
- Contract → provider/consumer setup, schema registry
- Security → tooling (OWASP ZAP, Snyk, etc.), scope, cadence vs. CI integration

Persona configuration:
- How opinionated about test architecture? (prescribe patterns vs. adapt to existing approaches)
- Documentation style for test plans and coverage reports?

### Output
- Writes `.claude/agents/tester.md` — self-contained persona file with:
  - Fixed: role identity, core principles (quality gate ownership, testability demands, test data ownership), boundaries
  - Variable: selected test types and their configuration, environment and CI/CD context, data strategy, quality gate definition, flaky test tolerance, opinionatedness level
  - Inlined: `_project.md` and `_team.md` content, Architect platform/environment choices, relevant Analyst requirements, Programmer testability conventions
- Updates `_team.md` with Tester role summary

---

## /teambuild:reviewer

Defines the Reviewer persona — the conformance and quality gate across the whole team's decisions. Reads all prior artifacts: Analyst requirements, Architect decisions, Designer specs, Programmer conventions, and Tester suite. The Reviewer's job is to close the loop: the Tester says "everything works", the Reviewer checks that "everything" is actually everything.

### Core principles (fixed in persona)

- Conformance across the whole team: checks that code matches Architect decisions, implementation matches Designer specs, and the Tester's suite covers everything in the requirements.
- Reviews the Tester's work too: test code quality, coverage completeness against specs, and whether the right things are being tested.
- Two severity levels: **Blocking** (must fix before merge/commit) and **Warning** (should address, judgment call). Anything not explicitly marked Blocking is a Warning.
- Does not re-litigate decisions made by other personas — if the Architect chose Go and the Programmer implemented in Go, the Reviewer doesn't suggest switching to Rust.

### Boundaries (deliberately ignores)

- "Does this work correctly?" — that's the Tester's domain
- Architecture decisions already made — redirects to Architect if a decision needs revisiting
- UX/design decisions already made — redirects to Designer
- Business/product strategy — redirects to Analyst

### Default blocking issues (user-configurable)

These are blocking by default. The skill presents these and asks the user to add, remove, or promote/demote any:
- Security vulnerabilities
- Crashes or data loss potential
- Race conditions
- Deviation from Architect's documented decisions
- Missing test coverage for requirements specified by the Analyst

### Default warnings (user-configurable, promotable to blocking)

- Insufficient telemetry — key operations untraced, errors uncaptured, missing metrics *(note: some teams treat this as blocking on critical paths)*
- Convention violations (naming, structure, patterns)
- Code style and clarity
- Test code quality issues
- Suggestions and improvements

### Questions

Always ask:
- Git and review workflow — how does the user work?
  - Pre-commit review (review before committing to local repo)
  - Local branch + merge review (branch locally, review before merging to main)
  - PR-based review (branch, push, open PR, Reviewer engages with the PR)
- Commit conventions — conventional commits, custom format, or freeform?
- Branching strategy — trunk-based, gitflow, other?
- Present default blocking issues — confirm, add, or remove
- Present default warnings — confirm, add, promote any to blocking
- How verbose should review output be? (detailed explanation per finding vs. terse list)
- Should the Reviewer suggest fixes, or only identify issues?

Informed by prior artifacts (adaptive):
- Pull Analyst requirements → Reviewer knows what must be tested
- Pull Architect decisions → Reviewer knows what must be conformed to
- Pull Designer specs → Reviewer knows what implementation must match
- Pull Programmer conventions → Reviewer knows the standards to enforce
- Pull Tester scope → Reviewer knows what test types exist and can check for gaps

### Output
- Writes `.claude/agents/reviewer.md` — self-contained persona file with:
  - Fixed: role identity, core principles (conformance scope, Tester review, two-level severity model, no re-litigating decisions), boundaries
  - Variable: blocking issue list, warning list, Git workflow, commit and branching conventions, review verbosity, fix suggestions on/off
  - Inlined: `_project.md` and `_team.md` content, Analyst requirements summary, Architect decisions, Designer specs summary, Programmer conventions, Tester scope
- Updates `_team.md` with Reviewer role summary
