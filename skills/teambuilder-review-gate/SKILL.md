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

   Goal: produce the diff of code changes made while working on this change.

   a. **Detect the base ref.** Try these in order, and stop at the first that resolves:
      1. `git symbolic-ref --short refs/remotes/origin/HEAD` (returns e.g. `origin/main`)
      2. `origin/main`, then `origin/master` (verify with `git rev-parse --verify <ref>`)
      3. `main`, then `master` (verify with `git rev-parse --verify <ref>`)

      If none resolve, stop and ask the user: "I couldn't detect a base branch automatically. What should I diff against? (e.g., `origin/develop`)"

   b. **Compute the merge base**: `git merge-base HEAD <base-ref>`.

   c. **Produce the diff**: `git diff <merge-base>..HEAD`.

      Also run `git diff HEAD` and `git diff --cached` to capture any uncommitted or staged changes; append them (labelled) if non-empty.

   d. **Handle the "on the base branch" case.** If `<merge-base>` equals `HEAD` (the user is working directly on the base branch), the committed diff is empty. Surface this to the user: "This change appears to be committed directly on the base branch — there is no feature-branch diff. Do you want me to diff the last N commits instead, or abort the review?" Wait for guidance before invoking the Reviewer.

3. **Invoke the Reviewer via the Agent tool**

   Use `subagent_type: "reviewer"` (the persona file at `.claude/agents/reviewer.md` is registered as a subagent by its `name:` frontmatter — Claude Code loads it as the system prompt automatically, no need to tell the subagent to read it). If the Agent tool rejects `"reviewer"` as an unknown subagent type in this environment, fall back to `subagent_type: "general-purpose"` and prepend "Read and adopt the persona defined in `.claude/agents/reviewer.md` before starting." to the prompt.

   Prompt:

   ```
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
