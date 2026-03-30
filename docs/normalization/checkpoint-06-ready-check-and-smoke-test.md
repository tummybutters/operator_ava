# Checkpoint 06 - Ready-Check And Smoke-Test Contract

## Status

Proposed normalization spec.

This document defines the canonical readiness gate for a fresh Sandlers/OpenClaw tenant after provisioning.

It answers one simple question:

When can Qortana say a tenant is actually ready to hand off?

## Objective

Define one normalized ready/not-ready contract that every fresh deploy must satisfy before it is treated as a usable live tenant.

The goal is to stop conflating:

- server exists
- runtime starts
- dashboard opens
- tenant is genuinely ready for real use

Provisioning success is not enough.

A tenant should only be considered ready when the system can prove the runtime, workspace, shared state, gateway, and dashboard are all aligned.

## Scope

This checkpoint is for:

- fresh tenant deploy validation
- post-provision readiness checks
- dashboard handoff gating
- operator-facing ready/not-ready reporting

This checkpoint is not for:

- incident response on a live tenant
- deep workload testing
- business-process QA
- ongoing uptime monitoring

Those belong to separate operational docs.

## Relationship To Earlier Checkpoints

This checkpoint depends on:

- checkpoint 1 for canonical runtime layout
- checkpoint 2 for the golden server preset
- checkpoint 3 for the golden workspace preset
- checkpoint 4 for the normalized tenant profile
- checkpoint 5 for the provisioning workflow

This is the gate at the end of that flow.

## Core Rule

The ready-check must verify the live tenant that the dashboard and runtime are actually using.

It must not:

- validate a mirrored temp workspace
- validate a stale session snapshot
- validate only a host copy when the runtime reads a different path
- validate only infrastructure while ignoring user-visible behavior

## Ready States

Every fresh tenant should end provisioning in exactly one of these states.

## 1. Ready

Meaning:

- the tenant passed all required checks
- the dashboard link can be handed off
- the assistant is usable now
- any remaining manual work is explicitly labeled as post-provision auth

## 2. Ready With Manual Auth Pending

Meaning:

- core runtime and dashboard contract passed
- the tenant is operational
- one or more auth-dependent systems are not yet connected

Examples:

- Telegram not connected yet
- Google Workspace CLI not authenticated yet
- Microsoft account login not completed yet
- browser portal auth still pending

This state is acceptable for handoff as long as the missing auth items are clearly reported.

## 3. Not Ready

Meaning:

- one or more core checks failed
- the tenant should not be handed off
- the failure must be diagnosed before calling the deploy complete

Examples:

- gateway unreachable
- dashboard cannot connect
- workspace path mismatch
- shared state unreadable
- assistant cannot answer a first message

## Required Check Categories

## Category A - Runtime layout validation

Purpose:

- confirm the live tenant is using the canonical paths

Required checks:

- the canonical tenant root exists
- the canonical live workspace path exists
- the canonical state path exists
- the canonical config path exists
- the canonical session path exists
- the running runtime points at the canonical workspace, not a mirror

Failure means:

- `Not Ready`

## Category B - Golden workspace presence

Purpose:

- confirm the live tenant actually has the expected workspace baseline

Required checks:

- required workspace markdown files are present
- required `state/*.json` files are present
- expected skills/workflow directories exist
- personalized files exist where checkpoint 5 says they should

Required files should include at minimum:

- `AGENTS.md`
- `USER.md`
- `TOOLS.md`
- `MEMORY.md`
- `IDENTITY.md`
- `HEARTBEAT.md`
- `state/tasks.json`
- `state/today.json`
- `state/business.json`
- `state/workflows.json`

Failure means:

- `Not Ready`

## Category C - Shared state readability

Purpose:

- confirm the machine-readable tenant state is usable by the dashboard

Required checks:

- each required JSON file parses cleanly
- each file conforms to expected top-level shape
- `tasks.json` can be empty without causing dashboard fallback behavior
- `business.json` reflects tenant facts rather than placeholders
- `today.json` is present even on day zero

Failure means:

- `Not Ready`

## Category D - Runtime startup and local service health

Purpose:

- confirm the tenant runtime is actually alive

Required checks:

- OpenClaw/NemoClaw runtime is running
- required local services are up
- gateway target is listening
- agent services are in a healthy phase

Failure means:

- `Not Ready`

## Category E - Gateway and dashboard contract validation

Purpose:

- confirm the dashboard can reach and use the tenant gateway correctly

Required checks:

- gateway is reachable from the allowed dashboard origin
- allowed origin matches the production dashboard domain being used
- auth token or dashboard handoff token is valid
- runtime accepts the expected dashboard/control-ui identity
- websocket or gateway connection succeeds without policy failure

Failure means:

- `Not Ready`

## Category F - Live dashboard state rendering

Purpose:

- confirm the actual dashboard can render this tenant correctly

Required checks:

- dashboard can connect without manual path edits
- assistant tab loads the live tenant session
- `Tasks` tab reads tenant state, not placeholders
- `Today` tab reads tenant state, not placeholders
- `Business` tab reads tenant facts, not placeholders
- `Workflows` tab reads tenant workflow state, not placeholders or fake summaries

Failure means:

- `Not Ready`

## Category G - First message smoke test

Purpose:

- prove the tenant is usable by a real user

Required checks:

- a simple first message can be sent from the dashboard
- the assistant visibly responds without requiring page refresh
- the reply comes from the live personalized workspace
- the response is attached to the active dashboard session

Examples of acceptable smoke prompts:

- "What kind of assistant are you?"
- "What do you know about this workspace?"
- "Summarize what you help with."

Failure means:

- `Not Ready`

## Category H - Auth readiness labeling

Purpose:

- distinguish a healthy tenant from a fully authenticated tenant

Required checks:

- each auth-dependent system is labeled as:
  - ready
  - pending manual auth
  - not configured
- the deploy result does not falsely imply those systems are ready when they are not

Auth-dependent systems may include:

- Telegram
- Google Workspace CLI
- Microsoft account access
- Sandler Portal
- SCOUT
- carrier portals
- browser session auth

Failure means:

- at minimum `Ready With Manual Auth Pending`
- or `Not Ready` if the deploy reporting is misleading or incomplete

## Minimum Ready Gate

A tenant may only be marked `Ready` or `Ready With Manual Auth Pending` if all of the following passed:

1. Runtime layout validation
2. Golden workspace presence
3. Shared state readability
4. Runtime startup and local service health
5. Gateway and dashboard contract validation
6. Live dashboard state rendering
7. First message smoke test

If any of those fail, the result is `Not Ready`.

## Required Operator-Facing Output

Every ready-check should produce a structured summary with:

- tenant identifier
- environment or host reference
- dashboard URL
- gateway URL or hostname
- final readiness state
- passed checks
- failed checks
- manual auth items pending
- notes or anomalies

This output should be concise enough for handoff but specific enough for debugging.

## Example Ready Summary Shape

- `tenant`: `sandlers-pilot-001`
- `dashboardUrl`: live tenant dashboard link
- `gatewayHost`: public gateway hostname
- `state`: `Ready With Manual Auth Pending`
- `passed`:
  - runtime layout
  - workspace presence
  - shared state readability
  - runtime health
  - dashboard handshake
  - first message smoke test
- `manualAuthPending`:
  - Telegram
  - Google Workspace CLI
  - Microsoft account login
- `notes`:
  - dashboard usable now
  - auth-dependent actions blocked until operator completes login

## What Does Not Count As Ready

The following are not sufficient on their own:

- the server exists
- the runtime process starts
- the dashboard opens in the browser
- the workspace files were copied somewhere
- a temp mirror of the workspace looks correct
- the dashboard shows generic or placeholder content
- the assistant only works after manual refreshes or session resets

If the user-visible tenant flow is not sound, the tenant is not ready.

## Failure Handling Expectations

If a ready-check fails:

- the tenant stays `Not Ready`
- the specific failing category is recorded
- the provisioning path should not be rewritten ad hoc
- the failure should become an implementation or ops fix against the normalized path

The purpose of this checkpoint is to keep deploy work from degrading back into improvisation.

## Exit Criteria For Checkpoint 6

Checkpoint 6 is complete only when:

1. There is one normalized ready/not-ready contract.
2. The contract checks both infrastructure and user-visible dashboard behavior.
3. The contract distinguishes ready core functionality from pending manual auth.
4. The contract makes placeholder UI or mirrored-path success insufficient.
5. Future automation can report a fresh deploy as `Ready`, `Ready With Manual Auth Pending`, or `Not Ready` using this model.

## Immediate Implementation Direction

After this spec is accepted, the next work should be:

- convert these categories into actual automated checks
- define the structured machine-readable ready summary format
- wire the provisioning workflow to stop on `Not Ready`
- expose the post-provision auth checklist in a standardized handoff artifact

## Relationship To Future Work

This checkpoint closes the initial normalization sequence.

After this, implementation work should focus on:

- turning these checkpoints into actual scripts and automation
- aligning the current fleet to the normalized path
- reducing the remaining hand-run repair steps that still exist in the live system
