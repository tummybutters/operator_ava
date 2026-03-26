# New Agent Handoff

Use this file when moving work to a different coding agent on another machine.

## What To Send

Send the other agent:

1. This repo or a copy of `sandlers-openclaw-preset/`
2. The intake file
3. The transcript file if available
4. The target instance details
5. This exact brief

## What The New Agent Should Read First

1. `sandlers-openclaw-preset/README.md`
2. `sandlers-openclaw-preset/factory/README.md`
3. `sandlers-openclaw-preset/factory/OPERATOR-AGENT-BRIEF.md`
4. `sandlers-openclaw-preset/factory/PERSONALIZE-WORKSPACE.template.md`
5. `sandlers-openclaw-preset/workspace/AGENTS.md`
6. `sandlers-openclaw-preset/workspace/TOOLS.md`

## Copy-Paste Prompt

```text
You are taking over the backend operator role for a sales-agent OpenClaw factory flow.

Read these files first:
- sandlers-openclaw-preset/README.md
- sandlers-openclaw-preset/factory/README.md
- sandlers-openclaw-preset/factory/OPERATOR-AGENT-BRIEF.md
- sandlers-openclaw-preset/factory/PERSONALIZE-WORKSPACE.template.md
- sandlers-openclaw-preset/workspace/AGENTS.md
- sandlers-openclaw-preset/workspace/TOOLS.md

Your job is to use the golden preset to prepare a tenant NemoClaw/OpenClaw instance so the human only needs to finish secrets and auth steps.

Do not redesign the preset from scratch.
Do not treat the live workspace state as the source of truth.
Use the preset as the source of truth and personalize only the tenant-specific parts.

Inputs I will give you:
- target instance details
- intake
- transcript if available

Expected output:
- a prepared tenant project
- a personalized workspace
- a short remaining handoff list for human auth/secrets
```

## Transfer Checklist

- confirm the new machine has repo access
- confirm the new agent has terminal access
- confirm the new agent has GitHub access if it needs to push
- confirm the new agent has Brev or remote-instance access if it needs to deploy
- confirm intake and transcript files are present
- confirm any secrets remain out of git
