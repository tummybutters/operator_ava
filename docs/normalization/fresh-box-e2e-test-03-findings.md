# Fresh Box E2E Test 03 Findings

## Status

Partial run — executed against a Hetzner rebuild of `nemoclaw-htz-002` (`5.161.80.130`).

This was the third clean-slate factory run. The server was rebuilt from Hetzner before this run.

Working tenant slug: `sandlers-factory-test-001`

Run was halted after session compaction caused a self-correction failure (see below). The run does not have a complete smoke test result. A clean restart is required.

---

## What Was Completed Before Halt

- Hetzner OS rebuild confirmed as valid clean-slate baseline
- `bootstrap-sandbox.sh` ran cleanly
- `install-runtime.sh` ran cleanly
- `apply-preset.sh` ran cleanly; model `openrouter/xiaomi/mimo-v2-pro` confirmed in gateway startup log
- Workspace personalized from normalized tenant profile — all six required files written, no placeholders
- Gateway started via `run-openclaw.sh` → `openclaw gateway run`
- cloudflared quick tunnel live
- Device pairing approved (manual, due to `approve-next-device.sh` grep bug — now fixed)
- Dashboard connected via `conn=334d94cf`, client identified as `openclaw-control-ui webchat v1.0.0`
- Smoke test was pending at context compaction

---

## Factory Defects Found And Fixed This Run

### 1. `approve-next-device.sh` — grep window too narrow

`grep -A2 "Pending"` did not capture the UUID, which appears 3+ lines after the "Pending" header in the table output. The watcher timed out without finding the pending request.

Fix applied: changed to `grep -A10 "Pending"`.

### 2. `agents.files.get` API limitation in openclaw 2026.3.28

The dashboard requests `state/*.json`, `MVP-DEFINITION.md`, and other extended files via `agents.files.get`. The runtime returns `INVALID_REQUEST errorMessage=unsupported file` for all of these. Only the five core markdown workspace files are served (AGENTS.md, USER.md, TOOLS.md, MEMORY.md, IDENTITY.md).

Root cause: runtime-level whitelist in openclaw 2026.3.28, not configurable. State tabs in the dashboard show placeholders as a result.

No fix applied. This requires a dashboard-side update to use the correct API for state file reads. It does not block basic smoke testing.

### 3. `ping` method unsupported

Dashboard sends periodic `ping` heartbeat over the gateway WebSocket. Runtime returns `unknown method: ping`. Same dashboard/runtime version mismatch pattern as defect 2. Not blocking.

---

## Critical Self-Correction: NemoClaw Internal CLI Drift

### What Happened

After session compaction, Ava re-entered the session and attempted to restart the gateway. The restart command (`nohup node bin/nemoclaw.js start`) failed because the system PATH did not include nvm's node binary. Rather than stopping to identify the canonical restart path, Ava continued investigating — reading `/root/NemoClaw/bin/nemoclaw.js` and `/root/NemoClaw/bin/lib/credentials.js` to understand the `ensureApiKey` / NVIDIA key prompt behavior.

This was a navigation error. The NemoClaw CLI internals are not the operator-facing runtime surface for this factory.

### Anti-Pattern (do not repeat)

**Do not treat upstream NemoClaw CLI internals as the canonical tenant runtime path.**

Specifically:
- Do not run `nemoclaw start` to bring the gateway up
- Do not read or reason from `/root/NemoClaw/bin/nemoclaw.js` to diagnose startup failures
- Do not attempt to bypass `ensureApiKey()` / NVIDIA key prompts — that is a NemoClaw onboarding concern, not an operator concern
- Do not reach for `node bin/nemoclaw.js` as a fallback when `openclaw gateway run` is the actual gateway command

The NemoClaw repo is plumbing installed by `install-runtime.sh`. It exists on disk as a dependency. It is not the operator's interface.

### Canonical Pattern (what to do instead)

| Step | Canonical path |
|------|---------------|
| Install runtime | `scripts/install-runtime.sh` |
| Apply config | `scripts/apply-preset.sh` |
| Start gateway | `scripts/run-openclaw.sh` → runs `openclaw gateway run` |
| Approve pairing | `scripts/approve-next-device.sh` |
| Get dashboard URL | `scripts/get-dashboard-url.sh` |

The `openclaw` npm package is the operator-facing CLI. `openclaw gateway run` is the command that starts the tenant runtime. `run-openclaw.sh` is the canonical wrapper that sets env, checks for missing config, and calls it.

If `run-openclaw.sh` fails, diagnose why `openclaw gateway run` cannot start — not why `nemoclaw.js` behaves a certain way.

---

## Docs That Risk Sending Future Runs Down the Wrong Path

The following references may anchor future session reasoning toward the NemoClaw CLI internals:

| File | Line(s) | Risk |
|------|---------|------|
| `docs/normalization/fresh-hetzner-box-ava-e2e-runbook.md` | ~233 | Post-install verify check uses `node /root/NemoClaw/bin/nemoclaw.js --help` as a success marker. Accurate for install verification but uses `nemoclaw.js` as a mental model anchor. |
| `docs/normalization/fresh-box-e2e-test-02-preflight.md` | ~79 | Same verify check phrased as a step: "Verify `node /root/NemoClaw/bin/nemoclaw.js --help` succeeds before proceeding." Same anchor risk. |

Neither reference incorrectly describes the start path. The runbook correctly uses `run-openclaw.sh` for Phase 10. But the nemoclaw.js verify step appears close to the runtime start section, which is where the drift occurred after session compaction.

---

## Smallest Cleanup Needed

### Change 1: Rewrite the install verify step in both docs

Replace:
```
- `node /root/NemoClaw/bin/nemoclaw.js --help` succeeds
```

With:
```
- `nemoclaw --help` succeeds (NemoClaw wrapper installed to ~/.local/bin)
```

This keeps the verification intent (wrapper is installed, node path works) without surfacing `nemoclaw.js` as a named internal. The wrapper is what the operator should know about; the internal path is an implementation detail.

### Change 2: Add a one-line boundary note to the runbook Phase 6 section

After the NemoClaw install verification block, add:

```
Note: NemoClaw is installed as runtime plumbing. The canonical operator gateway path is `run-openclaw.sh` → `openclaw gateway run`. Do not use `nemoclaw start` for tenant operations.
```

That is the full cleanup. No other files need changes.

---

## What To Do On The Next Rerun

1. The gateway on `5.161.80.130` is stopped (context was lost during compaction). cloudflared may still be running.
2. Start with `ssh root@5.161.80.130` and run `scripts/run-openclaw.sh` (after sourcing nvm or using the canonical wrapper with PATH set).
3. If the cloudflared tunnel is still alive, get its URL from the process or restart it. If not, start a fresh tunnel: `cloudflared tunnel --url http://localhost:18789`.
4. Run `scripts/get-dashboard-url.sh <tunnel-host>` to get the dashboard link.
5. Send the link to Tommy and ask for the Category G smoke test message.
6. Once smoke test passes, compile the full ready-check report (Categories A-H) and issue the final tenant classification.
