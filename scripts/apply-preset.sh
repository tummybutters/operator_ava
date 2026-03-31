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
WORKSPACE_ALREADY_EXISTS=0

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
  WORKSPACE_ALREADY_EXISTS=1
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
if [ "${WORKSPACE_ALREADY_EXISTS}" -eq 1 ]; then
  echo "Preserving tenant-specific workspace files during re-apply"
  rsync -a \
    --exclude 'USER.md' \
    --exclude 'TOOLS.md' \
    --exclude 'MEMORY.md' \
    --exclude 'IDENTITY.md' \
    --exclude 'HEARTBEAT.md' \
    --exclude 'onboarding/' \
    --exclude 'state/tasks.json' \
    --exclude 'state/today.json' \
    --exclude 'state/business.json' \
    --exclude 'state/workflows.json' \
    "${PRESET_ROOT}/workspace/" "${WORKSPACE_DIR}/"
else
  cp -R "${PRESET_ROOT}/workspace/." "${WORKSPACE_DIR}/"
fi

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

seed_initial_model_config() {
  local default_model="${OPENCLAW_DEFAULT_MODEL:-}"
  local openrouter_api_key="${OPENROUTER_API_KEY:-}"

  if [ -z "${openrouter_api_key}" ] && [ -n "${OPENROUTER_API_KEY_FILE:-}" ] && [ -f "${OPENROUTER_API_KEY_FILE}" ]; then
    openrouter_api_key="$(tr -d '\r\n' < "${OPENROUTER_API_KEY_FILE}")"
  fi

  if [ -n "${openrouter_api_key}" ]; then
    openclaw config set env.OPENROUTER_API_KEY "${openrouter_api_key}"
    echo "Seeded env.OPENROUTER_API_KEY for OpenRouter"
  fi

  if [ -n "${default_model}" ]; then
    openclaw models set "${default_model}"
    echo "Set default model: ${default_model}"
  fi
}

if command -v openclaw >/dev/null 2>&1; then
  openclaw config set agents.defaults.workspace "${WORKSPACE_DIR}"
  openclaw config set agents.defaults.skipBootstrap true --strict-json
  openclaw config set tools.exec.host gateway
  openclaw config set tools.exec.security full
  openclaw config set tools.exec.ask off
  openclaw config set tools.exec.pathPrepend '["/root/.local/bin"]' --strict-json
  seed_initial_model_config
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
