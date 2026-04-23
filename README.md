# prompt-brief

`prompt-brief` is a Codex skill inspired by Matt Shumer's article, [The Ultimate Guide to Prompting AI Agents](https://shumer.dev/prompting-ai-agents).

The skill turns rough requests into executable briefs an agent can actually succeed with. It adapts Shumer's core idea that agents should be briefed like workers, not prompted like chatbots, and packages that approach into an installable Codex skill workflow.

In practice, the skill helps the user tighten:

- context
- constraints
- composition

The result is a brief that tells an execution agent what it is doing, what materials matter, what counts as done, and what shape the answer should come back in.

This repository is an adaptation of those briefing ideas for Codex. It is not an official repository from Matt Shumer and should not be presented as one.

## What This Skill Does

Use `prompt-brief` when you have a task that is still vague, underspecified, or easy for an agent to misinterpret.

The skill is designed to:

- diagnose weak or incomplete prompts
- translate rough requests into actionable agent briefs
- surface missing assumptions, verification gaps, and output-shape problems
- present an approval flow before execution
- optionally save approved briefs into a reusable prompt library

It is intentionally a prompt-engineering skill, not a task-execution shortcut. Its first job is to improve the brief, not to start building the thing.
The skill does not execute the underlying task until you explicitly approve a run option.

## The 3 C's

The skill is built around a simple briefing framework:

- `Context`: the real objective, audience, current environment, files, docs, references, and current state
- `Constraints`: the requirements, limits, verification rules, and stopping conditions that define acceptable work
- `Composition`: the exact structure the execution agent should return

One of the key ideas behind the skill is that agents work better when they are briefed like workers, not chatted with like assistants.

## Repository Contents

This repo includes the complete skill package in two layouts:

- `SKILL.md`
- `agents/openai.yaml`
- `references/shumer-agent-briefing.md`
- `references/prompt-library-format.md`
- `skills/prompt-brief/SKILL.md`
- `skills/prompt-brief/agents/openai.yaml`
- `skills/prompt-brief/references/shumer-agent-briefing.md`
- `skills/prompt-brief/references/prompt-library-format.md`
- `scripts/validate-marketplace-layout.ps1`

The root-level files keep direct local installation simple. The `skills/prompt-brief/` copy satisfies marketplaces that expect a skill collection layout.

## Install

Install the repo directly into your Codex skills directory so the folder name matches the skill name.

### Option 1: Clone from GitHub

```powershell
git clone https://github.com/antifabill/prompt-brief.git "$HOME/.codex/skills/prompt-brief"
```

If your Codex setup uses `CODEX_HOME`, you can install it there instead:

```powershell
git clone https://github.com/antifabill/prompt-brief.git "$env:CODEX_HOME\\skills\\prompt-brief"
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

This shows the minimum required structure for the skill to work. Extra repo files such as `README.md` or `.gitignore` are fine.

## Marketplace Submission

Some marketplaces expect skill submissions to use a skill collection layout. For those submissions, the required skill entrypoint is:

```text
skills/prompt-brief/SKILL.md
```

This repo includes that path so the repository can be submitted as a skill collection artifact. The root-level skill files and the `skills/prompt-brief/` copy should stay in sync.

Before resubmitting, run:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\validate-marketplace-layout.ps1
```

The validation script checks that:

- `skills/prompt-brief/SKILL.md` exists
- the bundled `agents/` and `references/` files exist under `skills/prompt-brief/`
- the marketplace copy matches the root-level skill files
- `SKILL.md` still has valid `prompt-brief` frontmatter

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
- when you approve saving, the workflow writes the approved brief to both a workspace-local prompt library and a user-global prompt library

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

This repository adapts the briefing ideas from Matt Shumer's article, [The Ultimate Guide to Prompting AI Agents](https://shumer.dev/prompting-ai-agents), published on April 21, 2026, into an installable Codex skill workflow.
