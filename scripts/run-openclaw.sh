#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CANONICAL_STATE_DIR="/sandbox/.openclaw"
RUNTIME_DATA_ROOT="/sandbox/.openclaw-data"
DEPRECATED_STATE_DIR="/sandbox/.openclaw-sandlers"

STATE_DIR="${OPENCLAW_STATE_DIR:-${CANONICAL_STATE_DIR}}"
CONFIG_PATH="${OPENCLAW_CONFIG_PATH:-${STATE_DIR}/openclaw.json}"

export OPENCLAW_STATE_DIR="${STATE_DIR}"
export OPENCLAW_CONFIG_PATH="${CONFIG_PATH}"
export PATH="${HOME}/.local/bin:${PATH}"

if [ -z "${NVM_DIR:-}" ] && [ -d "${HOME}/.nvm" ]; then
  export NVM_DIR="${HOME}/.nvm"
fi

if [ -n "${NVM_DIR:-}" ] && [ -s "${NVM_DIR}/nvm.sh" ]; then
  # shellcheck disable=SC1090
  . "${NVM_DIR}/nvm.sh"
fi

if [ "${STATE_DIR}" = "${DEPRECATED_STATE_DIR}" ]; then
  echo "Warning: ${DEPRECATED_STATE_DIR} is deprecated and should only be used for migration or repair flows." >&2
fi

echo "Launching OpenClaw with:"
echo "  Canonical state dir: ${STATE_DIR}"
echo "  Canonical config: ${CONFIG_PATH}"
echo "  Runtime-owned data root: ${RUNTIME_DATA_ROOT}"

if [ ! -f "${CONFIG_PATH}" ]; then
  "${SCRIPT_DIR}/apply-preset.sh" "${STATE_DIR}"
fi

if ! command -v openclaw >/dev/null 2>&1; then
  echo "openclaw is not installed or not on PATH." >&2
  echo "Run ${SCRIPT_DIR}/install-runtime.sh first." >&2
  exit 1
fi

exec openclaw tui
