Set up teambuilder project context for the current project.

## What you do

You are running the `/teambuild:init` setup flow. Your job is to gather basic project context and write two files to `.claude/agents/`.

## Step 1: Check for existing context

Check whether `.claude/agents/_project.md` already exists.

- If it exists, tell the user a project context already exists and ask: **overwrite it or cancel?**
- If they choose cancel, stop here.
- If it doesn't exist (or they choose to overwrite), continue.

## Step 2: Create the agents directory

Create `.claude/agents/` if it doesn't already exist.

## Step 3: Ask these questions

Ask the following questions **one at a time**, waiting for each answer before continuing:

1. **What's the project name?**
2. **What organization or team is this for?** (Can be personal/solo if applicable)
3. **What industry or domain is this in?** (e.g., fintech, healthcare, e-commerce, internal tooling, game development)
4. **What stage is the project at?**
   - New (greenfield)
   - Existing (active development)
   - Legacy (maintenance/migration)

## Step 4: Write `_project.md`

Write `.claude/agents/_project.md` with this content (fill in the answers):

```
# Project: [project name]

**Organization:** [org/team]
**Domain:** [industry/domain]
**Stage:** [stage]
```

## Step 5: Write `_team.md`

Write `.claude/agents/_team.md` with this content:

```
# Team

*No personas created yet.*
```

## Step 6: Confirm and prompt

Tell the user:

> Project context saved to `.claude/agents/`. Your team roster is ready.
>
> Next step: run `/teambuild:analyst` to build your first persona.
