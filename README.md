# prompt-brief

`prompt-brief` is a Codex skill for turning rough requests into executable briefs an agent can actually succeed with.

Instead of treating prompting like chatbot phrasing, the skill reframes the task as worker briefing. It helps the user tighten:

- context
- constraints
- composition

The result is a brief that tells an execution agent what it is doing, what materials matter, what counts as done, and what shape the answer should come back in.

## What This Skill Does

Use `prompt-brief` when you have a task that is still vague, underspecified, or easy for an agent to misinterpret.

The skill is designed to:

- diagnose weak or incomplete prompts
- translate rough requests into actionable agent briefs
- surface missing assumptions, verification gaps, and output-shape problems
- present an approval flow before execution
- optionally save approved briefs into a reusable prompt library

It is intentionally a prompt-engineering skill, not a task-execution shortcut. Its first job is to improve the brief, not to start building the thing.

## The 3 C's

The skill is built around a simple briefing framework:

- `Context`: the real objective, audience, current environment, files, docs, references, and current state
- `Constraints`: the requirements, limits, verification rules, and stopping conditions that define acceptable work
- `Composition`: the exact structure the execution agent should return

One of the key ideas behind the skill is that agents work better when they are briefed like workers, not chatted with like assistants.

## Repository Contents

This repo includes the complete skill package:

- `SKILL.md`
- `agents/openai.yaml`
- `references/shumer-agent-briefing.md`
- `references/prompt-library-format.md`

## Install

Install the repo directly into your Codex skills directory so the folder name matches the skill name.

### Option 1: Clone from GitHub

Replace `<your-github-url>` with the final repo URL:

```powershell
git clone <your-github-url> "$HOME/.codex/skills/prompt-brief"
```

If your Codex setup uses `CODEX_HOME`, you can install it there instead:

```powershell
git clone <your-github-url> "$env:CODEX_HOME\\skills\\prompt-brief"
```

### Option 2: Copy the Folder Manually

Copy this repo so the final structure looks like:

```text
~/.codex/skills/prompt-brief/
  SKILL.md
  agents/openai.yaml
  references/shumer-agent-briefing.md
  references/prompt-library-format.md
```

## After Installing

If Codex was already open before installation, start a new session or restart Codex so the newly installed skill is picked up in the active skill list.

## Usage

Invoke the skill directly with a rough task:

```text
$prompt-brief create an executable brief for: refactor the auth flow without breaking the public API
```

Another example:

```text
$prompt-brief create an executable brief for: research the best way to compare pricing pages for three competitors
```

Expected behavior:

- the skill inspects the current context first
- it asks whether to do the prompt-engineering pass in the current chat or via a subagent when that preference was not already specified
- it diagnoses what is missing
- it returns an engineered brief
- it lists remaining assumptions or gaps
- it shows an approval menu before any execution happens

If you specifically want the prompt-engineering pass to use a subagent in environments that require explicit delegation, say so directly:

```text
$prompt-brief use a subagent to engineer this brief: create a GitHub repo for the prompt-brief skill
```

## Good Fit

This skill is especially useful for:

- coding tasks that need real verification
- research tasks that need sources and explicit output shape
- writing tasks where audience, tone, and source materials matter
- planning tasks where "done" is otherwise fuzzy

## Attribution

This skill package is inspired by Matt Shumer's article, [The Ultimate Guide to Prompting AI Agents](https://shumer.dev/prompting-ai-agents), published on April 21, 2026.

The repo adapts those briefing ideas into an installable Codex skill workflow. It is not an official repository from Matt Shumer and should not be presented as one.
