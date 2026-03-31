#!/usr/bin/env bash
# Runs locally (operator machine).
# Clears stale known_hosts entry for a server IP and verifies SSH connectivity.
# Use before any factory run targeting a rebuilt or unfamiliar server.
#
# Usage: ./scripts/prep-ssh.sh <server-ip>

set -euo pipefail

if [ -z "${1:-}" ]; then
  echo "Usage: $0 <server-ip>" >&2
  exit 1
fi

SERVER_IP="$1"

echo "Removing stale known_hosts entries for ${SERVER_IP} ..."
ssh-keygen -R "${SERVER_IP}" 2>/dev/null || true

echo "Scanning new host key ..."
ssh-keyscan -H "${SERVER_IP}" >> ~/.ssh/known_hosts 2>/dev/null

echo "Testing connectivity ..."
ssh -o ConnectTimeout=10 root@"${SERVER_IP}" 'echo "SSH OK: $(hostname)"'

echo "SSH ready for ${SERVER_IP}"
