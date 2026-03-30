# Operator Agent Brief

This document is the durable handoff for the backend operator agent that prepares tenant OpenClaw workspaces.

## Goal

Turn a fresh or existing NemoClaw/OpenClaw instance into a post-onboarding, production-ready tenant workspace so the human only needs to:

- add secrets
- complete auth flows
- connect Telegram or other live channels
- verify final behavior

## Architecture

There are two different agents:

1. **Backend operator agent**
   - runs on the owner's Mac mini or another trusted control machine
   - watches intake
   - decides whether to wait for transcript
   - creates tenant projects from the golden preset
   - personalizes tenant-specific files
   - deploys the workspace into the cloud instance
   - leaves a short human handoff checklist

2. **Tenant runtime agent**
   - runs inside NemoClaw/OpenClaw
   - receives a prepared workspace
   - uses the preset as its operating system
   - finishes only in-workspace validation and live assistant behavior

Current production assumption:

- live tenant instances are running on Hetzner-hosted NemoClaw/OpenClaw environments
- the shared dashboard connects through the runtime gateway using hash-provided `gateway` and `token`
- live migrations should preserve working tunnel and channel state instead of resetting the whole instance

## Source Of Truth

The source of truth is the golden preset in this repo:

- repo root (`README.md`, `workspace/`, `factory/`, `scripts/`, `config/`)

Do not treat the live `.openclaw` state directory on a random machine as the product source of truth.
Do treat the live instance as the deployment target whose working gateway auth, Cloudflare tunnel, Telegram bridge, and approved device state must usually be preserved.

## What The Operator Agent Should Control

- tenant project creation
- preset application
- intake and transcript staging
- tenant personalization
- instance provisioning and copy/deploy steps
- base runtime installs
- final handoff generation
- safe preset upgrades for already-running tenant instances

## What The Operator Agent Should Not Hardcode

- live secrets
- browser auth state
- tenant-specific formatting preferences that are not yet proven
- portal-specific doctrines unless the tenant actually uses them

## Default Preset Philosophy

The preset should be:

- strong on general operating behavior
- strong on universal playbooks like PDF form filling and memory consolidation
- lightweight on integrations and tenant-specific workflow formatting

Deeper preferences should be learned during onboarding and real usage.

## Built-In Default Capability Areas

The preset currently includes:

- opportunity intake
- follow-up drafting
- CRM note prep
- dream-style memory consolidation
- sales rhythm summaries
- Playwright browser automation
- Google Workspace CLI workflows
- Twilio CLI workflows
- AgentMail wrapper
- PDF form filling

## Runtime Tooling

Bootstrap currently installs or prepares:

- `playwright-cli`
- `gws`
- `twilio`
- `ngrok`
- `jq`
- `rg`
- `pandoc`
- `ffmpeg`
- `imagemagick`
- `yt-dlp`

Optional installs:

- `gh-copilot`
- `blender`

## Core Factory Flow

1. Create a tenant project from the preset.
2. Apply the preset into the writable workspace/state dir.
3. Stage onboarding material into `workspace/onboarding/`.
4. Ask the tenant runtime agent to read `onboarding/PERSONALIZE-WORKSPACE.md` and execute it.
5. Produce a human handoff checklist for secrets and auth.

For live upgrades on an already-running tenant:

1. back up the active workspace and config
2. apply the preset into the active `.openclaw` state instead of a sidecar state dir
3. preserve live tunnel and channel wiring
4. reset the webchat session only if the running session is still carrying a stale pre-upgrade system prompt

## Key Scripts

- `scripts/create-tenant-project.sh`
- `scripts/bootstrap-sandbox.sh`
- `scripts/apply-preset.sh`
- `scripts/stage-personalization.sh`
- `scripts/run-openclaw.sh`
- `sandlers-openclaw-preset/scripts/stage-personalization.sh`

## Human Handoff Expectation

The human should ideally only have to do:

- Google auth if used
- Twilio auth if used
- AgentMail API key setup if used
- Telegram/BotFather connection
- any tenant-specific portal logins or MFA

## Current Design Principle

The correct long-term experience is:

"Here is the instance, here is the intake, here is the transcript. Prepare this tenant for production and tell me what secrets/auth steps remain."

That is the north star for the operator agent.
