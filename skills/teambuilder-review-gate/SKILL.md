---
name: teambuilder-review-gate
description: Run the Reviewer persona over a completed OpenSpec change before it is archived, and surface non-blocking findings to the user. Use from `/opsx:archive` (or `openspec-archive-change`) when a Teambuilder Reviewer persona is present.
license: MIT
---

Run the Teambuilder Reviewer persona over a completed OpenSpec change and surface findings to the user before archival proceeds. Findings are non-blocking — the user decides whether to pause and address them.

**Input**: The active change name. The caller (typically `/opsx:archive`) invokes this skill before any archival steps run.

**Steps**

1. **Check the Reviewer persona exists**

   Check whether `.claude/agents/reviewer.md` exists.

   If it does not exist:
   - Stop immediately. Do not proceed with archival.
   - Tell the user: "A Reviewer persona is required before archiving. Run `/teambuild:reviewer` to create one, then re-run `/opsx:archive`."
   - Return control to the caller with a halt signal.

2. **Collect the code diff**

   Get a diff of the code changes produced during this change:

   ```bash
   git diff main...HEAD
   ```

   If `main` is not the base branch, use `git log --oneline` to identify the appropriate base.

3. **Invoke the Reviewer via the Agent tool**

   Use `subagent_type: "general-purpose"` with this prompt:

   ```
   Use the Reviewer persona defined in `.claude/agents/reviewer.md`. Read that file before starting.

   You are performing a per-change review at archive time for the change: <change-name>

   Read these change artifacts:
   - Proposal: <absolute path to openspec/changes/<name>/proposal.md>
   - Design: <absolute path to openspec/changes/<name>/design.md>
   - Specs: <absolute path to openspec/changes/<name>/specs/>
   - Tasks: <absolute path to openspec/changes/<name>/tasks.md>

   Code diff:
   <include the full git diff output here>

   Return your findings in two buckets: **Blocking** and **Warning**, using the review standards from your persona file. If you have no findings, return exactly: "No findings."
   ```

   Wait for the Reviewer subagent to return.

4. **Handle the Reviewer's response**

   **If the Reviewer returns "No findings.":**
   - Show "Reviewer: No findings." to the user.
   - Return control to the caller to continue archival automatically.

   **If the Reviewer returns findings:**
   - Display all findings to the user clearly.
   - Use the **AskUserQuestion tool** to ask: "Would you like to proceed with archiving, or pause to address these findings first?" with options: `Proceed with archiving`, `Pause — I'll address findings first`.
   - If the user chooses **Pause**: stop here. Tell the user to re-run `/opsx:archive` after addressing findings. Return a halt signal to the caller.
   - If the user chooses **Proceed**: return control to the caller to continue archival.

**Guardrails**
- Findings are non-blocking by design — the user, not the Reviewer, decides whether to address them before archiving.
- Halt archival if `.claude/agents/reviewer.md` is missing; do not fall back to a generic review.
- Do not embed Reviewer findings into the archive itself — they are surfaced to the user at review time only.
