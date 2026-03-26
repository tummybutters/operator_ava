#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PRESET_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

if [ "${1:-}" = "" ]; then
  echo "Usage: $0 <tenant-slug> [target-dir]" >&2
  exit 1
fi

TENANT_SLUG="$1"
TARGET_DIR="${2:-$(cd "${PRESET_ROOT}/.." && pwd)/${TENANT_SLUG}}"

if [ -e "${TARGET_DIR}" ]; then
  echo "Target already exists: ${TARGET_DIR}" >&2
  exit 1
fi

mkdir -p "${TARGET_DIR}"

for path in README.md .gitignore config factory scripts workspace; do
  cp -R "${PRESET_ROOT}/${path}" "${TARGET_DIR}/${path}"
done

mkdir -p "${TARGET_DIR}/workspace/onboarding"

echo "Created tenant project:"
echo "  ${TARGET_DIR}"
echo
echo "Next:"
echo "  1. cd ${TARGET_DIR}"
echo "  2. initialize git or create a fork/project repo"
echo "  3. run scripts/bootstrap-sandbox.sh and scripts/apply-preset.sh in the target environment"
