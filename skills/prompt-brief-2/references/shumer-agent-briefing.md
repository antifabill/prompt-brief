# Agent Briefing Rules

Use this reference to convert a rough prompt into a stronger brief for an execution agent.

## Core Idea

Do not prompt the agent like a chatbot you are casually asking for help.
Prompt it like a worker who needs a brief.

The brief must answer:

- what is the real objective?
- what context and materials does the agent need?
- what constraints define acceptable work?
- what proves the task is finished?
- what exact output shape should be returned?

## The Three C's

### 1. Context

Context is the environment the agent needs in order to work well.

Include:

- the real goal behind the request
- who the output is for
- current project/workspace state
- relevant files, docs, URLs, data, tests, tickets, or examples
- any assumptions that are already safe to make

Weak context looks like:

- "make this better"
- "research this"
- "fix the bug"

Strong context looks like:

- what system you are in
- where the relevant materials are
- what currently exists
- what outcome matters most

## 2. Constraints

Constraints are not decorative style notes. They define what counts as acceptable work.

Strong constraints include:

- success criteria
- verification steps
- stopping conditions
- compatibility requirements
- limits, non-goals, or forbidden shortcuts
- required evidence or tests

The highest-leverage pattern is explicit completion language:

- `Don't finish until ...`

Use it whenever the work can be verified.

Examples:

- coding: do not finish until the tests relevant to the change pass, or explain exactly what blocked them
- research: do not finish until sources are cited and conflicting evidence is noted
- writing: do not finish until the draft is revised for tone, structure, and factual consistency

## 3. Composition

Composition is the shape of the answer you want back.

It affects how the agent thinks while solving the task.

Do not leave the output shape implied when it matters.

Examples:

- "Return findings first, ordered by severity, then open questions, then a short summary."
- "Return a plan with Summary, Key Changes, Test Plan, and Assumptions."
- "Return the final email, then a short list of claims that need fact-checking."

## The Intern Test

Ask:

If a capable intern got this brief with the same materials, would they know:

- what to read
- what to do
- what to avoid
- how to verify success
- what format to return

If not, the brief is still underspecified.

## Bad To Better Patterns

### Coding

Weak:

- "Refactor this component"

Better:

- identify the component and relevant files
- explain the goal of the refactor
- name constraints such as API compatibility or styling invariants
- require verification
- define the return format

### Research

Weak:

- "Research the best approach for auth"

Better:

- define the decision to be made
- specify the app/team context
- require current and authoritative sources
- ask for tradeoffs, recommendation, and risks
- define the evidence format

### Writing

Weak:

- "Write a launch email"

Better:

- state the audience and product context
- list the facts or references that must be used
- define tone and length constraints
- require a final polish/review pass
- ask for a specific output shape

### Planning

Weak:

- "Make a plan for this feature"

Better:

- state the feature goal and current product state
- include known constraints and out-of-scope items
- require decision-complete implementation detail
- specify sections such as summary, implementation changes, tests, assumptions

## Practical Rewrite Checklist

Before returning an engineered brief, confirm:

- the actual objective is stated clearly
- the brief includes the right materials and references
- the most important constraints are explicit
- the `don't finish until` condition is concrete
- the output format is explicit
- remaining gaps are surfaced as assumptions instead of hidden guesses
