# prompt-brief

`prompt-brief` is a Codex skill inspired by Matt Shumer's article, [The Ultimate Guide to Prompting AI Agents](https://shumer.dev/prompting-ai-agents).

It turns rough requests into executable agent briefs through an adaptive, one-question-at-a-time interview. The skill keeps the core briefing idea from the article: agents work better when they are briefed like workers, not casually prompted like chatbots.

It also includes an optional GPT-5.5 tuning mode that keeps the same briefing method but compiles the approved brief into a leaner, outcome-first execution payload aligned with OpenAI's [GPT-5.5 prompt guidance](https://developers.openai.com/api/docs/guides/prompt-guidance?model=gpt-5.5).

## What The Skill Does

`prompt-brief` helps the user tighten three things before execution:

- `Context`: goal, audience, current state, materials, references, task background, and intended use
- `Constraints`: hard requirements, non-goals, scope limits, risks, verification, and stopping conditions
- `Composition`: exact output shape, deliverables, format, sections, and runner/tool payload needs

The skill asks exactly one material question at a time, re-evaluates all three C paths after each answer, and stops at an approval menu before any execution happens.

## Human Brief And Execution Payload

The `Human Brief` is the artifact shown for approval. It is readable and structured:

- `Context`
- `Your task`
- `Constraints`
- `Verification`
- `Output format`

The `Execution Payload` is generated only after approval and is tailored to the selected runner.

When GPT-5.5 tuning mode is active, the execution payload is compiled into a concise model-tuned shape:

- `Goal`
- `Success criteria`
- `Context / evidence`
- `Constraints`
- `Validation / stop rules`
- `Output`
- optional `Preamble`
- optional `Retrieval budget`
- optional `Personality / collaboration`

The mode keeps the original three-C interview, but removes redundant process-heavy wording from the final runner payload.

For example, when running with `imagegen`, the payload should contain only image-generation instructions. Captions, notes, or evaluation text should be handled by the chat agent after generation, not promised as part of the image tool output.

## Repository Layout

This repository contains one canonical skill package:

```text
skills/prompt-brief/
  SKILL.md
  agents/openai.yaml
  references/shumer-agent-briefing.md
  references/prompt-library-format.md
  scripts/save-approved-brief.ps1
  scripts/validate-marketplace-layout.ps1
```

The skill definition lives only under `skills/prompt-brief/`.

## Install

Clone the repository, then copy the packaged skill folder into your Codex skills directory so the final installed path is `prompt-brief`.

### Option 1: Clone and copy

```powershell
git clone <your-github-url> "$HOME\\prompt-brief"
Copy-Item -Recurse -Force "$HOME\\prompt-brief\\skills\\prompt-brief" "$HOME\\.codex\\skills\\prompt-brief"
```

If your Codex setup uses `CODEX_HOME`, install there instead:

```powershell
git clone <your-github-url> "$HOME\\prompt-brief"
Copy-Item -Recurse -Force "$HOME\\prompt-brief\\skills\\prompt-brief" "$env:CODEX_HOME\\skills\\prompt-brief"
```

### Option 2: Copy the packaged folder manually

Copy `skills/prompt-brief/` from this repo so the final installed structure looks like:

```text
~/.codex/skills/prompt-brief/
  SKILL.md
  agents/openai.yaml
  references/shumer-agent-briefing.md
  references/prompt-library-format.md
  scripts/save-approved-brief.ps1
  scripts/validate-marketplace-layout.ps1
```

If Codex was already open before installation, start a new session or restart Codex so the skill is picked up in the active skill list.

## Usage

Invoke the skill directly with a rough task:

```text
$prompt-brief create an executable brief for: refactor the auth flow without breaking the public API
```

Use GPT-5.5 tuning mode by putting `5.5` at the start of the rough task:

```text
$prompt-brief 5.5: create an executable brief for: refactor the auth flow without breaking the public API
```

Supported aliases:

```text
$prompt-brief gpt-5.5: <rough task>
$prompt-brief gpt-5-5: <rough task>
$prompt-brief tune-gpt-5.5: <rough task>
```

Another example:

```text
$prompt-brief create an executable brief for: image creation task - a premium UI for an iOS app that manages saved X articles
```

Expected behavior:

- The skill grounds itself in the current workspace first.
- It routes the prompt-engineering pass to current chat or subagent if needed.
- It asks one material guiding question at a time.
- It prefers multiple-choice questions when choices can guide the user cleanly.
- It checks `Context`, `Constraints`, and `Composition` before finalizing.
- It returns one prompt-brief card with a human brief, remaining assumptions, a three-C check, and approval menu.
- After approval, it saves with the helper and builds a runner-specific execution payload.
- In GPT-5.5 tuning mode, it compiles a concise GPT-5.5 tuned execution payload after approval.

## Good Fit

This skill is especially useful for:

- coding tasks that need concrete verification
- research tasks that need sources and output shape
- writing tasks where audience and materials matter
- image or design tasks where the run payload must match the selected tool
- planning tasks where "done" is otherwise fuzzy

## Attribution

This repository adapts the briefing ideas from Matt Shumer's article, [The Ultimate Guide to Prompting AI Agents](https://shumer.dev/prompting-ai-agents), published on April 21, 2026, into an installable Codex skill workflow.

The optional GPT-5.5 tuning mode is informed by OpenAI's [GPT-5.5 prompt guidance](https://developers.openai.com/api/docs/guides/prompt-guidance?model=gpt-5.5).
