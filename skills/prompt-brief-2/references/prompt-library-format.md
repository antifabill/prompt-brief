# Prompt Library Format

Use this reference when the user explicitly approves an engineered brief for saving.

## Save Gate

Do not write library files unless the user chose:

- `Approve and save only`
- `Approve, save, and run`

Do not save:

- drafts
- rejected prompts
- revision-only iterations

## Library Paths

### Workspace-local library

Prefer:

- `<project-root>/.codex/prompt-brief-library/`

Fallback:

- `<cwd>/.codex/prompt-brief-library/`

### User-global library

Prefer:

- `$CODEX_HOME/prompt-brief-library/`

Fallback:

- `~/.codex/prompt-brief-library/`

Create the directory if it does not exist.

## File Naming

Filename format:

- `YYYY-MM-DD_HHMMSS_<slug>.md`

Rules:

- use local machine time
- create a fresh filename for every approved save
- never overwrite an older prompt file
- use the same timestamped `id` for the local and global copies

### `id` format

Use:

- `YYYYMMDD-HHMMSS-<slug>`

### `slug` rules

- lowercase ASCII only
- replace non-alphanumeric sequences with `-`
- trim leading and trailing `-`
- keep it concise and human-readable
- derive it from the approved title

## Task Type

Classify the prompt as one of:

- `coding`
- `research`
- `writing`
- `planning`
- `other`

Use `other` only when none of the main categories fit.

## Status And Run Mode

Use these values:

- `status: approved-save-only` with `run_mode: not-run`
- `status: approved-save-and-run` with `run_mode: current-agent`
- `status: approved-save-and-run` with `run_mode: fresh-agent`

## Prompt File Template

Use this exact section order.

```md
---
id: "<id>"
title: "<title>"
created_at: "<ISO-8601 timestamp with offset>"
task_type: "<coding|research|writing|planning|other>"
status: "<approved-save-only|approved-save-and-run>"
project_root: "<absolute path or empty string>"
cwd: "<absolute path>"
run_mode: "<not-run|current-agent|fresh-agent>"
source_library: "<workspace-local|user-global>"
---

# <title>

## Original Rough Prompt

<the user's rough task>

## Engineered Brief

<approved engineered brief>

## Context Snapshot

<compact summary of the environment and relevant situation>

## Relevant Paths / Materials

- `<path or resource 1>`
- `<path or resource 2>`

## Assumptions / Gaps

- <item>
- <item>

## Approval / Execution Decision

- Approval choice: `<Approve and save only|Approve, save, and run>`
- Run mode: `<not-run|current-agent|fresh-agent>`
- Recommended mode at approval time: `<fresh-agent|current-agent|not-applicable>`
```

The two saved copies should be identical except for `source_library`.

## Index Rules

Each library keeps its own `index.md`.

If `index.md` does not exist, create it with this structure:

```md
# Prompt Brief Library

## Recent Entries

## By Task Type

### Coding

### Research

### Writing

### Planning

### Other
```

### Recent entry format

Use one bullet per saved prompt. Insert newest entries at the top of `## Recent Entries`.

Before writing any index entry, derive an escaped single-line title for index use:

- collapse `\r` and `\n` into spaces
- trim leading and trailing whitespace
- escape backslash as `\\`
- escape `[` as `\[`
- escape `]` as `\]`
- escape `|` as `\|`

Use this escaped single-line value anywhere the title appears inside `index.md`.

For the workspace-local index:

```md
- `<created_at>` | `<task_type>` | `<status>` | [<escaped title>](./<filename>) | `<workspace label>`
```

For the user-global index:

```md
- `<created_at>` | `<task_type>` | `<status>` | [<escaped title>](./<filename>) | `<workspace label>` | `<source workspace path>`
```

### Task-type entry format

Insert the same prompt under the matching task-type heading, newest first.

Workspace-local:

```md
- `<created_at>` | `<status>` | [<escaped title>](./<filename>)
```

User-global:

```md
- `<created_at>` | `<status>` | [<escaped title>](./<filename>) | `<source workspace path>`
```

### Idempotency

Before inserting a recent-entry line or a task-type line, check whether the same `id` is already represented in `index.md`.

Use the `id` in an HTML comment at the end of each bullet so duplicate detection is reliable:

```md
- `...entry contents...` <!-- prompt-brief:id=<id> -->
```

If the `id` is already present, do not add a duplicate line.

## Workspace Label

Use the project root folder name when available.
Otherwise use the `cwd` folder name.

## Example Recent Entries

```md
- `2026-04-22T15:41:00+03:00` | `coding` | `approved-save-and-run` | [Refactor dashboard filters](./2026-04-22_154100_refactor-dashboard-filters.md) | `analytics-app` <!-- prompt-brief:id=20260422-154100-refactor-dashboard-filters -->
- `2026-04-22T14:08:00+03:00` | `research` | `approved-save-only` | [Compare RAG chunking strategies](./2026-04-22_140800_compare-rag-chunking-strategies.md) | `notebook-lab` <!-- prompt-brief:id=20260422-140800-compare-rag-chunking-strategies -->
```
