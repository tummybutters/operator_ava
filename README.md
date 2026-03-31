# Sandlers OpenClaw Preset

This repo is the reusable starting point for a sales-agent OpenClaw instance.

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

- `docs/normalization/` - architecture specs and normalization checkpoints
- `workspace/` - the reusable agent workspace
- `workspace/state/` - machine-readable tenant state shared with the dashboard
- `workspace/memory/` - daily notes directory for continuity
- `workspace/STARTER-PROMPTS.md` - operator-facing setup prompt pack
- `workspace/MVP-DEFINITION.md` - scope and product-shape reference
- `workspace/skills/` - workspace-local skills with highest precedence
- `workspace/workflows/` - reusable workflow manifests
- `workspace/quote-templates/` - sanitized proposal shells and structure examples
- `factory/` - tenant-creation and cloud-personalization templates
- `config/openclaw.base.json5` - base config for a fresh writable state dir
- `scripts/bootstrap-sandbox.sh` - installs sandbox-safe runtime dependencies
- `scripts/install-runtime.sh` - installs the OpenClaw CLI plus the NemoClaw runtime on a fresh host
- `scripts/apply-preset.sh` - copies this preset into a target state/workspace
- `scripts/create-openrouter-key.sh` - mints a tenant-scoped OpenRouter child key from a management key
- `scripts/run-openclaw.sh` - launches OpenClaw against the target state dir
- `scripts/create-tenant-project.sh` - clones this preset into a new tenant project
- `scripts/stage-personalization.sh` - stages the normalized tenant profile plus supporting onboarding files into a live workspace for AI-driven personalization

## Shared State Layer

The preset uses a small JSON state layer under `workspace/state/` for live dashboard symmetry:

- `tasks.json`
- `today.json`
- `business.json`
- `workflows.json`

Use this state for UI-facing, machine-readable tenant data.

Keep markdown files as the assistant-facing reasoning layer.

## Included Base Behaviors

The preset now ships with tenant-agnostic workflow playbooks for:

- structured opportunity intake
- follow-up drafting
- CRM-ready note prep
- quote-factory support
- spreadsheet-preserving ops
- data-compare reporting
- delivery packaging
- document assembly
- memory consolidation and pruning
- morning brief and end-of-day summary rhythms
- browser and portal work
- Google Workspace workflows
- telephony and messaging workflows
- PDF form filling
- optional AgentMail-backed email workflows

Most of these are intentionally lightweight defaults.

The base preset should teach the agent what tools exist and provide small starting patterns, while leaving deeper formatting, rhythm, and workflow preferences to onboarding and real usage. The main exception is clearly reusable operational playbooks like PDF form filling and memory consolidation.

It should preload capability scaffolds, not tenant doctrine.

## Factory Flow

The intended repeatable flow is:

```bash
./scripts/create-tenant-project.sh acme-broker
cd ../acme-broker
./scripts/bootstrap-sandbox.sh
./scripts/install-runtime.sh
./scripts/apply-preset.sh
./scripts/stage-personalization.sh /sandbox/.openclaw/workspace --profile /path/to/tenant-profile.json --intake /path/to/intake.md --transcript /path/to/transcript.md
```

Then, inside the cloud agent:

```text
Read onboarding/PERSONALIZE-WORKSPACE.md and execute it.
```

## Live Deployment Note

For an already-running tenant on NemoClaw/OpenClaw, apply this preset into the existing writable workspace/state instead of creating a brand-new state directory. That preserves working gateway auth, channel wiring, Cloudflare tunnel setup, Telegram bridge state, and any already-approved device state while upgrading the tenant workspace and toolchain.

`scripts/apply-preset.sh` now auto-detects `/sandbox/.openclaw` when that live state exists and creates a backup before copying files in place.

Fresh deploys should treat `/sandbox/.openclaw` as the canonical tenant root.

`/sandbox/.openclaw-sandlers` is now deprecated and should only be referenced for migration or repair flows.

## Fast Start

From inside a writable sandbox:

```bash
./scripts/bootstrap-sandbox.sh
./scripts/install-runtime.sh
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

Runtime install now owns:

- Docker
- `cloudflared`
- the `openclaw` CLI
- NemoClaw clone/update at `/root/NemoClaw`
- a `nemoclaw` wrapper under `~/.local/bin`

When provider credentials are available, `scripts/install-runtime.sh` can also run a non-interactive `nemoclaw onboard` flow:

```bash
RUN_NEMOCLAW_ONBOARD=1 \
NEMOCLAW_PROVIDER=compatible-endpoint \
NEMOCLAW_MODEL=anthropic/claude-haiku-4-5 \
NEMOCLAW_ENDPOINT_URL=https://openrouter.ai/api/v1 \
COMPATIBLE_API_KEY=... \
./scripts/install-runtime.sh
```

Without those env vars, the runtime install still completes and leaves onboarding as the next explicit step.

For the simplest first-boot OpenRouter setup, create a child key and seed it into the live config during preset apply:

```bash
OPENROUTER_ADMIN_KEY=... \
./scripts/create-openrouter-key.sh \
  --name acme-broker \
  --out /tmp/acme.openrouter.key
```

Then:

```bash
OPENROUTER_API_KEY_FILE=/tmp/acme.openrouter.key \
OPENCLAW_DEFAULT_MODEL=openrouter/xiaomi/mimo-v2-pro \
./scripts/apply-preset.sh
```

That writes `env.OPENROUTER_API_KEY` into the live OpenClaw config and sets the default model in one pass.

Optional installs:

```bash
INSTALL_GH_COPILOT=1 ./scripts/bootstrap-sandbox.sh
INSTALL_BLENDER=1 ./scripts/bootstrap-sandbox.sh
```

By default this creates and uses:

- state dir: `/sandbox/.openclaw`
- workspace: `/sandbox/.openclaw/workspace`
- config: `/sandbox/.openclaw/openclaw.json`
- runtime-owned data root: `/sandbox/.openclaw-data`

Nothing in this preset writes secrets for you. Onboarding should fill in tenant specifics later.

`scripts/stage-personalization.sh` now requires the normalized tenant profile JSON and treats raw intake/transcript as supporting inputs rather than the primary source of truth.

## Normalization Docs

The first normalization checkpoint is documented under:

- `docs/normalization/README.md`
- `docs/normalization/checkpoint-01-canonical-runtime-layout.md`
- `docs/normalization/checkpoint-02-golden-server-preset.md`
- `docs/normalization/checkpoint-03-golden-workspace-preset.md`
- `docs/normalization/checkpoint-04-tenant-profile-schema.md`
- `docs/normalization/checkpoint-05-provisioning-workflow.md`
- `docs/normalization/checkpoint-06-ready-check-and-smoke-test.md`
- `docs/normalization/implementation-plan-from-checkpoints.md`
- `docs/normalization/fresh-hetzner-box-ava-e2e-runbook.md`

These docs define the intended canonical runtime layout before further golden preset work proceeds.
