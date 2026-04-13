## ADDED Requirements

### Requirement: `/opsx:apply` dispatches pending tasks to implementer personas

`/opsx:apply` SHALL read `tasks.md` for the active change, enumerate pending tasks (unchecked checklist items), and dispatch each to an implementer persona (Designer, Programmer, or Tester) in sequence. Completed tasks MUST be skipped.

#### Scenario: `tasks.md` contains a mix of pending and completed tasks

- **WHEN** `/opsx:apply` runs against a change whose `tasks.md` has some `- [x]` completed tasks and some `- [ ]` pending tasks
- **THEN** only the pending tasks are dispatched
- **AND** completed tasks are not re-dispatched

#### Scenario: `tasks.md` contains no pending tasks

- **WHEN** `/opsx:apply` runs against a change whose `tasks.md` has no unchecked tasks
- **THEN** the skill exits immediately with a message indicating there is nothing to do

### Requirement: Tasks are classified by `tasks.md` section heading

`/opsx:apply` SHALL classify each pending task by the section heading it lives under in `tasks.md`. Headings matching `/design|ux|ui/i` route to the Designer. Headings matching `/test/i` route to the Tester. All other headings (and unheadered tasks) route to the Programmer.

#### Scenario: Task lives under a Design heading

- **WHEN** `/opsx:apply` encounters a pending task under a heading matching `/design|ux|ui/i`
- **THEN** the task is dispatched to the Designer persona

#### Scenario: Task lives under a Testing heading

- **WHEN** `/opsx:apply` encounters a pending task under a heading matching `/test/i`
- **THEN** the task is dispatched to the Tester persona

#### Scenario: Task lives under an Implementation heading or has no heading

- **WHEN** `/opsx:apply` encounters a pending task under a heading that matches neither the Designer nor Tester patterns, or has no heading
- **THEN** the task is dispatched to the Programmer persona

#### Scenario: Persona needed for a task does not exist

- **WHEN** `/opsx:apply` classifies a task to a persona whose file is missing from `.claude/agents/`
- **THEN** the skill stops the loop and informs the user which persona is missing and which `/teambuild:<persona>` skill to run

### Requirement: Each task is dispatched in a fresh subagent

`/opsx:apply` SHALL dispatch each pending task by invoking the Agent tool with the matching persona, such that the subagent runs in a fresh context with no inherited session history. The dispatch prompt MUST contain the task text verbatim and file-path pointers to `proposal.md`, `design.md`, and the spec files relevant to the task's capability. It MUST NOT embed the full content of those files inline.

#### Scenario: Subagent prompt construction

- **WHEN** `/opsx:apply` dispatches a task
- **THEN** the prompt passed to the Agent tool contains the pending task's text verbatim
- **AND** the prompt lists the absolute paths of `proposal.md` and `design.md` for the active change
- **AND** the prompt lists the absolute paths of spec files under the active change's `specs/` directory
- **AND** the prompt does not include the file contents of those artifacts

### Requirement: Implementer personas self-verify and mark tasks complete

Dispatched implementer personas SHALL self-verify their work (tests pass, conventions met, task claim holds) and MUST mark the task complete in `tasks.md` by changing `- [ ]` to `- [x]` before returning.

#### Scenario: Implementer completes a task successfully

- **WHEN** a dispatched persona finishes its work and is satisfied with its self-verification
- **THEN** it updates the corresponding line in `tasks.md` from `- [ ]` to `- [x]`
- **AND** it returns a short summary to the controller

#### Scenario: Implementer cannot complete a task

- **WHEN** a dispatched persona encounters an error or cannot finish the task
- **THEN** it leaves the `- [ ]` checkbox unchanged
- **AND** it returns a message describing why the task could not be completed

### Requirement: Controller halts on incomplete task

`/opsx:apply` SHALL verify after each dispatch that the expected task is now marked complete in `tasks.md`. If it is not, the controller MUST stop the loop, surface the subagent's final message to the user, and not advance to the next task.

#### Scenario: Subagent returns without marking the task complete

- **WHEN** a dispatched subagent returns and the corresponding task in `tasks.md` is still `- [ ]`
- **THEN** `/opsx:apply` stops the dispatch loop
- **AND** it shows the user the subagent's final message so they can decide how to proceed

### Requirement: Inline persona invocation remains supported

Users SHALL be able to invoke any persona directly by name (e.g., "use the programmer") outside the orchestrated `/opsx:apply` path. The orchestrated dispatch loop MUST NOT disable or interfere with inline invocation.

#### Scenario: User invokes a persona inline for ad-hoc work

- **WHEN** a user types "use the programmer" in a Claude Code session, outside any opsx command
- **THEN** Claude Code invokes the Programmer persona as normal
- **AND** the invocation succeeds regardless of whether an OpenSpec change is currently active
