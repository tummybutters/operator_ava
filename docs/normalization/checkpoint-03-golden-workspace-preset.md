# Checkpoint 03 - Golden Workspace Preset

## Status

Proposed normalization spec.

This document defines the canonical workspace preset that every tenant should start from after the runtime layout and server baseline are accepted.

It answers:

- what belongs in the workspace
- what stays generic
- what gets personalized
- what the assistant should maintain over time
- what the dashboard should read directly

## Objective

Create one normalized workspace preset that future agents can apply without inventing structure.

The desired result is:

- every new tenant starts from the same durable workspace operating system
- the assistant knows how to behave before tenant-specific preferences are added
- the dashboard can read machine-readable tenant state directly
- onboarding only fills in tenant facts and auth-specific details instead of rewriting the whole workspace

## Relationship To Earlier Checkpoints

Checkpoint 01 defines where the live workspace lives.

Checkpoint 02 defines what machine and runtime baseline exist before the workspace is applied.

Checkpoint 03 defines what the workspace itself contains and how it behaves.

If checkpoint 03 is not normalized, then later onboarding still becomes a custom rewrite instead of a controlled personalization step.

## Canonical Workspace Root

The golden workspace preset is the contents of the canonical workspace root from checkpoint 01.

Target path:

`/sandbox/.openclaw/workspace`

Repo source:

`operator_ava/workspace/`

This repo path is the source of truth for the golden workspace preset.

Live tenant copies are deployment targets, not product truth.

## Current Workspace Surface

The current preset already includes these major categories:

### Core markdown files

- `AGENTS.md`
- `BOOTSTRAP.md`
- `HEARTBEAT.md`
- `IDENTITY.md`
- `MEMORY.md`
- `MVP-DEFINITION.md`
- `SOUL.md`
- `STARTER-PROMPTS.md`
- `TOOLS.md`
- `USER.md`

### Machine-readable state

- `state/README.md`
- `state/tasks.json`
- `state/today.json`
- `state/business.json`
- `state/workflows.json`

### Skills

- `agentmail`
- `crm-note-prep`
- `data-compare-reporting`
- `delivery-packaging`
- `document-assembly`
- `dream-memory-consolidation`
- `follow-up-drafting`
- `gws-meta-workflows`
- `opportunity-intake`
- `pdf-form-filling`
- `playwright-cli`
- `quote-factory`
- `sales-rhythm`
- `spreadsheet-ops`
- `twilio-cli`

### Workflow manifests and artifacts

- `workflows/`
- `quote-templates/`
- `tenant-profile.template.json`

## Golden Workspace Philosophy

The workspace preset should behave like an operating system for a tenant assistant.

It should be:

- strong on universal operating behavior
- strong on durable workflow primitives
- strong on the shared state contract
- lightweight on tenant-specific doctrine

It should not become a dumping ground for historical debugging or one-off tenant hacks.

## Canonical Workspace Contract

## Layer A - Identity and behavior

These files define assistant identity, boundaries, and baseline behavior:

- `AGENTS.md`
- `SOUL.md`
- `IDENTITY.md`
- `MVP-DEFINITION.md`

Rules:

- these files are generic by default
- they define the assistant's operating behavior
- they may be lightly personalized where tenant identity genuinely changes the assistant role
- they should not be rewritten wholesale during onboarding

### What stays generic

- safety and approval boundaries
- agent working style
- heartbeat philosophy
- default workflow/tool usage rules
- task-state maintenance rules

### What may be personalized

- assistant name
- assistant vibe details
- operator-facing role framing
- minor emphasis based on tenant workflow type

## Layer B - Tenant profile and stable business facts

These files hold tenant-specific facts:

- `USER.md`
- `TOOLS.md`
- `MEMORY.md`

Rules:

- these are the primary personalization targets
- they should hold stable business facts, not random day-to-day clutter
- they should be updated during onboarding and occasionally during long-term operations

### `USER.md`

Purpose:

- operator profile
- business context
- communication preferences
- work friction
- approval boundaries

### `TOOLS.md`

Purpose:

- system labels
- approved portals
- channel labels
- auth readiness notes
- storage references
- expected credential slots

### `MEMORY.md`

Purpose:

- durable operating context
- business priorities
- stable preferences
- rules learned over time

Not for:

- secrets
- MFA codes
- raw session transcripts
- temporary task clutter

## Layer C - First-run and startup scaffolding

These files help a fresh tenant boot cleanly:

- `BOOTSTRAP.md`
- `STARTER-PROMPTS.md`

### `BOOTSTRAP.md`

Rules:

- exists only for truly fresh tenants
- should be removed after onboarding is complete
- should not remain in mature live tenants unless intentionally resetting first-run behavior

### `STARTER-PROMPTS.md`

Rules:

- remains in the preset as operator tooling
- helps refine or extend a tenant later
- is not the same thing as runtime truth

## Layer D - Shared dashboard state

Canonical folder:

`state/`

This is the machine-readable contract between the assistant and the dashboard.

### `tasks.json`

Purpose:

- shared task list
- assistant-visible
- dashboard-visible
- later human-editable if desired

Behavior:

- assistant usually asks before adding inferred tasks
- assistant removes completed tasks when work is actually complete
- explicit empty task state means no tasks

### `today.json`

Purpose:

- current calendar-day summary
- freeform but useful operational snapshot

Behavior:

- reflects meaningful work completed
- reflects important activity and progress
- reflects near-term next steps
- updates as work happens, not just at the end of the day

### `business.json`

Purpose:

- stable tenant facts for the Business tab

Behavior:

- mirrors established tenant facts already present in markdown docs
- does not become a second hidden business memory system

### `workflows.json`

Purpose:

- lightweight workflow readiness view

Behavior:

- factual
- minimal
- not a marketing list of imaginary capabilities

## Layer E - Skills

Canonical folder:

`skills/`

This folder contains reusable operator-facing capabilities that should ship with every tenant by default.

Rules:

- skills should remain generic and reusable
- skills are not where tenant-specific facts belong
- skills define methods and operating patterns, not live account state
- onboarding may choose which skills matter most for a given tenant, but the base set should stay normalized

## Layer F - Workflow manifests and templates

Canonical folders:

- `workflows/`
- `quote-templates/`

Purpose:

- reusable workflow contracts
- artifact expectations
- sanitized proposal and document structures

Rules:

- these are reusable assets
- they should not contain live tenant secrets or real customer residue
- they help the assistant produce consistent outputs without hardcoding one tenant's entire style as the product default

## What The Workspace Preset Must Guarantee

A normalized workspace preset should guarantee:

1. Every tenant gets the same baseline assistant behavior.
2. Every tenant gets the same shared state contract.
3. Every tenant gets the same base skill set unless intentionally changed.
4. Dashboard tabs can be driven from explicit tenant state, not frontend boilerplate.
5. Personalization is focused on tenant facts and workflow emphasis, not on rebuilding the workspace from scratch.

## What Must Stay Out Of The Workspace Preset

The workspace preset must not become the place for:

- live secrets
- raw credentials
- browser auth state
- cloud tunnel tokens
- session transcript archives
- random host machine notes
- provider-specific hacks that only apply to one broken deploy

Those belong in:

- runtime-owned state
- onboarding-specific handoff
- host/runtime config
- or incident docs, not the preset itself

## Personalization Boundary

The normalized personalization step should be narrow.

What personalization should change:

- `USER.md`
- `TOOLS.md`
- `MEMORY.md`
- possibly `IDENTITY.md`
- initial values in `state/business.json`
- initial values in `state/workflows.json`
- initial day-zero values in `state/today.json`

What personalization should usually not change:

- `AGENTS.md` structure
- `SOUL.md`
- core skill set
- state contract schema
- workflow manifest structure

This is how the preset becomes a real product instead of a new custom workspace every time.

## Live Workspace Maintenance Rules

A live tenant should be allowed to evolve, but only within a normalized frame.

Acceptable live evolution:

- updating tenant facts
- updating task state
- updating today's summary
- updating workflow readiness
- adding durable memory based on real usage

Dangerous drift:

- rewriting core operating rules ad hoc
- introducing one-off files with no clear ownership
- storing secrets in workspace files
- letting live debugging notes become permanent preset doctrine

## Exit Criteria For Checkpoint 3

Checkpoint 3 is complete only when:

1. The canonical workspace contents are explicitly defined.
2. The generic-vs-personalized boundary is explicitly defined.
3. The shared state contract is part of the workspace spec, not a side idea.
4. Skills, workflow manifests, and artifact templates have clear ownership.
5. Future tenant onboarding can be described as "apply preset, then personalize a defined subset of files."

## Immediate Implementation Direction

After this spec is accepted, the next work should focus on:

- tightening the current workspace files against this contract
- identifying anything in `workspace/` that is too tenant-specific to remain in the base preset
- identifying anything missing that should be part of the normalized baseline
- defining the tenant profile schema that drives personalization cleanly

## Relationship To Later Checkpoints

This checkpoint does not yet define:

- the exact tenant profile schema
- the exact lead-intake to tenant-provisioning automation
- the final ready-check and smoke-test system

Those come next.
