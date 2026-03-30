# Checkpoint 01 - Canonical Runtime Layout

## Status

Proposed normalization spec.

This document defines the canonical live tenant layout that future deploys, presets, dashboard reads, and operator workflows should target.

It also records the current drift that must be eliminated.

## Objective

Create one canonical answer to these questions:

- Where does a live tenant actually live?
- Which path is runtime-owned?
- Which path is deploy-script-owned?
- Which path is dashboard-state-owned?
- Which path is backup-only?
- Which path is debug-only and should never again be treated as canonical?

If this checkpoint is not clean, every later "golden preset" remains fragile.

## Current Drift Observed

The current system has shown more than one candidate tenant root:

- `/tmp/oc-workspace`
- `/sandbox/.openclaw/workspace`
- `/sandbox/.openclaw-data/workspace`
- host-visible snapshot paths under containerd / Docker volumes

This created several classes of problems:

- preset upgrades could land in the wrong workspace copy
- the dashboard could read a different workspace than the runtime session snapshot was using
- stale `webchat` session state could preserve older prompt or skill paths
- future agents could "fix" the system successfully but in the wrong place

The existence of temporary or mirrored workspace copies is not automatically a bug.

The bug is when those copies are not explicitly labeled as:

- canonical
- runtime-managed
- backup-only
- debug-only

## Canonical Layout Contract

The normalized tenant layout should be:

### 1. Tenant writable state root

Canonical path:

`/sandbox/.openclaw`

This is the only deploy target future scripts should write into for a live tenant upgrade.

It is the canonical tenant state root.

### 2. Canonical workspace root

Canonical path:

`/sandbox/.openclaw/workspace`

This is the only canonical workspace path.

Everything that defines agent behavior and dashboard-facing tenant state should live here.

Examples:

- `AGENTS.md`
- `USER.md`
- `TOOLS.md`
- `MEMORY.md`
- `HEARTBEAT.md`
- `IDENTITY.md`
- `MVP-DEFINITION.md`
- `STARTER-PROMPTS.md`
- `skills/`
- `workflows/`
- `quote-templates/`
- `state/`

### 3. Canonical machine-readable UI state

Canonical path:

`/sandbox/.openclaw/workspace/state`

This directory is the shared state layer for the runtime and the dashboard.

Initial files:

- `tasks.json`
- `today.json`
- `business.json`
- `workflows.json`
- `README.md`

Rules:

- dashboard reads from here
- assistant/runtime updates here
- deploy scripts seed defaults here
- no secrets are stored here

### 4. Canonical tenant config

Canonical path:

`/sandbox/.openclaw/openclaw.json`

This is the tenant config path deploy/apply scripts should assume for a live tenant.

### 5. Runtime-managed internal data root

Canonical path:

`/sandbox/.openclaw-data`

This path is runtime-owned, not preset-owned.

It may contain:

- sessions
- transcripts
- caches
- internal runtime metadata
- backups created by runtime-aware migration flows

Normal preset application should not treat this as the workspace source of truth, even if the runtime currently mirrors or materializes files here.

### 6. Canonical session metadata

Canonical path family:

`/sandbox/.openclaw-data/agents/<agent-id>/sessions/`

Example:

`/sandbox/.openclaw-data/agents/main/sessions/sessions.json`

This path is authoritative for session metadata, but runtime-owned.

Normal deployment should not write here except for tightly scoped repair operations such as resetting a stale `webchat` session.

### 7. Canonical transcript/log ownership

Canonical path family:

`/sandbox/.openclaw-data/...`

Transcripts, logs, and runtime artifacts belong to runtime-owned space, not workspace-owned space.

The workspace is for agent context and tenant state.

The runtime data root is for execution history and internals.

## Ownership Boundaries

### Deploy scripts own

- `/sandbox/.openclaw`
- `/sandbox/.openclaw/workspace`
- `/sandbox/.openclaw/openclaw.json`

### Runtime owns

- `/sandbox/.openclaw-data`
- session metadata
- transcripts
- caches
- internal runtime state

### Dashboard reads

- tenant files through gateway file APIs
- especially `/workspace/state/*.json`

The dashboard should not invent tenant state when explicit state files exist.

### Backup and migration tools may read

- both canonical and runtime-owned paths

But they must label outputs clearly as:

- backup
- migration copy
- diagnostic mirror

## Deprecated and Non-Canonical Paths

The following should be treated as non-canonical unless explicitly documented as a migration step:

- `/tmp/oc-workspace`
- arbitrary host-visible copies of the workspace
- direct container snapshot paths under Docker or containerd
- any path discovered only through logs or forensic inspection

These may exist.

They may be useful for debugging.

They must not become the default target for future deploy scripts.

## Required Behavioral Rules

### Rule 1

Every future live tenant apply or upgrade flow must begin by resolving and logging:

- canonical tenant state root
- canonical workspace root
- canonical config path
- runtime-owned data root

### Rule 2

Every future deploy/apply script must target the canonical tenant root only.

### Rule 3

If the runtime is currently reading from a different workspace path than the canonical one, that is a migration problem to solve explicitly.

It is not permission to treat both paths as equal.

### Rule 4

Session resets are repair tools, not part of the normal happy path.

If a `webchat` reset is required, the script or operator should:

- back up the session file first
- remove only the affected browser session
- leave the main operator session intact

### Rule 5

The dashboard should treat explicit tenant state as authoritative:

- explicit empty task list means no tasks
- explicit daily summary means do not invent one from chat
- explicit workflow state means do not replace it with canned cards

## Exit Criteria For Checkpoint 1

Checkpoint 1 is complete only when all of the following are true:

1. There is one documented canonical tenant root.
2. There is one documented canonical workspace root.
3. There is one documented canonical runtime-owned data root.
4. Deploy/apply scripts target the canonical root only.
5. The dashboard reads tenant state from the canonical workspace through the gateway.
6. Future agents no longer need forensic path tracing to know where the live tenant actually is.
7. `/tmp` workspace copies and snapshot paths are treated as non-canonical by policy.

## Immediate Implementation Implications

Once this contract is accepted, the next implementation work should enforce it by:

- making `scripts/apply-preset.sh` and related tooling target the canonical path
- making live upgrade steps log the resolved canonical path before modifying anything
- documenting which runtime path is read-only for operators versus writable for migrations
- removing any remaining ambiguity from Ava's operator docs and fleet docs

## What This Checkpoint Does Not Solve

This checkpoint does not yet define:

- the full package list for the golden server preset
- the full tenant profile schema
- the full lead-to-live-dashboard automation workflow
- browser/OAuth auth finalization

Those are later checkpoints.

This checkpoint only establishes the foundation every later checkpoint depends on.
