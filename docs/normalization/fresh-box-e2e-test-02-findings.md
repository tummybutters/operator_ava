# Fresh Box E2E Test 02 Findings

## Status

Executed against a Hetzner rebuild of `nemoclaw-htz-002` (`5.161.80.130`).

This was the second clean-slate factory run. The server was rebuilt from Hetzner before this run, making it a true fresh baseline — not a leftover from run 01.

Working tenant slug: `sandlers-factory-test-001`

---

## What This Run Proved

Every layer that was still uncertain after run 01 is now confirmed:

- Clean Hetzner rebuild is a valid baseline reset — no residual state carryover concern
- `bootstrap-sandbox.sh` runs cleanly on Ubuntu 24.04 after the python3-pip fix
- `install-runtime.sh` runs cleanly: Docker, cloudflared, `openclaw` 2026.3.28, NemoClaw v0.1.0, `nemoclaw` wrapper all installed without manual intervention
- `apply-preset.sh` correctly seeds `env.OPENROUTER_API_KEY` and sets the default model via `OPENROUTER_API_KEY_FILE` + `OPENCLAW_DEFAULT_MODEL` — no manual config write required
- `stage-personalization.sh` stages the profile cleanly to `/sandbox/.openclaw/workspace/onboarding/tenant-profile.json`
- Workspace personalization from the normalized profile produces correct, non-placeholder output for all six required files
- Gateway starts, reads canonical config, and logs `openrouter/xiaomi/mimo-v2-pro` as the active model on boot
- cloudflared quick tunnel exposes the local gateway to the browser without additional config
- Device pairing approval via `openclaw devices approve <request-id>` unblocks the browser in one command
- Dashboard connected and tenant passed the smoke test

---

## New Factory Defect Found And Fixed

### `bootstrap-sandbox.sh` — missing `python3-pip` on Ubuntu 24.04

Ubuntu 24.04 ships Python 3 without pip. The script checked for `python3` but not for pip, causing the PDF dependency install to fail with:

```
/usr/bin/python3: No module named pip
```

Fix applied to canonical source: the script now self-installs `python3-pip` via apt if pip is missing before attempting the pymupdf/pypdf install.

This is a true golden-server defect, not environment noise. Every future Ubuntu 24.04 deploy would have hit it.

---

## OpenRouter Child Key Flow — Confirmed Canonical

The working path:

```bash
# Locally — mint a tenant-scoped child key from the admin key
OPENROUTER_ADMIN_KEY=$(grep OPENROUTER_ADMIN_KEY /Users/tommybutcher/operator_ava/.env | cut -d= -f2 | tr -d '[:space:]') \
  OPENROUTER_ADMIN_KEY="$OPENROUTER_ADMIN_KEY" \
  bash scripts/create-openrouter-key.sh --name sandlers-factory-test-001 --out /tmp/openrouter.key

# Transfer to server
scp /tmp/openrouter.key root@<server-ip>:/tmp/openrouter.key

# On server — apply preset with key and model injected
OPENROUTER_API_KEY_FILE=/tmp/openrouter.key \
OPENCLAW_DEFAULT_MODEL=openrouter/xiaomi/mimo-v2-pro \
  bash /root/operator_ava/scripts/apply-preset.sh
```

`apply-preset.sh` calls `openclaw config set env.OPENROUTER_API_KEY` and `openclaw models set` internally. No manual config edit required. Key is not committed to git.

**Critical ordering constraint confirmed:** `install-runtime.sh` must complete before `apply-preset.sh` runs. If `openclaw` is not on PATH, `seed_initial_model_config` silently no-ops without error.

---

## Device Pairing Approval — Confirmed Canonical

After cloudflared tunnel and dashboard connection, the fresh gateway holds new devices at:

```
Your workspace is being activated. Hang tight.
```

The approval path from the server:

```bash
# List pending requests
OPENCLAW_STATE_DIR=/sandbox/.openclaw openclaw devices list

# Approve the most recent pending request by its request ID
OPENCLAW_STATE_DIR=/sandbox/.openclaw openclaw devices approve <request-id>
```

The browser connects immediately after approval. No refresh required in most cases; hard refresh clears it if needed.

This is a manual step. There is no automated approval in the factory scripts yet.

---

## nvm / Node Not Pre-Installed On Fresh Hetzner

Both `bootstrap-sandbox.sh` and `install-runtime.sh` require `node` and `npm`. Neither script installs them. On a fresh Hetzner Ubuntu 24.04 box, Node is not present.

The working pre-bootstrap sequence:

```bash
curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
export NVM_DIR="$HOME/.nvm" && . "$NVM_DIR/nvm.sh"
nvm install --lts
```

This is a documentation gap, not yet a script gap. All scripts must be run with nvm sourced in the shell:

```bash
export NVM_DIR="$HOME/.nvm" && . "$NVM_DIR/nvm.sh" && export PATH="$HOME/.local/bin:$PATH"
```

---

## Remaining Manual Boundary

These items are explicitly outside the factory-owned path and must be completed by the operator after handoff:

| Item | Why manual |
|---|---|
| Telegram bot connection | Requires BotFather token and chat ID — no automated path |
| Microsoft 365 / Outlook login | Browser OAuth — no automated path |
| SandlerPortal login | Browser session auth — no automated path |
| SCOUT login | Browser session auth — no automated path |
| Google Drive (`gws auth login`) | Interactive OAuth — no automated path |
| Device pairing approval | One-time shell command on fresh gateway — not yet scripted |

---

## What Is Not Yet Scripted

These are factory gaps that did not block this run but are not yet owned by the canonical scripts:

1. **nvm / Node install** — Phase 2 host baseline prep has no script. A `scripts/install-node.sh` or `scripts/bootstrap-host.sh` wrapper would close this.
2. **Device pairing approval** — `openclaw devices approve` works but nothing in the factory flow calls it. Could be scripted as a post-start step with a short wait loop.
3. **Handoff artifact** — No structured `ready-summary.json` or operator-facing markdown artifact is produced automatically. The ready-check is still a manual walkthrough.

---

## Factory Ownership Summary After This Run

| Layer | Status |
|---|---|
| Host baseline (apt, nvm, Node) | Manual — documented sequence, no script |
| Golden server preset (`bootstrap-sandbox.sh`) | Factory-owned |
| Runtime install (`install-runtime.sh`) | Factory-owned |
| Workspace apply + provider auth seed (`apply-preset.sh`) | Factory-owned |
| Personalization staging (`stage-personalization.sh`) | Factory-owned |
| Workspace personalization (agent-driven) | Factory-owned (prompt-driven) |
| Gateway startup (`run-openclaw.sh`) | Factory-owned |
| cloudflared tunnel | Manual — single command, no factory script |
| Device pairing approval | Manual — single command, not yet called by factory |
| Dashboard handoff link | Manual — constructed from config values |
| Ready-check | Manual — checkpoint 6 not yet automated |
| Post-provision auth (Telegram, portals, Microsoft) | Manual — acceptable boundary |

---

## Recommended Interpretation

This run should be treated as a full factory validation success.

The deploy reached a live dashboard, passed device pairing, and completed the smoke test without path forensics or session surgery.

The remaining gaps (nvm install, tunnel start, pairing approval, handoff artifact) are narrow and well-understood. None of them require ad hoc debugging — they are single commands with known inputs.
