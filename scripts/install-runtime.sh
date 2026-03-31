#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PRESET_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
export PATH="${HOME}/.local/bin:${PATH}"

if [ -z "${NVM_DIR:-}" ] && [ -d "${HOME}/.nvm" ]; then
  export NVM_DIR="${HOME}/.nvm"
fi

if [ -n "${NVM_DIR:-}" ] && [ -s "${NVM_DIR}/nvm.sh" ]; then
  # shellcheck disable=SC1090
  . "${NVM_DIR}/nvm.sh"
fi

NEMOCLAW_HOME="${NEMOCLAW_HOME:-${HOME}/NemoClaw}"
NEMOCLAW_REPO_URL="${NEMOCLAW_REPO_URL:-https://github.com/NVIDIA/NemoClaw.git}"
NEMOCLAW_REF="${NEMOCLAW_REF:-}"
OPENCLAW_NPM_SPEC="${OPENCLAW_NPM_SPEC:-openclaw@latest}"
RUN_NEMOCLAW_ONBOARD="${RUN_NEMOCLAW_ONBOARD:-0}"
NEMOCLAW_NON_INTERACTIVE="${NEMOCLAW_NON_INTERACTIVE:-1}"

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Missing required command: $1" >&2
    echo "Run ${PRESET_ROOT}/scripts/bootstrap-sandbox.sh first." >&2
    exit 1
  fi
}

apt_get_retry() {
  local max_attempts="${APT_RETRY_MAX_ATTEMPTS:-24}"
  local sleep_seconds="${APT_RETRY_SLEEP_SECONDS:-5}"
  local attempt=1

  while true; do
    if "$@"; then
      return 0
    fi

    local exit_code=$?
    if [ "${attempt}" -ge "${max_attempts}" ]; then
      return "${exit_code}"
    fi

    echo "apt/dpkg busy or not ready yet; retrying in ${sleep_seconds}s ..."
    attempt=$((attempt + 1))
    sleep "${sleep_seconds}"
  done
}

install_docker() {
  if command -v docker >/dev/null 2>&1; then
    echo "docker already installed"
    return 0
  fi

  echo "Installing Docker ..."
  curl -fsSL https://get.docker.com | sh
  if command -v systemctl >/dev/null 2>&1; then
    systemctl enable docker >/dev/null 2>&1 || true
    systemctl start docker >/dev/null 2>&1 || true
  fi
}

install_cloudflared() {
  if command -v cloudflared >/dev/null 2>&1; then
    echo "cloudflared already installed"
    return 0
  fi

  if ! command -v apt-get >/dev/null 2>&1; then
    echo "cloudflared installation currently supports apt-based hosts only" >&2
    exit 1
  fi

  if ! command -v gpg >/dev/null 2>&1 || ! command -v lsb_release >/dev/null 2>&1; then
    echo "gpg and lsb_release are required to install cloudflared" >&2
    exit 1
  fi

  echo "Installing cloudflared ..."
  curl -fsSL https://pkg.cloudflare.com/cloudflare-main.gpg \
    | gpg --dearmor --batch --yes -o /usr/share/keyrings/cloudflare-main.gpg
  echo "deb [signed-by=/usr/share/keyrings/cloudflare-main.gpg] https://pkg.cloudflare.com/cloudflared $(lsb_release -cs) main" \
    > /etc/apt/sources.list.d/cloudflared.list
  apt_get_retry apt-get update -y >/dev/null
  apt_get_retry env DEBIAN_FRONTEND=noninteractive apt-get install -y cloudflared
}

install_openclaw() {
  if command -v openclaw >/dev/null 2>&1; then
    echo "openclaw already installed"
    return 0
  fi

  echo "Installing ${OPENCLAW_NPM_SPEC} ..."
  npm install -g "${OPENCLAW_NPM_SPEC}"
}

sync_nemoclaw_repo() {
  if [ -d "${NEMOCLAW_HOME}/.git" ]; then
    echo "Updating NemoClaw at ${NEMOCLAW_HOME} ..."
    git -C "${NEMOCLAW_HOME}" fetch --all --tags --prune
  else
    echo "Cloning NemoClaw into ${NEMOCLAW_HOME} ..."
    git clone "${NEMOCLAW_REPO_URL}" "${NEMOCLAW_HOME}"
  fi

  if [ -n "${NEMOCLAW_REF}" ]; then
    git -C "${NEMOCLAW_HOME}" checkout "${NEMOCLAW_REF}"
  else
    git -C "${NEMOCLAW_HOME}" checkout main >/dev/null 2>&1 || true
    git -C "${NEMOCLAW_HOME}" pull --ff-only >/dev/null 2>&1 || true
  fi
}

install_nemoclaw_deps() {
  echo "Installing NemoClaw dependencies ..."
  (
    cd "${NEMOCLAW_HOME}"
    npm install
  )
}

write_nemoclaw_wrapper() {
  local wrapper_path="${HOME}/.local/bin/nemoclaw"
  mkdir -p "${HOME}/.local/bin"
  cat > "${wrapper_path}" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

if [ -z "${NVM_DIR:-}" ] && [ -d "${HOME}/.nvm" ]; then
  export NVM_DIR="${HOME}/.nvm"
fi

if [ -n "${NVM_DIR:-}" ] && [ -s "${NVM_DIR}/nvm.sh" ]; then
  # shellcheck disable=SC1090
  . "${NVM_DIR}/nvm.sh"
fi

NEMOCLAW_HOME="${NEMOCLAW_HOME:-${HOME}/NemoClaw}"
exec node "${NEMOCLAW_HOME}/bin/nemoclaw.js" "$@"
EOF
  chmod +x "${wrapper_path}"
}

verify_runtime_tools() {
  echo "Verifying runtime tooling ..."
  openclaw --help >/dev/null
  node "${NEMOCLAW_HOME}/bin/nemoclaw.js" --help >/dev/null
  nemoclaw --help >/dev/null
}

maybe_onboard_runtime() {
  if [ "${RUN_NEMOCLAW_ONBOARD}" != "1" ]; then
    echo "Skipping nemoclaw onboard (set RUN_NEMOCLAW_ONBOARD=1 to enable)."
    return 0
  fi

  if [ -z "${NEMOCLAW_PROVIDER:-}" ] || [ -z "${NEMOCLAW_MODEL:-}" ]; then
    echo "RUN_NEMOCLAW_ONBOARD=1 requires NEMOCLAW_PROVIDER and NEMOCLAW_MODEL." >&2
    echo "Provide provider-specific auth env vars as well, then re-run." >&2
    exit 1
  fi

  echo "Running non-interactive nemoclaw onboard ..."
  export NEMOCLAW_NON_INTERACTIVE
  nemoclaw onboard
}

require_cmd git
require_cmd node
require_cmd npm
require_cmd curl

install_docker
install_cloudflared
install_openclaw
sync_nemoclaw_repo
install_nemoclaw_deps
write_nemoclaw_wrapper
verify_runtime_tools
maybe_onboard_runtime

echo
echo "Runtime install complete."
echo "  OpenClaw CLI: $(command -v openclaw)"
echo "  NemoClaw home: ${NEMOCLAW_HOME}"
echo "  NemoClaw wrapper: $(command -v nemoclaw)"
echo
echo "Next:"
echo "  ${PRESET_ROOT}/scripts/apply-preset.sh"
echo "  ${PRESET_ROOT}/scripts/run-openclaw.sh"
