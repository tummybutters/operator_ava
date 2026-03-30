# Normalization Roadmap

This folder is the source of truth for turning the current Sandlers/OpenClaw/NemoClaw setup into a repeatable fleet factory.

The goal is not to preserve every historical workaround. The goal is to define the canonical path future agents and future deploys should follow.

## Checkpoint Order

1. Canonical runtime layout
2. Golden server preset
3. Golden workspace preset
4. Tenant profile schema
5. Provisioning workflow
6. Ready-check and smoke-test contract

## Why This Order

The runtime layout comes first because every other preset depends on writing to the correct live location.

If deploy scripts, dashboard state reads, workspace sync, and runtime session state do not agree on the same tenant root, every later layer becomes brittle:

- server bootstrap can succeed in the wrong place
- workspace preset can be applied to a mirror instead of the live workspace
- dashboard tabs can read stale or fake state
- session snapshots can keep old prompt state alive even after a "successful" migration

Checkpoint 1 is therefore the foundation for the entire factory.

## Current Document Set

- `checkpoint-01-canonical-runtime-layout.md`
  - the detailed spec for the first normalization checkpoint
- `checkpoint-02-golden-server-preset.md`
  - the server and runtime baseline spec for fresh tenant machines
- `checkpoint-03-golden-workspace-preset.md`
  - the canonical workspace contents and behavior spec for every tenant
- `checkpoint-04-tenant-profile-schema.md`
  - the canonical onboarding profile derived from intake answers for fresh deploys
- `checkpoint-04-tenant-profile-example.json`
  - the matching example JSON shape for a fresh tenant onboarding profile
- `checkpoint-05-provisioning-workflow.md`
  - the canonical fresh-deploy path from intake to a live dashboard handoff
- `checkpoint-06-ready-check-and-smoke-test.md`
  - the canonical ready/not-ready gate for a fresh tenant after provisioning

## Document Status

These docs are design and operating documents.

They define the desired normalized system, highlight current drift, and establish the contract future implementation should satisfy.

They do not, by themselves, mean the system is already normalized.
