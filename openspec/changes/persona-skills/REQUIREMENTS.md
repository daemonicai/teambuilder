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
