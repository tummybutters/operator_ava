# Fresh Box E2E Test 04 Findings

## Status

Complete run — executed against a Hetzner rebuild of `nemoclaw-htz-002` (`5.161.80.130`).

This was the fourth clean-slate factory run. The server was confirmed freshly rebuilt from Hetzner before the run began. Dashboard connection confirmed live. First-message smoke test (Category G) was handed off to operator.

Working tenant slug: `sandlers-factory-test-001`

---

## Server Baseline Confirmed

- Host: `nemoclaw-htz-002`
- IP: `5.161.80.130`
- OS: Ubuntu 24.04.3 LTS
- Node: not installed (confirmed clean slate)
- nvm: not installed
- openclaw: not installed
- NemoClaw: not present
- cloudflared: not installed
- operator_ava: not present
- `/sandbox/.openclaw`: absent
- `/sandbox/.openclaw/workspace`: absent

---

## Run Sequence

### Step 1 — nvm + Node installed

- nvm v0.40.3 installed via official install script
- Node v24.14.1 LTS installed and aliased as default
- npm v11.11.0

### Step 2 — Canonical source synced to server

- `rsync` from `/Users/tommybutcher/operator_ava/` to `/root/operator_ava/`
- `.env` and `.docx` files excluded from sync
- All scripts confirmed present at `/root/operator_ava/scripts/`

### Step 3 — Bootstrap

- `scripts/bootstrap-sandbox.sh` ran cleanly
- playwright installed to `~/.local`
- Chromium browser installed with deps
- pymupdf, pypdf installed
- jq, rg, pandoc, ffmpeg, imagemagick, yt-dlp installed
- agentmail-cli written to `~/.local/bin/agentmail-cli` and confirmed callable
- twilio-cli, ngrok, gws installed to `~/.local`

### Step 4 — Runtime installed

- `scripts/install-runtime.sh` ran cleanly
- Docker installed via `get.docker.com`
- cloudflared installed via apt (version 2026.3.0)
- openclaw installed from npm: `/root/.nvm/versions/node/v24.14.1/bin/openclaw`
- NemoClaw cloned to `/root/NemoClaw`, deps installed
- nemoclaw wrapper written to `~/.local/bin/nemoclaw`
- `openclaw --help` and `nemoclaw --help` both verified

### Step 5 — OpenRouter child key minted

- Script: `scripts/create-openrouter-key.sh`
- Admin key source: `/Users/tommybutcher/operator_ava/.env` (`OPENROUTER_ADMIN_KEY`)
- Child key name: `sandlers-factory-test-001`
- Child key hash: `01bc674202bb4027cfdf05491227100e3aee93de12597b825c2fe0d6d6cb819e`
- Child key label: `sk-or-v1-56a...b8c`

### Step 6 — Preset applied

- Script: `scripts/apply-preset.sh`
- State dir: `/sandbox/.openclaw`
- Workspace: `/sandbox/.openclaw/workspace`
- Config: `/sandbox/.openclaw/openclaw.json`
- `OPENROUTER_API_KEY` seeded into `env.*` in config
- `OPENCLAW_DEFAULT_MODEL` set to `openrouter/xiaomi/mimo-v2-pro`
- `agents.defaults.workspace` set to `/sandbox/.openclaw/workspace`
- `agents.defaults.skipBootstrap` set to `true`
- `tools.exec.host` set to `gateway`
- `tools.exec.security` set to `full`
- `tools.exec.ask` set to `off`
- `tools.exec.pathPrepend` set to `["/root/.local/bin"]`
- `env.NODE_PATH` set to `/root/.nvm/versions/node/v24.14.1/lib/node_modules`

### Step 7 — Tenant profile staged

- Script: `scripts/stage-personalization.sh`
- Source: `/Users/tommybutcher/operator_ava/factory/test-fixtures/sandlers-factory-test-001.tenant-profile.json`
- Destination: `/sandbox/.openclaw/workspace/onboarding/tenant-profile.json`
- `PERSONALIZE-WORKSPACE.md` written to `/sandbox/.openclaw/workspace/onboarding/`

### Step 8 — Workspace personalized

Files written directly from tenant profile (no template placeholders remaining):

- `USER.md` — principal name, contact, timezone, territory, sales profile, stall points, approval boundaries
- `MEMORY.md` — operator facts, core systems, approval boundaries, working preferences
- `IDENTITY.md` — assistant name Cleo, context set to Qortana Sandlers Factory Test
- `TOOLS.md` — systems mapped: SandlerPortal, SCOUT, Microsoft 365, Google Drive/Dropbox; agentmail and GWS labeled as auth-pending
- `state/business.json` — operator block, sales profile, systems, approval boundaries
- `state/workflows.json` — 6 workflows: opportunity-intake (ready), quote-factory (ready), sandler-statements (auth-pending), follow-up-drafting (ready), crm-note-prep (ready), agentmail (auth-pending at this point)
- `state/today.json` — status: `fresh-deploy`, date: `2026-03-31`

### Step 9 — Workspace verified

All required files confirmed present:
- AGENTS.md, USER.md, TOOLS.md, MEMORY.md, IDENTITY.md, HEARTBEAT.md, SOUL.md
- state/tasks.json, state/today.json, state/business.json, state/workflows.json
- skills/sandler-statements present
- skills/agentmail present
- All JSON parses valid
- No template placeholders in any personalized file

### Step 10 — Gateway started

- Script: `scripts/run-openclaw.sh` → `openclaw gateway run`
- Gateway PID: 16267 (initial start)
- Auth token generated on first start: `592575f63ab396c2c55945fbcc45a72b2249769f7aa70567`
- Model confirmed in log: `openrouter/xiaomi/mimo-v2-pro`
- Gateway listening: `ws://127.0.0.1:18789`

### Step 11 — cloudflared tunnel started

- Command: `cloudflared tunnel --url http://127.0.0.1:18789`
- Initial tunnel URL: `https://sussex-nova-ministers-mas.trycloudflare.com`

### Step 12 — Dashboard URL generated

- Script: `scripts/get-dashboard-url.sh`
- First URL: `https://broker-dashboard-flax.vercel.app#gateway=wss://sussex-nova-ministers-mas.trycloudflare.com&token=592575f63ab396c2c55945fbcc45a72b2249769f7aa70567`

### Step 13 — AgentMail wired

- `AGENTMAIL_API_KEY` seeded into `env.*` in `/sandbox/.openclaw/openclaw.json` via `openclaw config set`
- Inbox created via `agentmail-cli create-inbox "Suzy TeamQortana"`
  - Display name: `Suzy TeamQortana`
  - Email address: `courageouscelebration209@agentmail.to`
  - Inbox ID: `courageouscelebration209@agentmail.to`
- `AGENTMAIL_INBOX_ID` seeded into `env.*` in config
- `agentmail-cli status` confirmed: configured, default inbox set
- `agentmail-cli list-messages` confirmed: inbox live, 0 messages
- Gateway restarted to pick up new env vars
- New tunnel URL after restart: `https://terminal-warm-winter-zen.trycloudflare.com`
- `TOOLS.md` updated: email status changed from auth-pending to configured
- `state/workflows.json` updated: agentmail status changed from auth-pending to ready

### Step 14 — Proxy trust fix

- Problem: dashboard connections rejected with `Proxy headers detected from untrusted address`
- Fix: `openclaw config set gateway.trustedProxies '["127.0.0.1","::1"]' --strict-json`
- Gateway restarted

### Step 15 — Browser pairing approved

- Pairing request found: `requestId f9eabc8d-92a9-44c0-8dd5-40ac5bab0cf2`
- Device ID: `a78bbf024148b9d4b7c4533c4819c9c9915f896c60780c2ce2036c4397b9bfba`
- Approved via `openclaw devices approve f9eabc8d-92a9-44c0-8dd5-40ac5bab0cf2`
- Gateway log confirmed: `webchat connected conn=f09abdab-3aeb-419f-ad01-81fe6b9cc797`

---

## Final Live State

- Server: `nemoclaw-htz-002` (`5.161.80.130`)
- Canonical state root: `/sandbox/.openclaw`
- Canonical workspace: `/sandbox/.openclaw/workspace`
- Canonical config: `/sandbox/.openclaw/openclaw.json`
- Gateway auth token: `592575f63ab396c2c55945fbcc45a72b2249769f7aa70567`
- Gateway tunnel: `terminal-warm-winter-zen.trycloudflare.com`
- Dashboard URL: `https://broker-dashboard-flax.vercel.app#gateway=wss://terminal-warm-winter-zen.trycloudflare.com&token=592575f63ab396c2c55945fbcc45a72b2249769f7aa70567`
- Model: `openrouter/xiaomi/mimo-v2-pro`
- AgentMail inbox: `courageouscelebration209@agentmail.to` (Suzy TeamQortana)
- Browser device paired: `a78bbf024148b9d4b7c4533c4819c9c9915f896c60780c2ce2036c4397b9bfba`
- webchat connected: `conn=f09abdab-3aeb-419f-ad01-81fe6b9cc797`

---

## Ready-Check Result

- Category A (runtime layout): PASS
- Category B (workspace presence): PASS
- Category C (state readability): PASS
- Category D (runtime health): PASS
- Category E (gateway reachable): PASS
- Category F (live dashboard rendering): not automated — browser connection confirmed
- Category G (first message smoke test): handed off to operator

Final classification: **Ready With Manual Auth Pending**

Manual auth pending:
- SandlerPortal: browser session required
- SCOUT: browser session required
- Google Workspace: `gws auth login` required
- Microsoft 365: browser auth required
- Telegram: not configured

---

## Factory Defects Found And Fixed This Run

### 1. `gateway.trustedProxies` not set in preset config

cloudflared forwards connections from `127.0.0.1` with `X-Forwarded-For` headers. Without `gateway.trustedProxies` set, the gateway rejects these with `Proxy headers detected from untrusted address`.

Fix applied: `openclaw config set gateway.trustedProxies '["127.0.0.1","::1"]' --strict-json`

This must be added to `apply-preset.sh` so it is set on every fresh deploy without a manual step.

### 2. `approve-next-device.sh` — UUID line-wrapped in table output

The table printed by `openclaw devices list` wraps the request UUID across two lines. The original grep regex `[0-9a-f]{8}-[0-9a-f]{4}-...-[0-9a-f]{12}` never matches across the line break, so the approve script always times out.

Fix applied in two steps:
1. First fix (test-03, carried forward): extended to `grep -A10 "Pending"` — did not fully resolve because UUID was still split
2. Second fix (this run): replaced grep parsing entirely with `openclaw devices list --json` and python3 extraction of `pending[0].requestId`

Script at `/Users/tommybutcher/operator_ava/scripts/approve-next-device.sh` updated and synced to server.

### 3. AgentMail display name cannot contain `@`

`agentmail-cli create-inbox "suzy@teamqortana"` returned `ValidationError: Display name contains invalid character(s): @`.

The assigned email address is system-generated (`courageouscelebration209@agentmail.to`). The display name is a human-readable label only.

Fix applied: used `"Suzy TeamQortana"` as display name.

---

## Known Non-Blocking Issues (carried from test-03)

### `agents.files.get` rejects state files and MVP-DEFINITION.md

The dashboard requests `state/*.json` and `MVP-DEFINITION.md` via `agents.files.get`. Runtime returns `INVALID_REQUEST errorMessage=unsupported file` for all of these. The chat and assistant paths are unblocked. State tabs in the dashboard show placeholders.

Same behavior as test-03. No fix applied. Requires dashboard-side update.

---

## Config Values Now Required On Every Fresh Deploy

These were set manually this run and must be added to `apply-preset.sh`:

- `gateway.trustedProxies` → `["127.0.0.1","::1"]`
