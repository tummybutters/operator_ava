#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

STATE_DIR="${OPENCLAW_STATE_DIR:-/sandbox/.openclaw-sandlers}"
CONFIG_PATH="${OPENCLAW_CONFIG_PATH:-${STATE_DIR}/openclaw.json}"

export OPENCLAW_STATE_DIR="${STATE_DIR}"
export OPENCLAW_CONFIG_PATH="${CONFIG_PATH}"
export PATH="${HOME}/.local/bin:${PATH}"

if [ ! -f "${CONFIG_PATH}" ]; then
  "${SCRIPT_DIR}/apply-preset.sh" "${STATE_DIR}"
fi

exec openclaw tui
