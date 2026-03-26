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

## Source Of Truth

The source of truth is the golden preset in this repo:

- `sandlers-openclaw-preset/`

Do not treat the live `.openclaw` state directory on a random machine as the product source of truth.

## What The Operator Agent Should Control

- tenant project creation
- preset application
- intake and transcript staging
- tenant personalization
- instance provisioning and copy/deploy steps
- base runtime installs
- final handoff generation

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
2. Apply the preset into a writable workspace/state dir.
3. Stage onboarding material into `workspace/onboarding/`.
4. Ask the tenant runtime agent to read `onboarding/PERSONALIZE-WORKSPACE.md` and execute it.
5. Produce a human handoff checklist for secrets and auth.

## Key Scripts

- `sandlers-openclaw-preset/scripts/create-tenant-project.sh`
- `sandlers-openclaw-preset/scripts/bootstrap-sandbox.sh`
- `sandlers-openclaw-preset/scripts/apply-preset.sh`
- `sandlers-openclaw-preset/scripts/run-openclaw.sh`
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
