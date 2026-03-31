#!/usr/bin/env bash
# Runs on the server.
# Reads the gateway auth token from config and prints the full dashboard handoff URL.
#
# Usage: ./scripts/get-dashboard-url.sh <public-gateway-host>
# Example: ./scripts/get-dashboard-url.sh marble-buffalo-acc-vector.trycloudflare.com

set -euo pipefail

export PATH="${HOME}/.local/bin:${PATH}"

if [ -z "${1:-}" ]; then
  echo "Usage: $0 <public-gateway-host>" >&2
  echo "  e.g. $0 marble-buffalo-acc-vector.trycloudflare.com" >&2
  exit 1
fi

GATEWAY_HOST="$1"
STATE_DIR="${OPENCLAW_STATE_DIR:-/sandbox/.openclaw}"
CONFIG_PATH="${STATE_DIR}/openclaw.json"

if [ ! -f "${CONFIG_PATH}" ]; then
  echo "Config not found: ${CONFIG_PATH}" >&2
  exit 1
fi

TOKEN="$(python3 -c "
import json, sys
c = json.load(open('${CONFIG_PATH}'))
t = c.get('gateway', {}).get('auth', {}).get('token', '')
if not t:
    sys.exit(1)
print(t)
")"

DASHBOARD_ALIAS="$(python3 -c "
import json
c = json.load(open('${CONFIG_PATH}'))
origins = c.get('gateway', {}).get('controlUi', {}).get('allowedOrigins', [])
print(origins[0].rstrip('/') if origins else 'https://broker-dashboard-flax.vercel.app')
")"

echo "${DASHBOARD_ALIAS}#gateway=wss://${GATEWAY_HOST}&token=${TOKEN}"
