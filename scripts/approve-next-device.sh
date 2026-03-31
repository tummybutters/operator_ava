#!/usr/bin/env bash
# Runs on the server.
# Polls for a pending device pairing request and approves the first one found.
# Use after starting the gateway when a browser is waiting at "activating workspace".
#
# Usage: ./scripts/approve-next-device.sh [timeout-seconds]
# Default timeout: 120 seconds

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export PATH="${HOME}/.local/bin:${PATH}"

if [ -z "${NVM_DIR:-}" ] && [ -d "${HOME}/.nvm" ]; then
  export NVM_DIR="${HOME}/.nvm"
fi
if [ -n "${NVM_DIR:-}" ] && [ -s "${NVM_DIR}/nvm.sh" ]; then
  # shellcheck disable=SC1090
  . "${NVM_DIR}/nvm.sh"
fi

TIMEOUT="${1:-120}"
STATE_DIR="${OPENCLAW_STATE_DIR:-/sandbox/.openclaw}"
ELAPSED=0
INTERVAL=5

echo "Watching for pending device pairing requests (timeout: ${TIMEOUT}s) ..."

while [ "${ELAPSED}" -lt "${TIMEOUT}" ]; do
  PENDING_ID="$(
    OPENCLAW_STATE_DIR="${STATE_DIR}" openclaw devices list --json 2>/dev/null \
      | python3 -c "import sys,json; d=json.load(sys.stdin); reqs=d.get('pending',[]); print(reqs[0]['requestId'] if reqs else '')" 2>/dev/null \
      || true
  )"

  if [ -n "${PENDING_ID}" ]; then
    echo "Approving request ${PENDING_ID} ..."
    OPENCLAW_STATE_DIR="${STATE_DIR}" openclaw devices approve "${PENDING_ID}"
    echo "Done. Browser should connect within a few seconds."
    exit 0
  fi

  sleep "${INTERVAL}"
  ELAPSED=$((ELAPSED + INTERVAL))
done

echo "No pending device request found within ${TIMEOUT}s." >&2
exit 1
