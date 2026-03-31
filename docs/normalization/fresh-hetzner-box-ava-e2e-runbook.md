# Fresh Hetzner Box Ava End-To-End Runbook

## Status

Execution runbook.

This document describes the first clean-slate end-to-end factory test on a brand-new Hetzner server using the normalized Operator Ava / OpenClaw path.

## Objective

Validate the intended future deployment model on a blank machine instead of continuing to patch the existing live server.

The goal is to prove:

- a fresh server can be provisioned from the golden server preset
- the golden workspace preset can be applied into the canonical layout
- the tenant can be personalized from a normalized profile
- the runtime and dashboard can be brought up cleanly
- the tenant can pass the ready-check without legacy path forensics

## Why This Test Matters

The current live Hetzner tenant has too much historical drift to serve as the first pure factory proof.

It has already involved:

- mirrored workspaces
- stale webchat sessions
- host/runtime path ambiguity
- live repair operations

That environment is still useful as a reference, but it is not the correct place to judge whether the normalized path really works.

The fresh-box test isolates the real question:

Can Ava set up a new tenant end to end on a clean machine using the factory path we actually want?

## Scope

This runbook is for:

- a brand-new Hetzner server
- a fresh tenant deploy
- Ava-operated end-to-end provisioning
- validation through the ready-check contract

This runbook is not for:

- rebuilding the current live server
- upgrading an existing tenant
- migrating current tunnel or Telegram state from the old server

Those are separate tracks.

## Success Criteria

This run is successful if it ends with:

- one fresh tenant on a new Hetzner box
- canonical tenant root in place
- personalized workspace applied
- dashboard link produced
- tenant classified as:
  - `Ready`
  - or `Ready With Manual Auth Pending`

The accepted manual boundary is:

- Telegram connection
- browser portal auth
- Google Workspace CLI auth
- Microsoft account auth
- other browser/OAuth-based account logins

## Preconditions

Before starting, the following must exist:

- a fresh Hetzner server provisioned and reachable over SSH
- the current `operator_ava` repo on its latest `main`
- the normalization checkpoint docs already accepted
- one completed onboarding intake for the test tenant
- one normalized tenant profile derived from that intake
- the shared Vercel dashboard still available as the dashboard surface

## Important Constraint

Do not use the existing live Hetzner tenant as the target of this run.

Use a second fresh server so the test measures the factory path, not a migration path.

## High-Level Flow

1. Provision the new Hetzner box.
2. Prepare the host baseline.
3. Clone `operator_ava`.
4. Normalize the tenant input.
5. Apply the golden server baseline.
6. Install the OpenClaw/NemoClaw runtime layer.
7. Apply the golden workspace preset into the canonical state root.
8. Personalize the tenant from the profile.
9. Start runtime and gateway wiring.
10. Produce the dashboard link.
11. Run the ready-check.
12. Stop at manual auth if the tenant is otherwise ready.

## Phase 1 - Fresh server creation

Goal:

- get a clean Hetzner box with no previous tenant history

Requirements:

- Ubuntu or the chosen standard OS image
- SSH access confirmed
- no copied-over workspace, runtime cache, or old tenant state

Record at this stage:

- server IP
- datacenter
- server type
- root SSH access confirmation

## Phase 2 - Host baseline prep

Goal:

- prepare the box to receive the golden server preset

Actions:

- update system packages
- install any base OS dependencies needed to support bootstrap
- confirm Node/npm baseline is present or installable
- confirm the machine has network reachability for package installs

Output:

- server is ready for `operator_ava/scripts/bootstrap-sandbox.sh`

## Phase 3 - Pull the canonical preset repo

Goal:

- use the latest normalized factory repo as the only source of truth

Actions:

- clone or pull `operator_ava` onto the new server
- confirm the checked-out commit is the intended one

Output:

- repo is available locally on the fresh box

## Phase 4 - Normalize tenant onboarding input

Goal:

- avoid freeform onboarding drift

Actions:

- capture or copy the completed intake
- create the normalized tenant profile matching checkpoint 4
- choose the tenant slug or identifier

Output:

- raw intake artifact
- canonical tenant profile JSON
- tenant slug

## Phase 5 - Create the tenant project scaffold

Goal:

- create the tenant-level working project from the preset

Primary command shape:

```bash
./scripts/create-tenant-project.sh <tenant-slug>
```

Output:

- tenant project scaffold with workspace, scripts, config, and onboarding staging area

## Phase 6 - Apply the golden server preset

Goal:

- install the runtime/tool baseline on the fresh box

Primary command shape:

```bash
./scripts/bootstrap-sandbox.sh
```

Expected outcome:

- browser tooling installed
- media/document utilities installed
- OpenClaw-supporting runtime environment prepared
- optional CLIs installed where they are part of the golden baseline

Notes:

- this step should not be blocked by missing tenant auth
- auth remains a later/manual boundary

## Phase 6.5 - Install the runtime layer

Goal:

- install the actual OpenClaw/NemoClaw engine on the fresh box

Primary command shape:

```bash
./scripts/install-runtime.sh
```

Expected outcome:

- `openclaw` is callable on the host
- NemoClaw is cloned under `/root/NemoClaw`
- NemoClaw dependencies are installed
- `nemoclaw --help` succeeds (NemoClaw wrapper installed to `~/.local/bin`)
- optional non-interactive `nemoclaw onboard` becomes available when provider credentials are supplied

Notes:

- this closes the runtime gap discovered in the first clean Hetzner factory run
- `run-openclaw.sh` should never be the first place a missing runtime is discovered
- onboarding credentials can remain a later/manual boundary if they are not yet available
- NemoClaw is installed as runtime plumbing. The canonical operator gateway path is `run-openclaw.sh` → `openclaw gateway run`. Do not use `nemoclaw start` for tenant operations.

## Phase 7 - Apply the canonical runtime layout and workspace preset

Goal:

- create the live tenant under the canonical root

Primary command shape:

```bash
./scripts/apply-preset.sh
```

Expected canonical targets:

- `/sandbox/.openclaw`
- `/sandbox/.openclaw/workspace`
- `/sandbox/.openclaw/workspace/state`
- `/sandbox/.openclaw/openclaw.json`

Critical check:

- do not allow the fresh deploy to normalize around `/sandbox/.openclaw-sandlers`
- if the scripts still do that, stop and treat it as a phase-1 implementation gap before continuing

## Phase 8 - Stage personalization

Goal:

- prepare the tenant-specific inputs inside the workspace

Primary command shape:

```bash
./scripts/stage-personalization.sh /sandbox/.openclaw/workspace --profile /path/to/tenant-profile.json --intake /path/to/intake.md --transcript /path/to/transcript.md
```

Preferred next-state direction:

- stage the normalized tenant profile explicitly
- use raw intake and transcript as supporting material only

Output:

- onboarding artifacts staged in the live workspace

## Phase 9 - Have Ava personalize the tenant

Goal:

- produce the tenant-specific workspace from the golden baseline

Expected outputs:

- personalized `USER.md`
- personalized `TOOLS.md`
- personalized `MEMORY.md`
- initialized `state/business.json`
- initialized `state/workflows.json`
- valid `state/tasks.json`
- valid `state/today.json`

Critical rule:

- the result must land in the canonical live workspace, not a mirror

## Phase 10 - Start runtime and supporting services

Goal:

- bring the tenant online

Primary command shape:

```bash
./scripts/run-openclaw.sh
```

Expected outputs:

- tenant runtime starts
- gateway target is live
- local runtime services are healthy

If additional service scripts or tunnel setup are needed, they should follow the normalized provisioning workflow rather than ad hoc shell memory.

## Phase 11 - Connect the dashboard path

Goal:

- make the tenant reachable from the shared Vercel dashboard

Expected outputs:

- allowed dashboard origin configured
- valid tenant gateway host or tunnel
- valid dashboard handoff link
- pending browser device can be approved from the server side
- dashboard reaches a live connected state

This phase should result in a real handoff URL, not just a working local runtime.

Canonical handoff flow:

1. Generate the dashboard URL.
2. Give the operator the URL.
3. Let the operator open the dashboard.
4. Approve the next pending browser device.
5. Confirm the dashboard connects.
6. Send the first message.

## Phase 12 - Run the ready-check

Goal:

- decide whether the tenant is truly handoff-ready

Required categories:

- runtime layout validation
- workspace presence
- shared state readability
- runtime and local service health
- gateway/dashboard contract validation
- live dashboard state rendering
- first message smoke test
- auth readiness labeling

Accepted outcomes:

- `Ready`
- `Ready With Manual Auth Pending`

Rejected outcome:

- `Not Ready`

If the result is `Not Ready`, do not hand off the link as if the deploy succeeded.

## Phase 13 - Stop at the manual auth boundary

Goal:

- keep the factory test clean

Manual work that may remain:

- Telegram connection
- Google Workspace CLI auth
- Microsoft account auth
- Sandler Portal login
- SCOUT login
- other browser/OAuth-based portal logins

This is acceptable as long as the tenant is otherwise ready and those items are explicitly reported.

## What To Record During The Test

Capture the following:

- Hetzner server details
- exact `operator_ava` commit used
- tenant slug
- tenant profile artifact used
- resolved canonical runtime paths
- dashboard URL produced
- ready-check result
- manual auth items pending
- any deviations from the documented path

## What Counts As A Failed Factory Test

Treat the test as failed if:

- the deploy only works after path forensics
- the deploy only works after session surgery
- the dashboard requires placeholder/fallback behavior to look correct
- the tenant can only respond after refresh hacks
- the runtime is clearly reading from a non-canonical workspace
- the link is handed off before a real ready-check result exists

The point of the test is not just to get something working.

The point is to prove the normalized path is good enough to trust for the next tenant.

## Immediate Follow-Through After The Test

After the fresh-box run completes:

- record what passed cleanly
- record what required manual repair
- convert repair steps into implementation tickets only if they violate the normalized path
- do not silently absorb new band-aids into tribal memory

## Recommended Operator Posture

This run should be treated as a factory validation exercise, not a rushed production patch.

That means:

- stop when the path diverges
- document the exact divergence
- fix the factory path
- rerun cleanly

That discipline is what turns this from a clever deploy into a real repeatable system.

## Immediate Next Build Step Before Running This

Before attempting this fresh-box test, complete the first implementation item from the bridge plan:

- normalize runtime path defaults in the actual scripts and docs

That is the narrowest, highest-leverage prerequisite because it removes the most fundamental source of drift before Ava tries the full end-to-end setup.
