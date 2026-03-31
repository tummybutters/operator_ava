#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PRESET_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
export PATH="${HOME}/.local/bin:${PATH}"

install_brew_formula() {
  if ! command -v brew >/dev/null 2>&1; then
    return 1
  fi
  brew list "$1" >/dev/null 2>&1 || brew install "$1"
}

install_apt_package() {
  if ! command -v apt-get >/dev/null 2>&1; then
    return 1
  fi
  if command -v sudo >/dev/null 2>&1; then
    sudo apt-get update -y >/dev/null 2>&1 || true
    sudo apt-get install -y "$1"
  else
    apt-get update -y >/dev/null 2>&1 || true
    apt-get install -y "$1"
  fi
}

ensure_system_tool() {
  local cmd="$1"
  local brew_formula="$2"
  local apt_pkg="$3"
  if command -v "$cmd" >/dev/null 2>&1; then
    echo "$cmd already installed"
    return 0
  fi

  if install_brew_formula "$brew_formula"; then
    return 0
  fi

  if install_apt_package "$apt_pkg"; then
    return 0
  fi

  echo "Skipping ${cmd}; no supported package manager available"
  return 0
}

install_npm_global() {
  local cmd="$1"
  local pkg="$2"
  if command -v "$cmd" >/dev/null 2>&1; then
    echo "$cmd already installed"
    return 0
  fi

  echo "Installing ${pkg} into ${HOME}/.local ..."
  npm install -g "$pkg"
}

if [ -z "${NVM_DIR:-}" ]; then
  mkdir -p "${HOME}/.local"
  npm config set prefix "${HOME}/.local" >/dev/null
fi

if ! command -v playwright >/dev/null 2>&1; then
  echo "Installing playwright into ${HOME}/.local ..."
  npm install -g playwright
else
  echo "playwright already installed"
fi

if command -v playwright >/dev/null 2>&1; then
  echo "Ensuring Chromium browser is installed ..."
  DEBIAN_FRONTEND=noninteractive playwright install chromium --with-deps
fi

if command -v python3 >/dev/null 2>&1; then
  echo "Ensuring PDF form dependencies are installed ..."
  if ! python3 -m pip --version >/dev/null 2>&1; then
    echo "pip not found; installing python3-pip ..."
    if command -v sudo >/dev/null 2>&1; then
      sudo apt-get install -y python3-pip >/dev/null 2>&1
    else
      apt-get install -y python3-pip >/dev/null 2>&1
    fi
  fi
  python3 -m pip install --user pymupdf pypdf --break-system-packages
else
  echo "python3 not found; skipping PDF dependency install"
fi

echo "Ensuring default utility and media tooling is installed ..."
ensure_system_tool jq jq jq
ensure_system_tool rg ripgrep ripgrep
ensure_system_tool pandoc pandoc pandoc
ensure_system_tool ffmpeg ffmpeg ffmpeg
ensure_system_tool magick imagemagick imagemagick
ensure_system_tool yt-dlp yt-dlp yt-dlp

install_npm_global twilio twilio-cli
install_npm_global ngrok ngrok-cli

if [ "${INSTALL_GH_COPILOT:-0}" = "1" ]; then
  if command -v gh >/dev/null 2>&1; then
    gh extension list | rg -q '^github/gh-copilot\\s' \
      && gh extension upgrade github/gh-copilot \
      || gh extension install github/gh-copilot
  else
    echo "Skipping gh-copilot; gh is not installed"
  fi
else
  echo "Skipping optional gh-copilot install (set INSTALL_GH_COPILOT=1 to enable)"
fi

if [ "${INSTALL_BLENDER:-0}" = "1" ]; then
  ensure_system_tool blender blender blender
else
  echo "Skipping optional blender install (set INSTALL_BLENDER=1 to enable)"
fi

if [ "${SKIP_GWS:-0}" != "1" ]; then
  if ! command -v gws >/dev/null 2>&1; then
    echo "Installing Google Workspace CLI into ${HOME}/.local ..."
    npm install -g @googleworkspace/cli
  else
    echo "gws already installed"
  fi

  echo "Google Workspace CLI installed."
  echo "Auth is still tenant-specific."
  echo "Next manual steps when Google Workspace is used:"
  echo "  gws auth setup"
  echo "  gws auth login -s drive,gmail,calendar,docs,sheets"
else
  echo "Skipping Google Workspace CLI install (set SKIP_GWS=0 or unset to enable)"
fi

echo "Twilio CLI installed."
echo "Auth is still tenant-specific."
echo "Next manual steps when Twilio is used:"
echo "  twilio login"

echo
echo "Sandbox bootstrap complete."
echo "Next:"
echo "  ${PRESET_ROOT}/scripts/install-runtime.sh"
echo "  ${PRESET_ROOT}/scripts/apply-preset.sh"
