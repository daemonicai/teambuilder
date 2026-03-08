# TBD — Open Questions

## The Actual Questions Each Skill Asks

The opinionated core of teambuilder. For each persona skill, what are the right questions to ask the user? These need to:
- Extract the right information to generate a useful persona
- Be adaptive (ask different follow-ups based on answers)
- Leverage existing artifacts (e.g., Architect skill reads requirements and asks about those specific requirements)
- Balance thoroughness with not being tedious

Needs to be designed per-persona:
- [ ] `/teambuild:init` — what project/org context matters?
- [ ] `/teambuild:analyst` — what shapes a good analyst persona?
- [ ] `/teambuild:architect` — what does this need beyond domain + tech preferences?
- [ ] `/teambuild:designer` — UX vs visual vs both? Platform conventions?
- [ ] `/teambuild:programmer` — conventions, style, patterns, testing philosophy?
- [ ] `/teambuild:tester` — testing strategy, coverage expectations, types of testing?
- [ ] `/teambuild:reviewer` — review standards, what to flag, what to let slide?

## Installation & Configuration

How do users get teambuilder into their Claude Code setup?
- Clone the repo and add to Claude Code's command/skill search paths?
- npm/brew install?
- Copy files into `~/.claude/`?
- What configuration is needed in `.claude/settings.json`?

## Extensibility for Community Personas

How do people contribute new persona types?
- Fork and PR with a new command+skill pair?
- Is there a template or generator for creating a new persona type?
- Any conventions for naming, file structure, etc.?
- How do variant-specific skills work? (e.g., a `programmer-ios` skill that knows iOS-specific questions vs. generic programmer skill with a variant argument)

## Persona Regeneration

When should personas be regenerated?
- When `_project.md` changes?
- When `_team.md` changes (new member added)?
- When upstream artifacts change (new requirements → regenerate architect)?
- What's the UX for this? Prompt? Command? Automatic?

## Persona File Format

What's the exact structure of a generated persona `.md` file?
- How is shared context inlined? Verbatim copy or summarized?
- Are there markers/comments indicating generated sections vs. user-editable sections?
- Can users hand-edit a generated persona without it being overwritten on regeneration?
