---
name: dream-memory-consolidation
description: Consolidate workspace memory by merging recent signal into durable context, resolving contradictions, and pruning stale references.
---

# Dream Memory Consolidation

Use this skill when workspace memory is getting noisy, stale, contradictory, or too bulky.

This is the OpenClaw-native version of a "dream" pass: a periodic consolidation of recent memory into a cleaner long-term operating context.

## When To Use It

Run this skill when:

- onboarding has added a lot of new context
- recent daily notes contain corrections or updated preferences
- `MEMORY.md` feels stale or contradictory
- relative dates in memory are starting to drift
- the workspace needs a periodic cleanup pass

This skill is a good fit for:

- manual maintenance
- scheduled review work
- occasional heartbeat-driven cleanup

## Read First

Start by reading:

1. `MEMORY.md`
2. `USER.md`
3. `TOOLS.md`
4. `HEARTBEAT.md`
5. recent `memory/YYYY-MM-DD.md` files
6. any current onboarding notes if they exist

If session logs or transcripts exist in this environment and are easy to access, you may use them as supporting signal, but do not rely on them as the only source.

## Four-Phase Flow

### Phase 1 - Orient

Understand the current memory system:

- what `MEMORY.md` currently claims
- what stable preferences exist in `USER.md`
- what environment facts exist in `TOOLS.md`
- what recent daily notes say

Identify:

- stale items
- contradictions
- duplicated facts
- references to missing files, systems, or workflows

### Phase 2 - Gather Signal

Scan recent daily notes for:

- user corrections
- changed preferences
- new durable business context
- recurring workflow patterns
- explicit decisions
- approval-boundary clarifications

Prefer direct operator statements over inference.

### Phase 3 - Consolidate

Merge the new signal into durable memory:

- keep the latest valid version of a fact
- resolve contradictions in favor of the newest direct instruction
- convert relative dates to absolute dates when they matter
- remove references to things that no longer exist
- separate durable context from temporary task clutter

### Phase 4 - Prune And Index

Rebuild `MEMORY.md` into a lean, useful index.

Guidelines:

- keep it concise
- keep only durable facts, preferences, and rules
- avoid repeating details that already live better in daily notes
- prefer clear headings and short bullets
- aim to keep `MEMORY.md` comfortably reviewable in one pass

## Rules

- Do not store secrets, tokens, MFA codes, or passwords.
- Do not preserve stale relative phrases like "tomorrow" or "next week" when an absolute date is available.
- Do not let `MEMORY.md` become a task dump.
- Keep facts separated from assumptions.
- If a fact is uncertain, either omit it or mark it clearly as tentative.

## Output

When you run this skill:

1. Update `MEMORY.md` in place.
2. Optionally tighten related notes in `USER.md`, `TOOLS.md`, or `HEARTBEAT.md` if the memory drift clearly affects them.
3. Briefly summarize:
   - what changed
   - what contradictions were resolved
   - what stale items were removed
   - any remaining uncertainty
