# Checkpoint 05 - Provisioning Workflow

## Status

Proposed normalization spec.

This document defines the canonical fresh-deploy provisioning workflow for turning a warm lead intake into a live, connected Sandlers/OpenClaw tenant with a ready dashboard link.

## Objective

Define one repeatable provisioning path that future agents and future deploys follow without improvising:

- intake captured once
- tenant profile normalized once
- server provisioned from the golden server preset
- workspace applied from the golden workspace preset
- tenant personalized from the profile
- gateway and dashboard connected
- live link produced
- only auth and channel handoff remain manual

The goal is to stop treating successful deploys like debugging victories.

## Scope

This workflow is for:

- fresh tenant deploys only
- Qortana-operated Sandlers/OpenClaw tenant creation
- the path from warm lead intake to a live dashboard link

This workflow is not for:

- existing tenant upgrades
- incident repair
- workspace migrations
- one-off debugging on already running boxes

Those are separate operational flows.

## Required Inputs

Provisioning begins only when the following exist:

- a completed onboarding intake
- a normalized tenant profile from checkpoint 4
- the golden server preset from checkpoint 2
- the golden workspace preset from checkpoint 3
- canonical runtime layout assumptions from checkpoint 1

## Core Rule

The provisioning workflow must consume normalized inputs and produce normalized outputs.

It should not depend on:

- manually remembered shell history
- ad hoc host path discovery
- debugging old sessions to determine what is live
- one-off frontend assumptions

## Canonical Workflow

## Step 1 - Capture intake

Input:

- lead form answers
- contact details
- legal consent

Output:

- raw intake record for this tenant

Notes:

- this should stay a clean intake artifact
- do not personalize the workspace directly from the raw form

## Step 2 - Normalize tenant profile

Input:

- raw intake record

Output:

- one canonical tenant profile JSON matching checkpoint 4

Notes:

- deployment mode is always `fresh`
- timezone defaults to `America/Los_Angeles` for now
- this profile becomes the source input for workspace personalization

## Step 3 - Create tenant project

Input:

- golden workspace preset repo
- tenant slug or identifier

Output:

- tenant project scaffold with:
  - preset files
  - personalization staging area
  - normalized docs and state scaffolds

Notes:

- this is the project-level representation of the tenant before server deployment
- it should not contain live secrets or browser auth state

## Step 4 - Provision server from the golden server preset

Input:

- tenant identifier
- golden server preset
- target infrastructure provider settings

Output:

- fresh tenant machine with the required runtime/tool baseline

The server must be provisioned with:

- canonical runtime layout
- Node and runtime dependencies
- NemoClaw/OpenClaw runtime dependencies
- browser automation stack
- media and document utilities
- cloudflared or equivalent tunnel prerequisites

Notes:

- this is the point where the machine becomes predictable
- this step should not yet require tenant browser auth

## Step 4.5 - Install the runtime layer

Input:

- fresh server
- Node runtime baseline
- runtime install script and version assumptions

Output:

- `openclaw` installed on the host
- NemoClaw cloned in a canonical location
- NemoClaw dependencies installed
- optional non-interactive onboarding path available when provider credentials are supplied

Notes:

- this is the missing layer discovered in the first clean Hetzner factory run
- runtime install should not depend on shell history or old-box memory
- `run-openclaw.sh` should assume this step has already happened and fail loudly if it has not

## Step 5 - Apply base runtime config

Input:

- fresh server
- base OpenClaw config
- canonical tenant root layout

Output:

- writable tenant state root
- canonical workspace path
- canonical state path
- canonical agent/session path

Notes:

- this is where checkpoint 1 becomes operational
- no temp path should become the implied live path

## Step 6 - Apply golden workspace preset

Input:

- canonical workspace target
- golden workspace preset

Output:

- generic tenant workspace loaded into the live runtime location

This includes:

- markdown workspace files
- `state/*.json` scaffolds
- workflow manifests
- skills
- quote templates

Notes:

- this is still tenant-agnostic at this moment
- the goal is to guarantee the same baseline on every new deploy

## Step 7 - Personalize from tenant profile

Input:

- normalized tenant profile
- tenant workspace

Output:

- personalized `USER.md`
- personalized `TOOLS.md`
- personalized `MEMORY.md`
- initialized `state/business.json`
- initialized `state/workflows.json`

Optional outputs:

- seeded `STARTER-PROMPTS.md`
- initial `state/today.json` framing

Notes:

- personalization should be deterministic from profile inputs
- do not rewrite the entire workspace freehand every time

## Step 8 - Initialize live shared state

Input:

- personalized tenant workspace

Output:

- initialized dashboard-facing state files

Required state files:

- `state/tasks.json`
- `state/today.json`
- `state/business.json`
- `state/workflows.json`

Rules:

- `tasks.json` should start empty unless onboarding itself creates real approved tasks
- `today.json` should describe the current day as a fresh deploy until activity begins
- `business.json` should mirror stable tenant facts only
- `workflows.json` should reflect available and expected workflows, not fantasy capabilities

## Step 9 - Start runtime and services

Input:

- provisioned machine
- applied config
- personalized workspace

Output:

- live tenant runtime
- active agent services
- stable gateway target

This step should bring up:

- the OpenClaw/NemoClaw runtime
- required local services
- tunnel processes or service wiring

Notes:

- this should be a normalized start path, not a debug shell sequence

## Step 10 - Connect gateway and dashboard

Input:

- live runtime
- gateway config
- allowed dashboard origin
- tenant auth token

Output:

- reachable tenant gateway
- valid dashboard URL
- valid token-bearing handoff link

Notes:

- the dashboard contract must match the runtime expectations
- this is where the control UI identity and origin policy matter

## Step 11 - Run readiness checks

Input:

- live tenant
- dashboard link

Output:

- pass/fail result for deploy readiness

Minimum expected checks:

- gateway reachable from the dashboard origin
- assistant connects without manual path fixes
- live workspace is the personalized workspace
- shared state files can be read
- dashboard tabs can render tenant state
- assistant can answer a simple first message

Notes:

- detailed smoke-test contract belongs to checkpoint 6
- this step is still required here as the gate before handoff

## Step 12 - Produce handoff package

Input:

- passing deploy

Output:

- live dashboard link
- operator-facing notes
- explicit manual auth checklist

The handoff package should include:

- dashboard URL
- what is ready now
- what still requires manual auth
- what channels are preserved or pending

## Manual Boundary After Provisioning

Provisioning should end with a tenant that is live and usable, but not falsely marked fully authenticated.

Manual or operator-guided post-provision steps may still include:

- Telegram connection
- browser/OAuth auth flows
- Google Workspace CLI auth
- Microsoft account auth
- portal-specific login approval

The workflow should make these explicit instead of silently treating them as already done.

## Ava / Operator Responsibilities

The normalized operator workflow should be responsible for:

- collecting intake
- normalizing the tenant profile
- creating the tenant project
- provisioning the server
- applying the workspace preset
- personalizing from the profile
- starting the tenant
- verifying first readiness
- delivering the live link

The operator workflow should not require:

- shell forensics to find the live workspace
- manually guessing whether the dashboard is reading the correct tenant state
- ad hoc prompt rewriting on each new deploy

## Canonical Inputs And Outputs

### Inputs

- raw intake
- normalized tenant profile
- golden server preset
- golden workspace preset
- base runtime config

### Outputs

- live tenant server
- live personalized workspace
- initialized shared state files
- working dashboard link
- manual auth checklist

## Exit Criteria For Checkpoint 5

Checkpoint 5 is complete only when:

1. There is one documented provisioning path for fresh tenants.
2. That path starts from intake and ends at a live dashboard link.
3. The path explicitly depends on checkpoints 1 through 4.
4. The workflow distinguishes provisioning from post-provision auth.
5. The workflow avoids existing-tenant or migration logic contaminating fresh onboarding.
6. Future implementation can say "run the provisioning workflow" instead of rediscovering the sequence.

## Immediate Implementation Direction

After this spec is accepted, the next work should be:

- define the actual orchestration command or script boundaries for each provisioning step
- align the current factory scripts to these step names
- define the final readiness gate and smoke-test contract in checkpoint 6

## Relationship To Later Checkpoints

This checkpoint defines the provisioning path.

It does not yet define:

- the exact smoke-test assertions
- the exact ready/not-ready reporting contract
- the full rollback strategy for failed provisioning

Those belong in checkpoint 6 and later operational docs.
