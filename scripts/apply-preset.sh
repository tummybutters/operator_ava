#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PRESET_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
CANONICAL_STATE_DIR="/sandbox/.openclaw"
RUNTIME_DATA_ROOT="/sandbox/.openclaw-data"
DEPRECATED_STATE_DIR="/sandbox/.openclaw-sandlers"

default_state_dir() {
  printf '%s\n' "${CANONICAL_STATE_DIR}"
}

STATE_DIR="${1:-$(default_state_dir)}"
WORKSPACE_DIR="${2:-${STATE_DIR}/workspace}"
CONFIG_PATH="${STATE_DIR}/openclaw.json"
BACKUP_ROOT="${STATE_DIR}/backups"
STAMP="$(date +%Y%m%d-%H%M%S)"

if [ "${STATE_DIR}" = "${DEPRECATED_STATE_DIR}" ]; then
  echo "Warning: ${DEPRECATED_STATE_DIR} is deprecated and should only be used for migration or repair flows." >&2
fi

echo "Resolved preset targets:"
echo "  Canonical state dir: ${STATE_DIR}"
echo "  Canonical workspace: ${WORKSPACE_DIR}"
echo "  Canonical config: ${CONFIG_PATH}"
echo "  Runtime-owned data root: ${RUNTIME_DATA_ROOT}"

mkdir -p "${STATE_DIR}" "${WORKSPACE_DIR}"

if [ -d "${WORKSPACE_DIR}" ] && [ "$(ls -A "${WORKSPACE_DIR}" 2>/dev/null)" != "" ]; then
  mkdir -p "${BACKUP_ROOT}"
  BACKUP_DIR="${BACKUP_ROOT}/preset-apply-${STAMP}"
  mkdir -p "${BACKUP_DIR}"
  echo "Backing up existing workspace to ${BACKUP_DIR}"
  cp -R "${WORKSPACE_DIR}" "${BACKUP_DIR}/workspace"
  if [ -f "${CONFIG_PATH}" ]; then
    cp "${CONFIG_PATH}" "${BACKUP_DIR}/openclaw.json"
  fi
fi

echo "Applying workspace into ${WORKSPACE_DIR}"
cp -R "${PRESET_ROOT}/workspace/." "${WORKSPACE_DIR}/"

if [ ! -f "${CONFIG_PATH}" ]; then
  cp "${PRESET_ROOT}/config/openclaw.base.json5" "${CONFIG_PATH}"
fi

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
echo "Runtime data root: ${RUNTIME_DATA_ROOT}"
if [ -n "${BACKUP_DIR:-}" ]; then
  echo "Backup: ${BACKUP_DIR}"
fi
