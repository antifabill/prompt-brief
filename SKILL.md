---
name: prompt-brief
description: Turn a rough user request into an executable agent brief with stronger context, constraints, and output composition. Use when the user asks to improve or engineer a prompt for an AI agent, wants help turning a vague task into a runnable brief, wants guidance gathering missing context or verification criteria, or wants approved briefs logged into a reusable prompt library.
argument-hint: "[rough task]"
user-invocable: true
---

# Prompt Brief

## Overview

Use this skill to turn a rough task into a brief an execution agent can actually succeed with.
The goal is not prettier wording. The goal is a better worker brief: grounded context, explicit constraints, clear verification, and an exact output shape.

This skill is for prompt engineering, not task execution.
When invoked, do not start implementing the user's underlying request, do not start editing project files for that underlying request, and do not treat the rough task as already approved to run.
Your job is to diagnose the request, engineer the brief, surface assumptions or missing pieces, and stop at the approval menu unless the user explicitly chooses an approval option that includes saving or running.

Read [references/shumer-agent-briefing.md](references/shumer-agent-briefing.md) before rewriting the prompt. Read [references/prompt-library-format.md](references/prompt-library-format.md) before saving an approved brief.

## Core Standard

- Treat the input as a rough brief, not as the final prompt.
- Build the final brief around the three C's:
  - `Context`: the real objective, audience, working environment, materials, references, files, and current state.
  - `Constraints`: success criteria, verification, stopping conditions, hard requirements, and forbidden shortcuts.
  - `Composition`: the exact structure of the output the execution agent must return.
- Apply the `intern test`: if a capable intern received this brief, would they know what to read, what to produce, and how to know they are done?
- Prefer `don't finish until` language whenever the task needs verification or completion checks.
- When the user does not naturally provide context, constraints, or composition, translate their rough request into those categories yourself and then ask only for the missing pieces.
- Default to agent-style briefs, not generic chatbot prompt polishing.
- Default to returning a prompt artifact, not doing the task described by the prompt.

## Hard Boundary

- Treat everything after the skill invocation as the rough task to engineer, not as permission to execute that task.
- Even if the user says `use a subagent`, that means a prompt-engineering subagent for the briefing pass unless the user later approves running the engineered brief.
- Do not start building the product, changing the codebase, creating the repo, researching implementation details beyond prompt-grounding needs, or otherwise carrying out the underlying task before approval.
- Your first deliverable is always the structured prompt-brief artifact or a short question round, never the finished work product from the rough task.
- If you notice yourself saying things like `I'm going to implement`, `I'm wiring up`, `I'm creating the repo now`, or `I'll build`, stop and return to the prompt-engineering workflow.

## Workflow

### 1. Ground The Request First

Before drafting questions or rewriting anything:

- Identify the current `cwd`.
- Detect the project root if possible. Prefer the git root; otherwise use the most relevant working directory. If no project root is detectable, treat `cwd` as the project root for local-library purposes.
- Inspect likely relevant files, docs, tests, or configs when a repo or document set exists.
- Capture a compact context snapshot:
  - current objective
  - likely audience or consumer
  - relevant files, paths, URLs, docs, or artifacts
  - current state of the project or workspace
- Classify the task as one of:
  - `coding`
  - `research`
  - `writing`
  - `planning`
  - `other`

Do not dump the full conversation or the full repo into the prompt-engineering pass. Curate the scope.

### 2. Route The Prompt-Engineering Mode

Before choosing local prompt engineering vs subagent prompt engineering, check whether the user already specified a preference in the current invocation or current turn.

If the user already clearly asked for one of these, honor it:

- `current chat`
- `subagent`

Do not reuse an older routing answer from a previous skill run unless the user explicitly says to use the same mode again.

If the user did not specify, ask one short routing question before the rest of the interview:

- `Do you want me to engineer this brief in the current chat, or use a subagent for the prompt-engineering pass?`

When the environment supports `request_user_input`, use it for this routing question.
Otherwise do not call `request_user_input`; ask the same question directly in chat using the Markdown question-card fallback below.

Recommendation rule:

- recommend `subagent` for larger, high-stakes, or multi-step brief-engineering tasks
- recommend `current chat` for smaller or straightforward brief-engineering tasks

If the user chooses `current chat`, do the prompt-engineering pass locally and continue with the rest of this skill.

If the user chooses `subagent`, use the delegation rules below before spawning.

### 3. Launch The Prompt-Engineering Pass

Prefer a dedicated prompt-engineering subagent only when both of these are true:

- the environment supports subagents
- higher-priority instructions allow delegation for this turn, or the user explicitly asks to use a subagent / delegate this step

When those conditions are not both true, run the same workflow locally in the main agent.

If the user wants the prompt-engineering pass to use a subagent in environments with strict delegation rules, they must ask for it explicitly. Example:

- `$prompt-brief use a subagent to engineer this brief: ...`

If you do use a prompt-engineering subagent, prefer:

- model: `gpt-5.4`
- reasoning effort: `high`
- context: only the rough task, the context snapshot, relevant materials, and the briefing rubric from the reference file

Do not claim that a subagent is required when higher-priority instructions forbid spawning one in the current turn.
Do not use the subagent to execute the underlying user task. The subagent's scope is only the prompt-engineering pass.

The prompt-engineering pass must return a structured artifact with these sections:

1. `Diagnostic Summary`
2. `Missing Context / Constraints / Composition`
3. `Next Questions` (0-3 questions max for the next round, using the structured schema below)
4. `Engineered Brief`
5. `Remaining Gaps / Assumptions`
6. `Suggested Title`
7. `Suggested Task Type`

`Next Questions` must be machine-usable so the main agent can relay them consistently.

Use this shape for each question:

```md
- id: `short-stable-id`
  style: `multiple-choice` | `open`
  question: `user-facing question text`
  why_it_matters: `one short sentence about what this unlocks`
  options:
    - label: `Recommended option label`
      description: `one short sentence`
      recommended: `true`
    - label: `Alternative option label`
      description: `one short sentence`
      recommended: `false`
  input_hint: `only for open questions; one short sentence`
```

Rules:

- Use `options` only for `multiple-choice` questions.
- Use `input_hint` only for `open` questions.
- For multiple-choice questions, provide 2-4 mutually exclusive options and mark exactly one as recommended.
- Keep ids stable and concise so the main agent can map returned answers back to the prompt-engineering pass.
- If no question is needed, return `Next Questions: none`.

#### Question UI Rules

Use the best available question surface without changing the rest of the workflow:

- If `request_user_input` is available in the current collaboration mode, use it for routing and interview questions.
- If `request_user_input` is unavailable, do not call it. Render a Markdown fallback that looks like a question card.
- Do not claim that the skill can enter or switch to Plan mode. The skill can adapt to the current mode, but it cannot change the runtime mode.
- Keep fallback question cards concise: one question, recommended option first, alternatives after it, and one-sentence tradeoffs.

Use this Markdown fallback shape:

```md
**Question**
<one concise question>

**Recommended:** <option label>
<one sentence explaining why this is recommended>

**Alternative:** <option label>
<one sentence explaining the tradeoff>
```

### 4. Diagnose Before You Rewrite

Have the prompt-engineering pass evaluate the rough request before producing the final brief:

- What is the actual goal behind the request?
- What materials or references are missing?
- What would cause the execution agent to stop too early or guess?
- What verification is required?
- What output shape is missing?
- Is the user's current wording a vague question, a proposed solution, or a usable worker brief?

If the user included a proposed solution, separate the underlying goal from the proposed approach before you lock the brief.

### 5. Interview In Short Rounds

Ask at most 1-3 questions per round.

- Prefer multiple-choice questions whenever the ambiguity can be expressed cleanly.
- Use open questions only when multiple choice would distort the real decision.
- Ask only questions that materially change the brief.
- Do not ask for facts you can discover by exploring the workspace.
- When the current collaboration mode supports `request_user_input`, use it.
- Otherwise ask concise questions directly in chat using the Markdown question-card fallback.
- For tasks that involve publishing, repo creation, deployment, external sharing, auth-bound actions, or changes outside the local workspace, do not silently default if key ownership or visibility decisions are still unknown. Ask at least one clarification round unless the user explicitly told you to choose defaults.

For publish/distribution tasks, treat these as high-priority questions when unknown:

- owner or org
- visibility
- license preference
- whether "create locally only" is acceptable if publish/auth fails

The main agent owns the user conversation. If a subagent drafts the questions, relay them to the user and send the answers back to the subagent.

Stop the interview when either:

- no critical ambiguity remains about goal, audience, materials, success criteria, verification, or output format, or
- the remaining unknowns can be named explicitly as assumptions in the final brief.

Do not use the second rule to skip decision-critical questions for publishing or external-side-effect tasks. For those tasks, unresolved owner/visibility/license/destination decisions remain critical unless the user explicitly authorized reasonable defaults.

### 6. Write The Engineered Brief

The final brief must always use this structure:

```md
## Context

## Your task

## Constraints

## Verification (don't finish until)

## Output format
```

Requirements for each section:

- `Context`
  - include the real objective, audience, current state, and all relevant files/materials/paths
  - include only context that will help execution
- `Your task`
  - state the job plainly and directly
  - focus on the actual objective, not generic rephrasing
- `Constraints`
  - include hard requirements, scope limits, preferences, compatibility needs, and non-goals
  - prefer concrete constraints over style fluff
- `Verification (don't finish until)`
  - include the explicit stopping condition
  - require checks, tests, source verification, or evidence where appropriate
  - never leave "done" implicit on work that can be verified
- `Output format`
  - specify the exact shape the execution agent should return
  - examples: plan sections, code review findings, summary plus sources, files changed plus verification

### 7. Self-Check Before Returning

Before presenting the engineered brief, verify that:

- all three C's are present
- the brief passes the `intern test`
- at least one real stopping condition exists when the task is verifiable
- the output format is explicit
- unresolved gaps are named instead of silently guessed

### 8. Present The Approval Menu

Return the result to the user as one cohesive prompt-brief card, in this order:

1. `Engineered Brief`
2. `Remaining Gaps / Assumptions`
3. Approval menu:
   1. `Revise`
   2. `Approve and save only`
   3. `Approve, save, and run`

Rules:

- Keep the engineered brief, remaining gaps, and approval menu together in the same visual block. Do not put the brief in one block and the gaps/menu outside it.
- Use a Markdown card-style container when no native card UI is available:

````md
**Prompt Brief Card**

### Engineered Brief

```md
## Context

## Your task

## Constraints

## Verification (don't finish until)

## Output format
```

### Remaining Gaps / Assumptions

- ...

### Approval Menu

1. `Revise`
2. `Approve and save only`
3. `Approve, save, and run`
````

- If the user chooses `Revise`, do not write any prompt-library files yet. Continue the interview/revision loop.
- If the user chooses `Approve and save only`, log the approved brief with `run_mode: not-run`.
- If the user chooses `Approve, save, and run`, ask whether to execute it in the current agent or a fresh execution agent before writing any prompt-library files.
- If the user asks which execution mode to choose, recommend a fresh execution agent.
- Do not skip the approval menu just because the rough task seems clear.
- Do not start executing the engineered brief in the same response where you first present it.

### 9. Save Approved Briefs To The Prompt Library

Only save after explicit approval. Never save drafts, rejected prompts, or revision-only attempts.

Use the format rules in [references/prompt-library-format.md](references/prompt-library-format.md).

On every approved save:

- Write one Markdown file to the workspace-local library:
  - `<project-root>/.codex/prompt-brief-library/`
  - if no project root exists, use `<cwd>/.codex/prompt-brief-library/`
- Write a second Markdown file to the user-global library:
  - `$CODEX_HOME/prompt-brief-library/`
  - if `CODEX_HOME` is unset, use `~/.codex/prompt-brief-library/`
- Use the same `id` for both files.
- Create a new file every time. Never overwrite an earlier prompt file.
- Update `index.md` in both libraries after the files are written.
- Preserve history. The only file you overwrite is `index.md`.
- Before inserting a new index entry, check whether the same `id` is already present. If it is, do not add a duplicate line.

### 10. Run The Approved Brief

If the user chooses to run the approved brief:

- ask for the selected run mode first if it is not already known
- save after the run mode is known so the recorded `status` and `run_mode` are correct on first write
- then execute with the selected run mode
- when using a fresh execution agent, pass the approved engineered brief plus the same curated context bundle you assembled earlier
- when using the current agent, treat the engineered brief as the active task contract

## Notes

- Keep the interview helpful, not academic. The user should feel guided, not examined.
- Translate the user's rough words into a stronger brief. Do not merely lecture them about prompt theory.
- The final artifact is an executable agent brief plus an optional library entry, not a generic writing exercise.
- A successful run of this skill can end with no code changes at all if the user has not yet approved the brief.
- For this skill to be callable as a live skill in a fresh session, the skill must be installed under the active skills directory before the session starts. If it was created or modified mid-session and is not in the active skill list yet, restart Codex or start a new thread/session before judging whether invocation works.
- Explicit invocation should use the real skill name, for example: `$prompt-brief draft a stronger agent brief for refactoring the auth flow`.
- A good explicit invocation for this skill is: `$prompt-brief create an executable brief for: <rough task>`.
