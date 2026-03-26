#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PRESET_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

STATE_DIR="${1:-/sandbox/.openclaw-sandlers}"
WORKSPACE_DIR="${2:-${STATE_DIR}/workspace}"
CONFIG_PATH="${STATE_DIR}/openclaw.json"

mkdir -p "${STATE_DIR}" "${WORKSPACE_DIR}"

echo "Applying workspace into ${WORKSPACE_DIR}"
cp -R "${PRESET_ROOT}/workspace/." "${WORKSPACE_DIR}/"

if [ ! -f "${CONFIG_PATH}" ]; then
  cp "${PRESET_ROOT}/config/openclaw.base.json5" "${CONFIG_PATH}"
fi

export OPENCLAW_STATE_DIR="${STATE_DIR}"
export OPENCLAW_CONFIG_PATH="${CONFIG_PATH}"
export PATH="${HOME}/.local/bin:${PATH}"

if command -v openclaw >/dev/null 2>&1; then
  openclaw config set agents.defaults.workspace "${WORKSPACE_DIR}"
  openclaw config set agents.defaults.skipBootstrap true --strict-json
  openclaw config set tools.exec.pathPrepend '["/sandbox/.local/bin"]' --strict-json
else
  echo "openclaw not found on PATH; copied files only"
fi

echo
echo "Preset applied."
echo "State dir: ${STATE_DIR}"
echo "Workspace: ${WORKSPACE_DIR}"
echo "Config: ${CONFIG_PATH}"
