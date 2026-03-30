# Checkpoint 02 - Golden Server Preset

## Status

Proposed normalization spec.

This document defines the target server baseline for a fresh tenant machine after the canonical runtime layout is accepted.

It is not a claim that every live tenant already matches this baseline.

## Objective

Create one normalized server preset that makes future tenant creation predictable.

The desired result is:

- a new tenant server starts from one known baseline
- the right runtime and toolchain are already present
- the canonical OpenClaw tenant layout exists
- the dashboard/gateway path is expected and reproducible
- only tenant-specific secrets, Telegram connection, and browser or OAuth auth remain manual

## Important Distinction

The current fleet blurs two different layers:

- the host machine
- the tenant runtime environment

That distinction must become explicit.

### Host layer

The host is responsible for:

- OS
- package manager
- Node runtime installation path if host-managed
- cloudflared and gateway-facing infrastructure
- Docker or containerd runtime if used
- NemoClaw/OpenClaw launcher and supervisor layer
- filesystem ownership and mount layout

### Tenant runtime layer

The tenant runtime is responsible for:

- canonical tenant state root
- canonical workspace
- browser tooling
- CLI tools used by the assistant
- skill-accessible utilities
- tenant-facing OpenClaw behavior

Checkpoint 2 must say which tools belong to which layer.

## Current Observed Baseline

On the current Hetzner host, observed facts include:

- OS: Ubuntu 24.04.3 LTS
- `cloudflared` exists on the host
- `ffmpeg` exists on the host
- `chromium` exists on the host
- many expected assistant tools are not present on the host path:
  - `node`
  - `npm`
  - `openclaw`
  - `playwright-cli`
  - `rg`
  - `pandoc`
  - `yt-dlp`
  - `twilio`
  - `ngrok`
  - `gws`

This strongly suggests the live system should not assume:

- "host has everything"
- "assistant runtime tools are host-global"

That is good to know.

It means the server preset must explicitly define whether the golden baseline is:

- host-heavy
- runtime-heavy
- or split

## Recommended Server Preset Model

Use a split model:

### 1. Host golden preset

The host should provide only the infrastructure and runtime foundation:

- Ubuntu LTS
- cloudflared
- container runtime or sandbox runtime needed by NemoClaw/OpenClaw
- stable filesystem layout
- Node and launcher prerequisites if required by the host supervisor
- canonical tenant mount or state roots
- logging and backup utilities

The host should not be the place where tenant-specific workflow tooling is assumed to live globally.

### 2. Tenant runtime golden preset

The tenant runtime should carry the assistant-facing toolchain:

- `openclaw`
- `playwright-cli`
- Chromium/browser dependencies
- `python3`
- PDF dependencies
- `jq`
- `rg`
- `pandoc`
- `ffmpeg`
- `imagemagick`
- `yt-dlp`
- `twilio`
- `ngrok`
- `gws`

This keeps the tenant environment portable and closer to what the assistant actually needs.

## Canonical Golden Server Preset

The normalized golden server preset should define the following layers.

## Layer A - Base Host OS

Preferred baseline:

- Ubuntu 24.04 LTS
- x86_64
- security updates enabled
- predictable package manager behavior via `apt`

Required host-level utilities:

- `bash`
- `curl`
- `git`
- `tar`
- `rsync`
- `python3`
- `jq`

Recommended host-level utilities:

- `ripgrep`
- `htop`
- `unzip`

## Layer B - Host Runtime Infrastructure

Required:

- `cloudflared`
- the NemoClaw/OpenClaw runtime launcher path
- the sandbox or container runtime required by the product
- stable writable canonical tenant root
- stable runtime-owned data root

Required host-level guarantees:

- the canonical tenant root from checkpoint 1 exists or is created consistently
- the runtime can resolve the tenant workspace from the canonical path
- logs and session state are in documented runtime-owned paths

## Layer C - Tenant Runtime Toolchain

Required by default:

- Node runtime
- `npm`
- `openclaw`
- `playwright-cli`
- Chromium
- `python3`
- `jq`
- `rg`
- `pandoc`
- `ffmpeg`
- `imagemagick`
- `yt-dlp`
- `twilio`
- `ngrok`
- `gws`

Required runtime dependency behavior:

- all assistant-facing CLI tools are on the runtime PATH
- runtime PATH is deterministic
- Playwright can actually launch a browser in the runtime environment
- browser install is part of the preset, not an ad hoc repair

## Layer D - Tenant Runtime Workspace Seed

The server preset should seed the canonical writable state root with:

- canonical workspace path
- base config path
- state directory
- preset application support

The server preset is not the same thing as the workspace preset.

It should prepare the machine so the workspace preset can be applied cleanly every time.

## Layer E - Manual Auth Boundary

The golden server preset should stop at the correct line.

It should not attempt to hardcode:

- Telegram bot tokens
- Google OAuth login state
- Twilio login state
- portal browser auth state
- CRM credentials
- tenant-specific secrets

It should leave clear, documented manual steps for:

- Telegram/BotFather connection
- Google Workspace auth
- Twilio auth
- tenant-specific portal login
- browser session establishment where needed

## What The Server Preset Must Guarantee

For a fresh tenant machine, "server ready" should mean:

1. The machine is reachable.
2. The canonical tenant root exists.
3. The runtime can launch against the canonical tenant root.
4. The tenant runtime toolchain is installed and on PATH.
5. Chromium and Playwright are usable.
6. The workspace preset can be applied without path guessing.
7. The gateway and tunnel layer can be attached without re-architecting the machine.
8. The only remaining human work is secrets/auth/channel onboarding.

## What Should Not Be Left To Debugging

The following should never again be "figure it out live" items:

- where Node is installed
- whether `openclaw` exists
- whether the browser is installed
- whether `playwright-cli` can actually run
- whether the runtime PATH includes assistant tools
- whether the tenant root exists
- whether the runtime is reading from the canonical workspace path

If these remain uncertain, the server preset is not normalized.

## Current Bootstrap Script Coverage

The current `scripts/bootstrap-sandbox.sh` already points in the right direction for the tenant runtime layer.

It currently installs or prepares:

- `playwright-cli`
- browser install via `playwright-cli install-browser`
- PDF Python dependencies
- `jq`
- `rg`
- `pandoc`
- `ffmpeg`
- `imagemagick`
- `yt-dlp`
- `twilio`
- `ngrok`
- `gws` unless skipped

That script is a good seed for the runtime toolchain spec, but it is not yet the whole normalized server preset because it does not fully define:

- host/runtime boundary
- filesystem/layout guarantees
- service model
- validation contract

## Recommended Preset Outputs

Checkpoint 2 should eventually produce:

### 1. Host bootstrap spec

A document that says exactly what the machine image or first-boot host script provides.

### 2. Runtime bootstrap script

A single canonical script for the tenant runtime toolchain.

### 3. Validation script

A script that confirms the machine satisfies the golden preset.

### 4. "Server ready" handoff output

A machine-readable or text checklist confirming:

- host baseline ready
- runtime baseline ready
- workspace apply-ready
- auth-later items remaining

## Exit Criteria For Checkpoint 2

Checkpoint 2 is complete only when:

1. The host-vs-runtime boundary is explicitly defined.
2. There is one canonical list of required host packages and services.
3. There is one canonical list of required runtime tools.
4. There is one canonical bootstrap flow for a fresh tenant machine.
5. There is one canonical validation pass for server readiness.
6. Future agents no longer need to inspect a live machine ad hoc to know whether it is properly prepared.

## Immediate Implementation Direction

After this spec is accepted, the next implementation work should focus on:

- splitting host bootstrap from runtime bootstrap if they are currently mixed
- hardening `bootstrap-sandbox.sh` into the canonical runtime baseline installer
- adding a readiness validator for all required binaries and browser/runtime checks
- aligning the live Hetzner fleet with that validator instead of relying on memory and debugging

## Relationship To Later Checkpoints

This checkpoint does not yet define:

- the full workspace preset contents
- the tenant profile schema
- the intake-to-live-dashboard orchestration flow
- the dashboard smoke test contract

Those depend on the server baseline, so they come later.
