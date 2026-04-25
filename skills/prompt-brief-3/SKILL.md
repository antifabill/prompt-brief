---
name: prompt-brief-3
description: "Turn a rough user request into an executable agent brief using an adaptive one-question-at-a-time interview across the three C's: Context, Constraints, and Composition. Use when the user asks to improve or engineer a prompt for an AI agent, wants guided multiple-choice clarification, wants a runnable brief with approval gates, or wants approved briefs saved without affecting earlier prompt-brief variants."
argument-hint: "[rough task]"
user-invocable: true
---

# Prompt Brief 3

## Overview

Use this skill to turn a rough task into an executable worker brief. The goal is not prettier wording. The goal is a stronger agent brief with the right context, constraints, verification, and output shape.

This skill is for prompt engineering, not task execution. Do not start the underlying task, edit project files for the underlying task, or treat the rough request as approved to run. Stop at the approval menu unless the user explicitly chooses an approval option that includes saving or running.

Read [references/shumer-agent-briefing.md](references/shumer-agent-briefing.md) before rewriting the prompt. Read [references/prompt-library-format.md](references/prompt-library-format.md) before saving an approved brief. Use [scripts/save-approved-brief.ps1](scripts/save-approved-brief.ps1) for approved saves.

## Core Standard

- Treat everything after invocation as a rough brief to engineer.
- Build the final brief around the three C's:
  - `Context`: objective, audience, current state, working environment, materials, references, and intended use.
  - `Constraints`: hard requirements, non-goals, limits, preferences, risks, verification, and stopping conditions.
  - `Composition`: exact output shape, sections, deliverables, format, and runner/tool payload needs.
- Ask exactly one material question at a time.
- Prefer multiple-choice questions with options labeled `A.`, `B.`, `C.`, `D.` so the user can answer with only a letter. Use open questions only when choices would distort the real decision.
- After each answer, re-evaluate all three C paths before choosing the next question.
- Return the final prompt card only when `Context`, `Constraints`, and `Composition` are each complete, discoverable, or safely assumable.
- Apply the intern test: a capable worker should know what to read, what to do, what to avoid, how to verify success, and what to return.

## Hard Boundary

- Do not execute the underlying task before approval.
- If the user says `use a subagent`, that means a prompt-engineering subagent for the briefing pass unless the user later approves running the engineered brief.
- Your first deliverable is a routing question, a single guiding question, or the prompt-brief card. It is never the finished work product from the rough task.
- If you notice yourself starting implementation, stop and return to the prompt-engineering workflow.

## Workflow

### 1. Ground The Request

Before asking interview questions or drafting the brief:

- Identify the current `cwd`.
- Detect the project root if possible. Prefer the git root; otherwise use the most relevant working directory.
- Inspect likely relevant files, docs, tests, configs, or artifacts when they exist.
- Capture a compact context snapshot:
  - objective
  - likely audience or consumer
  - relevant files, paths, URLs, docs, data, or artifacts
  - current workspace state
- Classify the task as `coding`, `research`, `writing`, `planning`, or `other`.

Do not ask the user for facts you can discover from the workspace.

### 2. Route The Prompt-Engineering Mode

If the user already requested `current chat` or `subagent` in the current turn, honor that. Do not reuse a routing answer from an older skill run unless the user explicitly says to do so.

If the user did not specify, ask exactly one routing question before the interview:

`Do you want me to engineer this brief in the current chat, or use a subagent for the prompt-engineering pass?`

Use `request_user_input` when it is available. Otherwise use the Markdown fallback question card. Recommend `current chat` for focused tasks and `subagent` for larger, high-stakes, or multi-step prompt-engineering tasks.

### 3. Multi-Path Interview

Evaluate the rough request across the three C paths before every question:

- `Context`: goal, audience, current state, materials, references, task background, intended use.
- `Constraints`: hard requirements, non-goals, scope limits, preferences, risks, verification, stopping conditions.
- `Composition`: output shape, sections, format, deliverables, runner/tool payload, save/run needs.

Optional extra paths may be useful, such as `Runner / Tool`, `Save / Run`, `Style / Tone`, or `External Ownership`, but they must map back to one of the three C's rather than replace them.

For each path, classify the remaining gaps as:

- `complete`: enough information is already present.
- `discoverable`: Codex can inspect local files, docs, or workspace state.
- `assumable`: low-risk and can be named explicitly as an assumption.
- `user-owned/material`: depends on user preference, priority, audience, scope, approval, ownership, output expectations, or another decision that materially changes the brief.

Question rule:

- If any three-C path has a `user-owned/material` gap, ask exactly one question from the highest-impact path.
- After the user answers, re-evaluate all three C paths, not only the path just answered.
- When one path is complete, check whether another path still has a material gap.
- Only return `Next Questions: none` when all three C paths are complete, discoverable, or assumable. Include one sentence explaining why no more user input is needed.

### 4. Ask One Guided Question

Ask exactly one material question per turn.

Prefer this Markdown fallback shape when native question UI is unavailable:

```md
**Question**
<one concise question>

**Recommended:** A. <option label>
<one sentence explaining why this is recommended>

**Alternative:** B. <option label>
<one sentence explaining the tradeoff>
```

For multiple-choice questions:

- Provide 2-4 mutually exclusive options.
- Label every option with a leading letter and period: `A.`, `B.`, `C.`, `D.`.
- Tell the user they can answer with the letter only.
- Mark or present exactly one recommended option.
- Make the options useful, not filler.

Use open questions only when multiple-choice would hide the real answer.

### 5. Diagnose Before Drafting

Before producing the prompt card, evaluate:

- What is the real objective?
- What is the user likely trying to avoid?
- Which context, constraints, or composition gaps remain?
- What verification is required?
- What would cause the execution agent to guess or stop too early?
- Is the user asking a question, proposing a solution, or already giving a usable worker brief?

### 6. Write The Human Brief

The approved human-readable brief must use this structure:

```md
## Context

## Your task

## Constraints

## Verification (don't finish until)

## Output format
```

Requirements:

- `Context`: include only execution-useful objective, audience, current state, files/materials, and assumptions.
- `Your task`: state the job plainly.
- `Constraints`: include hard requirements, non-goals, compatibility needs, preferences, and forbidden shortcuts.
- `Verification (don't finish until)`: include concrete stopping conditions.
- `Output format`: specify the exact returned artifact shape for the execution agent.

### 7. Separate Execution Payloads

The `Human Brief` is what the user reviews and approves. The `Execution Payload` is generated only after approval and must be tailored to the chosen runner.

Runner rules:

- `current-agent` or `fresh-agent`: pass the approved human brief plus the curated context snapshot.
- `imagegen`: create an image-only payload. Do not promise captions, design notes, text analysis, or evaluation as part of the image tool output. If those are needed, the chat agent should provide them after generation.
- If the user requests a specific image model and the available tool does not expose a model selector, say so before generation and run with the available image tool surface.
- `not-run`: save the approved brief only.

### 8. Present The Prompt Brief Card

Return one cohesive card:

````md
**Prompt Brief Card**

### Human Brief

```md
## Context

## Your task

## Constraints

## Verification (don't finish until)

## Output format
```

### Remaining Gaps / Assumptions

- ...

### Three-C Check

- `Context`: ...
- `Constraints`: ...
- `Composition`: ...

### Approval Menu

1. `Revise`
2. `Approve and save only`
3. `Approve, save, and run`
````

Do not save or run in the same response where the card is first presented.

### 9. Save Approved Briefs

Only save after explicit approval. Never save drafts, rejected prompts, or revision-only attempts.

Use `scripts/save-approved-brief.ps1` for approved saves instead of manually patching prompt-library files. The helper writes the workspace-local and user-global prompt files, creates missing indexes, inserts newest entries by stable headings, and skips duplicate ids.

Recommended command shape:

```powershell
powershell -ExecutionPolicy Bypass -File <skill-folder>\scripts\save-approved-brief.ps1 `
  -Title "<title>" `
  -OriginalRoughPrompt "<rough prompt>" `
  -EngineeredBriefPath "<temp or saved brief markdown>" `
  -ContextSnapshot "<compact context>" `
  -TaskType "<coding|research|writing|planning|other>" `
  -Status "<approved-save-only|approved-save-and-run>" `
  -RunMode "<not-run|current-agent|fresh-agent>" `
  -ProjectRoot "<absolute path or empty string>" `
  -Cwd "<absolute path>"
```

If a required value is too long for command-line quoting, write that value to a temporary file and use the corresponding `*Path` parameter.

### 10. Run After Approval

If the user chooses `Approve, save, and run`:

- Determine the run mode if it was not already specified.
- Save first using the helper, so the approval record is durable.
- Build the runner-specific execution payload.
- Execute only what the selected runner can actually return.

## Notes

- Keep the interview helpful and quick, not academic.
- A successful run of this skill can end with no code changes if the user has not approved saving or running.
- For this skill to be callable as a live skill, install it under the active skills directory before starting the session; a new thread or restart may be needed after installation.
- Explicit invocation should use the real skill name, for example: `$prompt-brief-3 create an executable brief for: <rough task>`.
