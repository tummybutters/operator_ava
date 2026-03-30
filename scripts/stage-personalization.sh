#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PRESET_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

usage() {
  cat <<'EOF' >&2
Usage: stage-personalization.sh <workspace-dir> --profile <file> [--intake <file>] [--transcript <file>]

Stages normalized onboarding files into a workspace and writes
onboarding/PERSONALIZE-WORKSPACE.md for the cloud agent to execute.
EOF
  exit 1
}

if [ "${1:-}" = "" ]; then
  usage
fi

WORKSPACE_DIR="$1"
shift

PROFILE_PATH=""
INTAKE_PATH=""
TRANSCRIPT_PATH=""

while [ "$#" -gt 0 ]; do
  case "$1" in
    --profile)
      PROFILE_PATH="${2:-}"
      shift 2
      ;;
    --intake)
      INTAKE_PATH="${2:-}"
      shift 2
      ;;
    --transcript)
      TRANSCRIPT_PATH="${2:-}"
      shift 2
      ;;
    *)
      usage
      ;;
  esac
done

if [ "${PROFILE_PATH}" = "" ]; then
  echo "--profile is required" >&2
  exit 1
fi

if [ ! -f "${PROFILE_PATH}" ]; then
  echo "Profile file not found: ${PROFILE_PATH}" >&2
  exit 1
fi

if ! jq . "${PROFILE_PATH}" >/dev/null 2>&1; then
  echo "Profile file is not valid JSON: ${PROFILE_PATH}" >&2
  exit 1
fi

if [ "${INTAKE_PATH}" != "" ] && [ ! -f "${INTAKE_PATH}" ]; then
  echo "Intake file not found: ${INTAKE_PATH}" >&2
  exit 1
fi

if [ "${TRANSCRIPT_PATH}" != "" ] && [ ! -f "${TRANSCRIPT_PATH}" ]; then
  echo "Transcript file not found: ${TRANSCRIPT_PATH}" >&2
  exit 1
fi

ONBOARDING_DIR="${WORKSPACE_DIR}/onboarding"
mkdir -p "${ONBOARDING_DIR}"

cp "${PROFILE_PATH}" "${ONBOARDING_DIR}/tenant-profile.json"

if [ "${INTAKE_PATH}" != "" ]; then
  cp "${INTAKE_PATH}" "${ONBOARDING_DIR}/intake.md"
fi

if [ "${TRANSCRIPT_PATH}" != "" ]; then
  cp "${TRANSCRIPT_PATH}" "${ONBOARDING_DIR}/transcript.md"
fi

cp "${PRESET_ROOT}/factory/PERSONALIZE-WORKSPACE.template.md" \
  "${ONBOARDING_DIR}/PERSONALIZE-WORKSPACE.md"

echo "Staged onboarding material into:"
echo "  ${ONBOARDING_DIR}"
echo "  - tenant-profile.json (required)"
if [ "${INTAKE_PATH}" != "" ]; then
  echo "  - intake.md"
fi
if [ "${TRANSCRIPT_PATH}" != "" ]; then
  echo "  - transcript.md"
fi
echo
echo "Next prompt for the cloud agent:"
echo "  Read onboarding/PERSONALIZE-WORKSPACE.md and execute it."
