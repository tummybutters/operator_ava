# Implementation Plan From The Normalization Checkpoints

## Status

Living planning document. Updated after fresh-box e2e test 02 (2026-03-31).

This document turns checkpoints 1 through 6 into an ordered implementation plan against the current `operator_ava` repo and the live Sandlers/OpenClaw deployment model.

## Objective

Move from:

- normalized documentation
- partial preset alignment
- successful but brittle live fixes

To:

- one canonical deployment path
- one canonical workspace/state contract
- one canonical onboarding and handoff flow
- fewer repair-only interventions in future deploys

## What This Document Is

This is the bridge between:

- the normalization specs
- the actual repo and scripts
- the current live fleet reality

It answers:

- what is already aligned
- what is still drifting
- what should be changed first
- what should wait until the foundation is stable

## Current State Summary

The repo now has a complete normalization design set:

1. canonical runtime layout
2. golden server preset
3. golden workspace preset
4. tenant profile schema
5. provisioning workflow
6. ready-check and smoke-test contract

That is good progress.

The remaining problem is implementation drift.

Some code paths and defaults still reflect the older, looser model rather than the normalized one.

## The Most Important Current Drift

## 1. Runtime path defaults were the highest-priority drift

Observed in:

- `scripts/run-openclaw.sh`
- `scripts/apply-preset.sh`
- `README.md`

This was previously visible in:

- `run-openclaw.sh` defaulting to `/sandbox/.openclaw-sandlers`
- `apply-preset.sh` treating `/sandbox/.openclaw-sandlers` as a normal fallback default
- the repo README documenting `/sandbox/.openclaw-sandlers` as the default created state

Why this mattered:

- checkpoint 1 says the canonical tenant root is `/sandbox/.openclaw`
- if scripts normalize around a side path, future deploys can still land in non-canonical locations

Status:

- phase 1 runtime path normalization has now been applied in the repo
- fresh defaults now point to `/sandbox/.openclaw`
- `/sandbox/.openclaw-sandlers` is now documented as deprecated and migration-only
- runtime/apply scripts now log the resolved canonical paths when they run

## 2. Tenant profile implementation was older than the schema

Observed in:

- `workspace/tenant-profile.template.json`
- `scripts/stage-personalization.sh`
- `factory/PERSONALIZE-WORKSPACE.template.md`

This was previously visible in:

- the template using older fields like `display_name`, `primary_channel`, `email_layer`, and loose placeholder refs
- the template not reflecting the checkpoint 4 schema sections
- the template reading more like a handcrafted personalization input than a canonical onboarding profile

Why this mattered:

- checkpoint 4 is now the onboarding contract
- if the repo personalizes from the old template, onboarding drifts immediately

Status:

- phase 2 tenant-profile normalization has now been applied in the repo
- `workspace/tenant-profile.template.json` now matches the checkpoint 4 structure
- `deploymentMode` is fixed to `fresh`
- timezone now defaults to `America/Los_Angeles`
- the old personalization-era fields have been removed from the template

## 3. Personalization is still more prompt-heavy than fully deterministic

Observed in:

- `scripts/stage-personalization.sh`
- `factory/PERSONALIZE-WORKSPACE.template.md`

Current shape:

- stage the normalized tenant profile plus optional intake/transcript support files
- ask the cloud agent to read a personalization prompt and execute it

Why this matters:

- this is much better than raw-intake-only staging, but it is still more freeform than the fully normalized end state
- checkpoints 4 and 5 want personalization to be driven from one normalized tenant profile
- freeform personalization still increases variability between tenants

Status:

- phase 3 profile-first staging and prompting has now been applied in the repo
- `scripts/stage-personalization.sh` now requires `--profile` and validates the normalized tenant profile JSON
- the script now stages `onboarding/tenant-profile.json` as the required primary input
- `factory/PERSONALIZE-WORKSPACE.template.md` now treats the normalized profile as primary and intake/transcript as secondary supporting material
- expected personalization outputs are now called out explicitly in the prompt template
- a deterministic renderer step is still recommended later if onboarding variability remains too high

## 4. Ready-check is documented but not automated

Observed in:

- no dedicated ready-check script yet
- no machine-readable handoff summary artifact yet

Why this matters:

- checkpoint 6 is the real handoff gate
- until it becomes executable, "ready" is still too dependent on operator judgment

## 5. Dashboard/shared-state symmetry is partially implemented, but not yet enforced by the factory flow

Observed in:

- dashboard already reads shared state
- live tenant workspace already contains `state/*.json`
- but provisioning/personalization scripts do not yet own this contract end to end

Why this matters:

- right now the architecture is correct in spirit
- the missing piece is making the factory scripts the ones that guarantee it

## What Already Looks Good

These should mostly be preserved and refined, not replaced:

- `scripts/bootstrap-sandbox.sh`
  - already acts like the starting point for the golden server/runtime toolchain
- `scripts/create-tenant-project.sh`
  - already gives a clean tenant project scaffold
- `scripts/apply-preset.sh`
  - already backs up live state before applying the preset
- `workspace/state/*.json`
  - the shared state layer exists and is conceptually correct
- the normalization docs
  - these now provide a strong target to implement against

## Recommended Execution Order

Implementation should happen in the following order.

## Phase 1 - Lock the canonical runtime path into code

Goal:

- remove path ambiguity from the actual scripts

Files to change first:

- `scripts/apply-preset.sh`
- `scripts/run-openclaw.sh`
- `README.md`

Required changes:

- make `/sandbox/.openclaw` the default canonical state root
- make `/sandbox/.openclaw/workspace` the default canonical workspace
- treat `/sandbox/.openclaw-sandlers` as deprecated or migration-only
- log the resolved canonical paths at runtime
- ensure apply/start flows clearly distinguish:
  - canonical tenant root
  - canonical workspace
  - runtime-owned data root

Done means:

- a fresh deploy path no longer defaults to a deprecated state root
- future agents do not have to guess where a live tenant should live

## Phase 2 - Replace the old tenant profile template with the normalized schema

Goal:

- make checkpoint 4 the real onboarding contract

Files to change:

- `workspace/tenant-profile.template.json`
- possibly add a canonical onboarding profile example or schema file under `factory/`

Required changes:

- replace the old loose structure with the normalized checkpoint 4 structure
- hardcode `deploymentMode` to `fresh`
- default timezone to `America/Los_Angeles`
- remove assumptions that belong to migrations or existing-tenant upgrades
- keep the raw intake mapping clean and machine-readable

Done means:

- future personalization starts from the same profile shape every time

## Phase 3 - Make personalization profile-driven instead of mostly prompt-driven

Goal:

- reduce onboarding variability

Files to change:

- `scripts/stage-personalization.sh`
- `factory/PERSONALIZE-WORKSPACE.template.md`
- possibly add a new helper script that compiles profile -> workspace/state outputs

Required changes:

- stage the normalized tenant profile, not just raw intake
- make the personalization prompt explicitly consume the normalized profile
- define exact outputs:
  - `USER.md`
  - `TOOLS.md`
  - `MEMORY.md`
  - `state/business.json`
  - `state/workflows.json`
- keep freeform LLM behavior for voice/tone refinement only where useful

Strong recommendation:

- introduce a deterministic renderer step for the first-pass outputs
- use the agent as an enhancer, not the only compiler

Done means:

- two similar intakes produce meaningfully similar workspace outputs

## Phase 4 - Turn the shared state layer into a factory-owned contract

Goal:

- ensure every tenant starts with valid UI state

Files to change:

- `workspace/state/*.json`
- `scripts/apply-preset.sh`
- personalization logic

Required changes:

- ensure every fresh deploy seeds:
  - `tasks.json`
  - `today.json`
  - `business.json`
  - `workflows.json`
- ensure empty tasks are explicit and valid
- ensure `business.json` mirrors stable tenant facts only
- ensure `today.json` starts in a clean day-zero state
- ensure `workflows.json` reflects realistic workflow readiness rather than marketing language

Done means:

- the dashboard can render a fresh tenant without guessing

## Phase 4.5 - Own the runtime install and start path

Goal:

- close the gap between workspace provisioning and a live engine

Files to add or change:

- `scripts/install-runtime.sh`
- `scripts/run-openclaw.sh`
- `scripts/apply-preset.sh`
- `README.md`
- fresh-deploy runbook docs

Required changes:

- install or update `openclaw` on a fresh host
- clone or update NemoClaw in a canonical location
- install NemoClaw dependencies
- make a `nemoclaw` entrypoint available without shell-memory tricks
- source `nvm` inside repo scripts when it is present so runtime commands work in normal shells
- fail loudly when `run-openclaw.sh` is asked to launch without a runtime installed
- support optional non-interactive `nemoclaw onboard` when provider credentials are provided

Done means:

- a fresh deploy can reach a callable OpenClaw/NemoClaw runtime without manual shell forensics
- the next factory rerun can get past Phase 11 for the right reasons
- Phase 5 ready-check automation has a live runtime layer to validate

## Phase 4.6 - Own gateway pairing and initial agent auth seeding

Goal:

- close the gap between a reachable gateway and a tenant that can actually answer

Files to add or change:

- `scripts/run-openclaw.sh`
- `scripts/install-runtime.sh`
- `scripts/ready-check.sh`
- gateway/auth handoff docs
- possibly a new helper such as:
  - `scripts/seed-agent-auth.sh`
  - or a deterministic gateway pairing helper

Required changes:

- generate and persist the gateway handoff token from the same live config the gateway will actually use
- make the handoff artifact point at the real live token instead of a drift-prone side file
- define how browser device pairing is handled on a fresh server:
  - explicit approval step
  - deterministic approval helper
  - or controlled auto-approval for the intended dashboard role
- ensure the production dashboard origin is allowed by default
- ensure the dashboard/browser device-auth flow matches the gateway protocol
- seed initial provider/model auth through the smallest supported path when credentials are already available:
  - prefer provider-native config/env paths for first boot
  - for OpenRouter, mint a tenant-scoped child key from the management key and seed `env.OPENROUTER_API_KEY`
  - use `auth-profiles.json` only when a provider flow truly requires it
- fail clearly when the tenant is connected but the agent cannot run due to missing provider auth

Done means:

- a fresh deploy can move from:
  - live dashboard URL
  - to browser pairing
  - to a successful first message
  without ad hoc shell debugging
- the remaining manual boundary is explicit and narrow when credentials are intentionally omitted

## Phase 5 - Implement the ready-check as code

Goal:

- make checkpoint 6 enforceable

Likely new files:

- `scripts/ready-check.sh`
- optionally a machine-readable summary file such as `ready-summary.json`

Required checks to automate first:

- canonical path validation
- workspace presence validation
- shared state JSON validation
- runtime process and gateway reachability
- dashboard handshake contract validation
- device pairing / pending-request detection
- agent auth-store presence for the default tenant agent

Checks that may start semi-manual before full automation:

- first message smoke test
- dashboard render validation

Done means:

- every tenant ends provisioning with:
  - `Ready`
  - `Ready With Manual Auth Pending`
  - or `Not Ready`

## Phase 6 - Align the handoff artifact

Goal:

- standardize what gets delivered after a successful deploy

Required output:

- dashboard URL
- gateway hostname
- readiness state
- manual auth checklist
- basic notes on what is usable immediately

Likely implementation:

- a structured JSON handoff summary
- an operator-facing markdown summary

Done means:

- Qortana can hand off a tenant consistently without re-explaining the state from scratch

## Phase 7 - Tighten dashboard integration only after factory ownership is in place

Goal:

- avoid more frontend band-aids before the backend contract is stable

What should happen here:

- confirm dashboard reads only the shared state contract
- reduce fallback heuristics where possible
- ensure assistant-side state updates follow the normalized contract

Why this is later:

- the dashboard is downstream of the factory path
- making the UI smarter before the factory is stable risks another layer of compensating logic

## Concrete Repo Changes To Prioritize First

If implementation starts now, the first concrete changes should be:

1. `scripts/run-openclaw.sh`
   - remove `/sandbox/.openclaw-sandlers` as the normal default

2. `scripts/apply-preset.sh`
   - resolve only the canonical tenant root for fresh deploys
   - keep any migration logic clearly labeled

3. `README.md`
   - remove or de-emphasize deprecated default state roots

4. `workspace/tenant-profile.template.json`
   - align or replace it with the checkpoint 4 schema

5. `scripts/stage-personalization.sh`
   - stage the normalized tenant profile explicitly

6. Add a first `ready-check` script stub
   - even if it only validates paths and JSON at first

## What Not To Do Yet

Do not start with:

- more dashboard polish
- more live-tenant surgery
- more prompt-only workspace rewrites
- complex workflow orchestration logic

Those can wait until the path, profile, and handoff contract are owned by the factory.

## Definition Of Success

This implementation plan is successful when a future fresh deploy works like this:

1. intake is captured
2. tenant profile is normalized
3. server is provisioned into the canonical layout
4. workspace preset is applied into the canonical workspace
5. personalization uses the normalized profile
6. shared state is initialized
7. runtime and gateway start
8. ready-check runs
9. a live dashboard link is handed off
10. only Telegram and browser/OAuth auth remain manual

And most importantly:

The deploy succeeds without needing path forensics, temp-workspace debugging, or hidden operator memory.

## What Run 02 Proved (2026-03-31)

Fresh-box e2e test 02 ran against a Hetzner rebuild of `nemoclaw-htz-002` and reached a live dashboard with a passing smoke test. Full findings: `docs/normalization/fresh-box-e2e-test-02-findings.md`.

Phases that are now confirmed factory-owned:

- Phase 1 — canonical runtime paths: confirmed, no `/sandbox/.openclaw-sandlers` in any resolved path
- Phase 2 — tenant profile template: confirmed, profile drove all six personalization outputs cleanly
- Phase 3 — profile-first personalization: confirmed, `stage-personalization.sh --profile` works end to end
- Phase 4 — shared state initialization: confirmed, all four state JSON files seeded correctly
- Phase 4.5 — runtime install: confirmed, `install-runtime.sh` owns Docker, cloudflared, openclaw, NemoClaw
- Phase 4.6 — provider auth seeding: confirmed, `create-openrouter-key.sh` + `apply-preset.sh` own the full OpenRouter child-key and model-seed path without manual config writes

One new defect found and fixed: `bootstrap-sandbox.sh` now self-installs `python3-pip` on Ubuntu 24.04 hosts where pip is missing.

What is still manual after run 02:

- nvm / Node install before bootstrap — no script, documented sequence only
- cloudflared tunnel start — single command, not yet called by a factory script
- Device pairing approval — `openclaw devices approve <request-id>` works but is not yet called by the factory
- Handoff link construction — manual assembly from config values
- Ready-check — checkpoint 6 is still a manual walkthrough
- Post-provision auth (Telegram, Microsoft, SandlerPortal, SCOUT, Google Drive) — accepted manual boundary

## Immediate Next Move

The factory path is now proven end to end. The highest-leverage remaining simplification is not adding new scripts — it is **collapsing the three manual pre-bootstrap shell steps into one**.

The current pre-bootstrap sequence requires the operator to know:

1. Install nvm
2. Source nvm
3. Install Node LTS

A single `scripts/bootstrap-host.sh` (or a guard at the top of `bootstrap-sandbox.sh`) that self-installs nvm and Node if missing would remove the last piece of required operator shell memory before the factory scripts take over.

After that, the next ticket is:

`Implement the ready-check as code.`

The factory can now provision, personalize, start, and expose a tenant. The missing piece is a script that verifies the result and produces a machine-readable handoff artifact instead of a manual walkthrough.
