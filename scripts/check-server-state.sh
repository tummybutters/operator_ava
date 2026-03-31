#!/usr/bin/env bash
# Runs locally (operator machine).
# SSH into a server and print a quick inventory of factory-relevant state.
# Use before deciding whether to wipe, rebuild, or proceed fresh.
#
# Usage: ./scripts/check-server-state.sh <server-ip>

set -euo pipefail

if [ -z "${1:-}" ]; then
  echo "Usage: $0 <server-ip>" >&2
  exit 1
fi

SERVER_IP="$1"

ssh -o ConnectTimeout=10 root@"${SERVER_IP}" '
echo "=== host ===" && hostname
echo "=== os ===" && . /etc/os-release && echo "$PRETTY_NAME"
echo "=== node ===" && (command -v node >/dev/null 2>&1 && node --version || echo "not installed")
echo "=== nvm ===" && ([ -d ~/.nvm ] && echo "installed" || echo "not installed")
echo "=== openclaw ===" && (command -v openclaw >/dev/null 2>&1 && openclaw --version 2>/dev/null | head -1 || echo "not installed")
echo "=== NemoClaw ===" && ([ -d ~/NemoClaw ] && git -C ~/NemoClaw log --oneline -1 2>/dev/null || echo "not present")
echo "=== cloudflared ===" && (command -v cloudflared >/dev/null 2>&1 && cloudflared --version 2>/dev/null | head -1 || echo "not installed")
echo "=== operator_ava ===" && ([ -d ~/operator_ava ] && git -C ~/operator_ava log --oneline -1 || echo "not present")
echo "=== /sandbox/.openclaw ===" && ([ -d /sandbox/.openclaw ] && echo "exists" || echo "absent")
echo "=== /sandbox/.openclaw/workspace ===" && ([ -d /sandbox/.openclaw/workspace ] && echo "exists" || echo "absent")
'
