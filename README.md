# Sandlers OpenClaw Preset

This folder is the reusable starting point for a sales-agent OpenClaw instance.

It is intentionally smaller than a full live machine snapshot.

What belongs here:

- the workspace bootstrap files that shape agent behavior
- local workspace skills that should ship with every new agent
- a base OpenClaw config
- sandbox bootstrap and apply scripts
- durable workflow skills like opportunity intake, follow-up drafting, CRM note prep, memory consolidation, sales rhythms, Playwright, AgentMail, Twilio, PDF form filling, and Google Workspace workflows

What does not belong here:

- live secrets
- channel tokens
- browser auth state
- session transcripts
- `~/.openclaw` host state
- random sandbox residue

## Layout

- `workspace/` - the reusable agent workspace
- `workspace/memory/` - daily notes directory for continuity
- `workspace/STARTER-PROMPTS.md` - operator-facing setup prompt pack
- `workspace/MVP-DEFINITION.md` - scope and product-shape reference
- `workspace/skills/` - workspace-local skills with highest precedence
- `factory/` - tenant-creation and cloud-personalization templates
- `config/openclaw.base.json5` - base config for a fresh writable state dir
- `scripts/bootstrap-sandbox.sh` - installs sandbox-safe runtime dependencies
- `scripts/apply-preset.sh` - copies this preset into a target state/workspace
- `scripts/run-openclaw.sh` - launches OpenClaw against the target state dir
- `scripts/create-tenant-project.sh` - clones this preset into a new tenant project
- `scripts/stage-personalization.sh` - stages intake/transcript files into a live workspace for AI-driven personalization

## Included Base Behaviors

The preset now ships with tenant-agnostic workflow playbooks for:

- structured opportunity intake
- follow-up drafting
- CRM-ready note prep
- memory consolidation and pruning
- morning brief and end-of-day summary rhythms
- browser and portal work
- Google Workspace workflows
- telephony and messaging workflows
- PDF form filling
- optional AgentMail-backed email workflows

Most of these are intentionally lightweight defaults.

The base preset should teach the agent what tools exist and provide small starting patterns, while leaving deeper formatting, rhythm, and workflow preferences to onboarding and real usage. The main exception is clearly reusable operational playbooks like PDF form filling and memory consolidation.

## Factory Flow

The intended repeatable flow is:

```bash
./scripts/create-tenant-project.sh acme-broker
cd ../acme-broker
./scripts/bootstrap-sandbox.sh
./scripts/apply-preset.sh
./scripts/stage-personalization.sh /sandbox/.openclaw-sandlers/workspace --intake /path/to/intake.md --transcript /path/to/transcript.md
```

Then, inside the cloud agent:

```text
Read onboarding/PERSONALIZE-WORKSPACE.md and execute it.
```

## Fast Start

From inside a writable sandbox:

```bash
./scripts/bootstrap-sandbox.sh
./scripts/apply-preset.sh
./scripts/run-openclaw.sh
```

Google Workspace CLI is installed by default during bootstrap:

```bash
./scripts/bootstrap-sandbox.sh
```

If you need to skip it on a lean box:

```bash
SKIP_GWS=1 ./scripts/bootstrap-sandbox.sh
```

When the tenant uses Google Workspace, complete:

```bash
gws auth setup
gws auth login -s drive,gmail,calendar,docs,sheets
gws auth status
```

Twilio CLI is also installed by default during bootstrap:

```bash
twilio login
```

Default utility/media stack now includes:

- `jq`
- `rg`
- `pandoc`
- `ffmpeg`
- `imagemagick`
- `yt-dlp`
- `twilio`
- `ngrok`

Optional installs:

```bash
INSTALL_GH_COPILOT=1 ./scripts/bootstrap-sandbox.sh
INSTALL_BLENDER=1 ./scripts/bootstrap-sandbox.sh
```

By default this creates and uses:

- state dir: `/sandbox/.openclaw-sandlers`
- workspace: `/sandbox/.openclaw-sandlers/workspace`

Nothing in this preset writes secrets for you. Onboarding should fill in tenant specifics later.
