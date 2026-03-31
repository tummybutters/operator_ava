# Fresh Box E2E Test 02 - Preflight Briefing

## Run Parameters

- Server: `nemoclaw-htz-002` / `5.161.80.130`
- Tenant slug: `sandlers-factory-test-001`
- Tenant profile: `factory/test-fixtures/sandlers-factory-test-001.tenant-profile.json`
- Default model: `openrouter/xiaomi/mimo-v2-pro`
- Deploy type: fresh only — no existing-tenant upgrade logic

---

## 1. End-to-End Deployment Plan

1. SSH into the server and verify we are starting from a known-clean baseline — not carrying over leftover state from the first e2e run that already ran on this same machine against this same slug.
2. Update packages and confirm Node/nvm baseline.
3. Clone or pull `operator_ava` from the canonical source.
4. Run `bootstrap-sandbox.sh` — golden server preset (browser tooling, media/doc utilities, Python/pip stack). Four real defects were already found and fixed in the canonical source on the previous run; they should not reappear.
5. Run `install-runtime.sh` — Docker, cloudflared, `openclaw` on PATH, NemoClaw cloned to `/root/NemoClaw`, dependencies installed, `nemoclaw` wrapper created.
6. Run `create-tenant-project.sh sandlers-factory-test-001` to scaffold the tenant project.
7. Run `apply-preset.sh` to create the canonical runtime layout under `/sandbox/.openclaw`.
8. Transfer the tenant profile to the server and run `stage-personalization.sh` with `--profile` pointing to it.
9. Have Ava personalize the workspace from the staged profile — producing `USER.md`, `TOOLS.md`, `MEMORY.md`, and all four state JSON files.
10. Seed provider/model auth for `openrouter/xiaomi/mimo-v2-pro` — mint or inject an OpenRouter API key into `env.OPENROUTER_API_KEY` and set the default model.
11. Start the runtime: `run-openclaw.sh`. Verify `gateway.mode=local` is set and the production dashboard origin is in `gateway.controlUi.allowedOrigins`.
12. Generate the dashboard handoff link with the live gateway host and token.
13. Handle device pairing approval for the fresh gateway.
14. Run all eight ready-check categories (A–H).
15. Report the final state and deliver the handoff package.

---

## 2. Canonical Paths

| Purpose | Canonical path |
|---|---|
| Tenant root | `/sandbox/.openclaw` |
| Live workspace | `/sandbox/.openclaw/workspace` |
| Shared state | `/sandbox/.openclaw/workspace/state` |
| Runtime config | `/sandbox/.openclaw/openclaw.json` |
| Agent session root | `/sandbox/.openclaw/agents/main/agent/` |
| Auth profiles | `/sandbox/.openclaw/agents/main/agent/auth-profiles.json` |
| NemoClaw | `/root/NemoClaw` |

`/sandbox/.openclaw-sandlers` is deprecated and must not appear in any resolved path during this run. If any script defaults there, stop and treat it as a blocker.

---

## 3. Expected Artifacts

### On the server

- `/sandbox/.openclaw/openclaw.json` — base runtime config with `gateway.mode=local` and allowed origins set
- `/sandbox/.openclaw/workspace/USER.md` — personalized from contact + classification + salesProfile
- `/sandbox/.openclaw/workspace/TOOLS.md` — personalized from systemsProfile (mandatory systems, portals, file storage)
- `/sandbox/.openclaw/workspace/MEMORY.md` — personalized from stallPoints, approvalBoundaries, noteHabits
- `/sandbox/.openclaw/workspace/AGENTS.md`
- `/sandbox/.openclaw/workspace/IDENTITY.md`
- `/sandbox/.openclaw/workspace/HEARTBEAT.md`
- `/sandbox/.openclaw/workspace/state/tasks.json` — empty but valid
- `/sandbox/.openclaw/workspace/state/today.json` — day-zero state
- `/sandbox/.openclaw/workspace/state/business.json` — seeded from contact + systemsProfile
- `/sandbox/.openclaw/workspace/state/workflows.json` — seeded from salesProfile + systemsProfile
- Provider auth seeded via `env.OPENROUTER_API_KEY` with `openrouter/xiaomi/mimo-v2-pro` as default model

### Operator-facing artifacts

- Dashboard handoff link (Vercel dashboard URL with `gateway` and `token` hash params)
- Ready-check summary: state (`Ready` or `Ready With Manual Auth Pending`), passed categories, manual auth checklist

---

## 4. First 5 Actions on the Server

1. **SSH in and audit the baseline.** Confirm whether `/sandbox/.openclaw` already exists from the prior run on this machine. If it does, decide explicitly: wipe it, or verify it is already in canonical shape before proceeding. Do not silently build on leftover state.
2. **Update packages.** `apt update && apt upgrade -y`, `DEBIAN_FRONTEND=noninteractive` for any interactive prompts.
3. **Clone or pull `operator_ava`** onto the server. Confirm the commit matches the expected main.
4. **Run `bootstrap-sandbox.sh`.** Watch for the four previously-fixed defects to confirm they stay fixed. If any fail, stop — do not hand-patch.
5. **Run `install-runtime.sh`.** Verify `openclaw` is callable and `node /root/NemoClaw/bin/nemoclaw.js --help` succeeds before proceeding.

---

## 5. Pass/Fail Conditions

All of the following must pass to exit as anything other than `Not Ready`:

| Category | What must be true |
|---|---|
| A — Runtime layout | `/sandbox/.openclaw`, `/sandbox/.openclaw/workspace`, `state/`, `openclaw.json` all exist; runtime is reading the canonical workspace, not a mirror |
| B — Workspace presence | All required markdown files and all four state JSON files are present in the live workspace |
| C — State readability | All JSON files parse cleanly; `business.json` has tenant facts, not template placeholders |
| D — Runtime health | OpenClaw/NemoClaw process running, gateway target listening |
| E — Gateway/dashboard contract | Gateway reachable from the dashboard origin, token valid, runtime accepts `openclaw-control-ui` identity |
| F — Dashboard renders | All tabs (Tasks, Today, Business, Workflows) read tenant state, not placeholders |
| G — First message smoke test | A simple prompt gets a real reply without manual refresh |
| H — Auth labeling | Every auth-dependent system is explicitly labeled: ready, pending, or not configured |

Acceptable final states: `Ready` or `Ready With Manual Auth Pending`.

`Not Ready` means do not hand off the link.

Expected manual auth items for this tenant: Telegram, Microsoft/Outlook, SandlerPortal, SCOUT, Google Drive — all acceptable as `pending` as long as they are explicitly listed.

---

## 6. Top 3 Likely Failure Points

### 1. Server is not actually clean

`nemoclaw-htz-002` was the target of the first e2e run. It has existing state: residual `/sandbox/.openclaw`, prior NemoClaw install, prior gateway config, prior browser device pairings. The `apply-preset.sh` re-apply regression was fixed (it no longer blindly overwrites personalized files), but that also means if old files are present they may survive without the new run being aware. The first action must be an explicit decision about what already exists and what gets cleared.

### 2. Provider/model auth seeding for OpenRouter

The findings doc from run 1 explicitly names this as the last unsolved gap: the agent reaches the live dashboard, the browser pairs, the user sends a message, and the run fails because the agent has no API key for the provider. That was for `anthropic`. This run uses `openrouter/xiaomi/mimo-v2-pro`. OpenRouter auth must be seeded before the smoke test, either via `env.OPENROUTER_API_KEY` or `auth-profiles.json`. There is no scripted, normalized path for this yet (Phase 4.6 in the implementation plan). It will require a deliberate step unless built as part of this run.

### 3. Device pairing on a fresh gateway

Even with transport, origin, and token all correct, the fresh gateway requires explicit pairing approval for a new browser device identity. Run 1 confirmed this: the browser showed "Your workspace is being activated. Hang tight." because the fresh server was waiting for approval. The old live server had already paired. There is no automated pairing approval step in the factory scripts yet. This will require a manual shell-side approval step during the smoke test phase unless scripted before we get there.
