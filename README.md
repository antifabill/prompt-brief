# prompt-brief skills

`prompt-brief` is a family of Codex skills inspired by Matt Shumer's article, [The Ultimate Guide to Prompting AI Agents](https://shumer.dev/prompting-ai-agents).

The skills turn rough requests into executable briefs an agent can actually succeed with. They adapt Shumer's core idea that agents should be briefed like workers, not prompted like chatbots, and organize a task around the three C's:

- `Context`: goal, audience, current state, materials, references, and intended use
- `Constraints`: requirements, non-goals, limits, risks, verification, and stopping conditions
- `Composition`: output shape, sections, deliverables, format, and runner/tool payload needs

This repository is an adaptation of those briefing ideas for Codex. It is not an official repository from Matt Shumer and should not be presented as one.

`prompt-brief` also includes an optional GPT-5.5 tuning mode that keeps the same three-C briefing method but compiles the approved brief into a leaner, outcome-first execution payload aligned with OpenAI's [GPT-5.5 prompt guidance](https://developers.openai.com/api/docs/guides/prompt-guidance?model=gpt-5.5).

## Versions

This repo contains three side-by-side versions. They share the same briefing foundation, but differ in how strongly they guide the interview.

| Skill | Best for | Behavior |
| --- | --- | --- |
| `prompt-brief` | Original approval-first brief engineering plus GPT-5.5 tuning | Grounds the request, drafts a structured prompt-brief card, stops for approval before save/run, and supports optional GPT-5.5 tuning with `5.5`. |
| `prompt-brief-2` | More guided clarification | Adds a stronger question gate and prefers multiple-choice clarification when user-owned context is missing. |
| `prompt-brief-3` | Adaptive interview, one question at a time | Evaluates `Context`, `Constraints`, and `Composition` as separate paths, asks exactly one material question per turn, labels multiple-choice answers `A.`, `B.`, `C.`, `D.`, and separates the human brief from runner-specific execution payloads. |

## Repository Layout

```text
.
├── SKILL.md                         # Root copy of prompt-brief v1
├── agents/openai.yaml               # Root UI metadata for v1
├── references/                      # Shared briefing references for v1 root copy
├── scripts/validate-marketplace-layout.ps1
└── skills/
    ├── prompt-brief/                # Installable v1 package
    ├── prompt-brief-2/              # Installable v2 package
    └── prompt-brief-3/              # Installable v3 package
```

The `skills/<name>/` folders are the installable skill packages. The root-level files are kept for the original `prompt-brief` direct-install layout.

## Install

Install one version by copying its folder from `skills/` into your Codex skills directory:

```powershell
git clone https://github.com/antifabill/prompt-brief.git "$env:TEMP\prompt-brief-skills"
Copy-Item "$env:TEMP\prompt-brief-skills\skills\prompt-brief-3" "$HOME\.codex\skills\prompt-brief-3" -Recurse -Force
```

Change `prompt-brief-3` to `prompt-brief` or `prompt-brief-2` to install a different version.

To install all three:

```powershell
git clone https://github.com/antifabill/prompt-brief.git "$env:TEMP\prompt-brief-skills"
Copy-Item "$env:TEMP\prompt-brief-skills\skills\prompt-brief" "$HOME\.codex\skills\prompt-brief" -Recurse -Force
Copy-Item "$env:TEMP\prompt-brief-skills\skills\prompt-brief-2" "$HOME\.codex\skills\prompt-brief-2" -Recurse -Force
Copy-Item "$env:TEMP\prompt-brief-skills\skills\prompt-brief-3" "$HOME\.codex\skills\prompt-brief-3" -Recurse -Force
```

If Codex was already open before installation, start a new session or restart Codex so the new skills are picked up in the active skill list.

## Usage

Invoke the version you want:

```text
$prompt-brief create an executable brief for: refactor the auth flow without breaking the public API
```

```text
$prompt-brief-2 create an executable brief for: research the best way to compare pricing pages for three competitors
```

```text
$prompt-brief-3 create an executable brief for: generate three premium iOS app screens for managing saved X articles
```

Use GPT-5.5 tuning mode in `prompt-brief` by putting `5.5` at the start of the rough task:

```text
$prompt-brief 5.5: create an executable brief for: refactor the auth flow without breaking the public API
```

Supported aliases:

```text
$prompt-brief gpt-5.5: <rough task>
$prompt-brief gpt-5-5: <rough task>
$prompt-brief tune-gpt-5.5: <rough task>
```

Expected shared behavior:

- The skill treats the rough request as a prompt-engineering task, not permission to execute the underlying work.
- It grounds itself in the current workspace when useful.
- It produces an engineered brief with context, constraints, verification, and output format.
- It stops at an approval menu before saving or running the underlying task.

`prompt-brief` GPT-5.5 tuning adds:

- a concise approved-run payload with `Goal`, `Success criteria`, `Context / evidence`, `Constraints`, `Validation / stop rules`, and `Output`
- optional `Preamble`, `Retrieval budget`, and `Personality / collaboration` sections when useful
- leaner wording that preserves the original brief's intent and hard constraints without carrying unnecessary process scaffolding

V3 adds the strongest interview behavior:

- exactly one material question per turn
- multiple distinct paths based on `Context`, `Constraints`, and `Composition`
- multiple-choice options labeled `A.`, `B.`, `C.`, `D.` so the user can answer with one letter
- a `Human Brief` for approval and a separate `Execution Payload` after approval
- a deterministic save helper at `skills/prompt-brief-3/scripts/save-approved-brief.ps1`

## Validation

Run the validation script before pushing changes:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\validate-marketplace-layout.ps1
```

The script checks that:

- `skills/prompt-brief`, `skills/prompt-brief-2`, and `skills/prompt-brief-3` each have a valid `SKILL.md`
- each package includes its `agents/openai.yaml` and briefing references
- the root v1 files match `skills/prompt-brief`
- V3 includes its save helper in the installable package

## Attribution

This repository adapts the briefing ideas from Matt Shumer's article, [The Ultimate Guide to Prompting AI Agents](https://shumer.dev/prompting-ai-agents), published on April 21, 2026, into installable Codex skill workflows.

The optional GPT-5.5 tuning mode is informed by OpenAI's [GPT-5.5 prompt guidance](https://developers.openai.com/api/docs/guides/prompt-guidance?model=gpt-5.5).
