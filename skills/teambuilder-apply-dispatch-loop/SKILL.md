---
name: teambuilder-apply-dispatch-loop
description: Dispatch pending tasks from an OpenSpec change's tasks.md to the right Teambuilder persona in fresh subagents. Use from `/opsx:apply` (or `openspec-apply-change`) when Teambuilder personas are present in `.claude/agents/`.
license: MIT
---

Dispatch pending tasks from an OpenSpec change's `tasks.md` to the right Teambuilder persona (Designer, Programmer, or Tester) in a fresh subagent per task.

**Input**: The active change name. The caller (typically `/opsx:apply`) has already selected the change, read context files, and shown current progress — this skill only runs the dispatch loop itself.

**Steps**

1. **Enumerate pending tasks and available personas**

   Read `openspec/changes/<name>/tasks.md` and collect every `- [ ]` checklist item in source order, along with the section heading it appears under. Preserve the exact task text.

   List `.claude/agents/programmer-*.md` and extract the variant suffix from each filename (e.g., `programmer-ios.md` → `ios`). Hold this list for the classification step. If no variant files exist, the list is empty.

   If there are no pending tasks, exit immediately with a "Nothing to do" message and return control to the caller.

2. **For each pending task in source order:**

   a. **Classify by section heading:**
      - Heading matching `/design|ux|ui/i` → **Designer** (`.claude/agents/designer.md`)
      - Heading matching `/test/i` → **Tester** (`.claude/agents/tester.md`)
      - All other headings, or no heading → **Programmer**. Pick the variant:
        - Check the heading (case-insensitive) for any variant suffix from step 1 as a whole-word substring.
        - If exactly one variant matches → use `.claude/agents/programmer-<variant>.md`.
        - If zero or more than one variant matches → use `.claude/agents/programmer.md`.

      The Architect is expected to structure `tasks.md` headings to match available personas (see `/teambuild:architect`). If a heading is ambiguous, the fallback to base `programmer.md` is intentional — do not guess.

   b. **Check the persona file exists** at `.claude/agents/<persona>.md`. If it does not:
      - Halt the loop immediately.
      - Tell the user: "Task N requires the [Persona] persona, but `.claude/agents/<persona>.md` does not exist. Run `/teambuild:<persona>` to create it, then re-run `/opsx:apply`."
      - Stop here.

   c. **Dispatch via the Agent tool** using the persona's name as `subagent_type`. Each persona file in `.claude/agents/` registers a subagent type via its `name:` frontmatter (`designer`, `tester`, `programmer`, `programmer-<variant>`), so Claude Code loads the persona file as the subagent's system prompt automatically — no read-and-adopt step needed.

      - Designer task: `subagent_type: "designer"`
      - Tester task: `subagent_type: "tester"`
      - Programmer task: `subagent_type: "programmer"` or `subagent_type: "programmer-<variant>"` per step 2a.

      If the Agent tool rejects the persona name as an unknown subagent type in the current environment, fall back to `subagent_type: "general-purpose"` and prepend a line to the prompt: "Read and adopt the persona defined in `.claude/agents/<persona>.md` before starting."

      Pass the task text verbatim and file-path pointers only — do NOT embed file contents:

      ```
      Your task:
      <task text verbatim from tasks.md>

      Change artifacts (read these files for context):
      - Proposal: <absolute path to proposal.md>
      - Design: <absolute path to design.md>
      - Specs: <absolute path to specs/ directory>
      - Tasks: <absolute path to tasks.md>

      When you have completed the task:
      1. Self-verify: confirm the implementation is correct, tests pass (if applicable), and the task claim holds.
      2. Mark the task complete in tasks.md by changing its `- [ ]` to `- [x]`.
      3. Return a brief summary of what you did.

      If you cannot complete the task, leave the checkbox unchanged and explain why.
      ```

   d. **Verify completion**: After the subagent returns, re-read `tasks.md` and confirm the dispatched task is now `- [x]`. If it is still `- [ ]`:
      - Halt the loop immediately.
      - Surface the subagent's final message to the user.
      - Tell the user which task stalled and wait for guidance.
      - Do not advance to the next task.

   e. Show progress: "✓ Task N complete" and continue to the next task.

3. **On completion, emit a summary** listing tasks completed this session and overall progress. If all tasks are now done, suggest `/opsx:archive`.

**Guardrails**
- Pass task text verbatim to dispatched subagents — do not paraphrase.
- Pass file paths as pointers only — never embed artifact contents in the dispatch prompt.
- Halt immediately if a persona file is missing; do not skip to a fallback persona.
- Halt immediately if a subagent returns without marking its task complete; surface the message.
- Tasks are dispatched sequentially (not in parallel) — OpenSpec task ordering is intentional.
- Inline persona invocation ("use the programmer") remains available for off-workflow ad-hoc work; this dispatch loop is for orchestrated changes only.
