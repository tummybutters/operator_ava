# Fresh Box E2E Test 01 Findings

## Status

Executed against a fresh Hetzner server.

This document preserves the first real clean-slate factory run and the exact issues it surfaced.

Target server:

- `nemoclaw-htz-002`
- `5.161.80.130`

Working tenant slug:

- `sandlers-factory-test-001`

## Why This Matters

This was the first run that tested the normalized path against a genuinely blank server instead of the older repaired live environment.

The goal was not to get a tenant working by any means necessary.

The goal was to learn which parts of the factory path are now real, and which parts were still tribal knowledge or missing automation.

## What The Run Proved

The following layers are now materially real on a blank box:

- canonical tenant root:
  - `/sandbox/.openclaw`
- canonical live workspace:
  - `/sandbox/.openclaw/workspace`
- profile-first personalization staging
- shared state creation for:
  - `tasks.json`
  - `today.json`
  - `business.json`
  - `workflows.json`
- runtime installation:
  - `openclaw` on PATH
  - NemoClaw cloned to `/root/NemoClaw`
- gateway startup on the fresh box
- browser-facing dashboard link generation
- browser-to-gateway pairing flow on the fresh box

This means the system is no longer blocked at:

- path drift
- missing workspace
- missing runtime
- missing gateway
- missing browser reachability

## Bootstrap Defects Found And Fixed

The run exposed four real defects in `scripts/bootstrap-sandbox.sh`.

These were fixed in the canonical `operator_ava` source during the run:

1. wrong Playwright browser install command
2. `npm prefix` conflict with `nvm`
3. missing `DEBIAN_FRONTEND=noninteractive` for Playwright dependency install
4. Ubuntu 24.04 `pip` PEP 668 failure without `--break-system-packages`

Those failures were valuable because they were true golden-server defects, not quirks of the old live box.

## Runtime Layer Gap Found And Closed

The run initially failed at the runtime boundary because the factory could build the workspace but did not yet install the engine that runs it.

That gap is now addressed by:

- `scripts/install-runtime.sh`

The runtime layer now owns:

- Docker install
- `cloudflared` install
- `openclaw` install
- NemoClaw clone/update
- NemoClaw dependency install
- `nemoclaw` wrapper creation

## Gateway And Dashboard Defects Found

After the runtime layer was added, the next boundary became gateway startup and dashboard connection.

The run exposed these factory defects:

1. `gateway.mode=local` was missing from the base config
2. `run-openclaw.sh` launched `openclaw tui` instead of the gateway
3. `gateway.controlUi.allowedOrigins` was missing for the production dashboard origin

Those were fixed in the canonical source.

## Dashboard Device-Auth Defect Found

The fresh box then exposed a different class of issue:

- the dashboard browser client was not producing device auth in the same canonical form the OpenClaw gateway expects

Observed gateway failures included:

- `device identity mismatch`
- `pairing required`

This was important because it proved:

- transport worked
- token auth was present
- origin checks were working
- the browser was reaching the gateway
- the remaining problem was protocol alignment and pairing state

The dashboard was updated to align browser device auth more closely with the gateway protocol and to surface gateway detail codes more accurately.

Relevant dashboard repo:

- `https://github.com/tummybutters/broker-dashboard.git`

Relevant commit:

- `8bed777`
- `fix(gateway): align browser device auth with OpenClaw`

## Pairing Was A Real Missing Piece

Once the browser reached the fresh gateway, the next real missing piece was device pairing approval.

That is why the browser message:

- `Your workspace is being activated. Hang tight.`

was not random.

It meant:

- the browser reached the new server
- the new server recognized a new device identity
- the new server was waiting for approval

That is different from the older live server, where the browser had already been paired previously.

## Current Boundary Reached

The fresh box is now past the connectivity phase.

The latest visible user-facing behavior was:

- dashboard connected far enough to submit a chat message
- assistant attempted a run
- the run failed before reply because the tenant agent did not yet have a provider API key in its auth store

Observed error:

- `No API key found for provider "anthropic".`
- auth store path:
  - `/sandbox/.openclaw/agents/main/agent/auth-profiles.json`

This is not the same kind of failure as:

- tunnel failure
- token mismatch
- origin rejection
- missing pairing

It means the deployment is now blocked at initial provider/model auth seeding, not at connectivity.

## Most Important New Learning

The one-click deploy path is now missing a smaller, more specific layer:

- seed or provision the initial provider/model credentials for the tenant

The system can now:

- provision the box
- install the runtime
- apply the workspace
- personalize the tenant
- start the gateway
- expose the dashboard
- pair the browser

But it still does not yet guarantee:

- the agent has the right provider credentials through one of OpenClaw's supported resolution paths:
  - `auth-profiles.json`
  - environment variables
  - `models.providers.*.apiKey`

## Implication For One-Click Deploy

The path is much closer than before.

The next normalization target is not broad “debugging.”

It is a precise factory-owned step:

- install and seed the initial provider/model auth
- or explicitly classify it as a manual post-provision auth boundary

## Recommended Next Implementation Ticket

Create a new factory phase after runtime install and before final handoff:

- gateway + device onboarding normalization
- agent auth-profile seeding normalization

That phase should answer:

- how gateway tokens are generated and handed off
- how dashboard browser devices are approved or auto-approved in controlled cases
- how the main agent gets its initial provider/model auth through the simplest supported path

## Recommended Validation Interpretation

This run should be treated as a success, not a failure.

Why:

- it surfaced multiple real factory defects
- those defects were converted into canonical fixes
- it moved the system from infrastructure uncertainty to a narrow auth-store boundary

That is exactly how a clean factory validation run should behave.
