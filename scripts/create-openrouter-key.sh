#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  create-openrouter-key.sh --name <name> [options]

Required:
  --name <name>                 Human-readable child-key name

Optional:
  --admin-key <key>            OpenRouter management key (defaults to OPENROUTER_ADMIN_KEY)
  --limit <usd>                Spending limit in USD
  --limit-reset <period>       daily | weekly | monthly
  --expires-at <utc-iso8601>   Expiry timestamp, e.g. 2026-12-31T23:59:59Z
  --include-byok-in-limit      Count BYOK usage against the limit
  --out <path>                 Write the raw child key to a file
  --json-out <path>            Write the full API response JSON to a file
  --print-key                  Print the raw child key to stdout

Examples:
  OPENROUTER_ADMIN_KEY=... ./scripts/create-openrouter-key.sh --name sandlers-factory-test-001 --out /tmp/openrouter.key
  OPENROUTER_ADMIN_KEY=... ./scripts/create-openrouter-key.sh --name acme --limit 50 --limit-reset monthly --expires-at 2026-12-31T23:59:59Z
EOF
}

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Missing required command: $1" >&2
    exit 1
  fi
}

NAME=""
ADMIN_KEY="${OPENROUTER_ADMIN_KEY:-}"
LIMIT=""
LIMIT_RESET=""
EXPIRES_AT=""
INCLUDE_BYOK_IN_LIMIT=0
OUT_PATH=""
JSON_OUT_PATH=""
PRINT_KEY=0

while [ $# -gt 0 ]; do
  case "$1" in
    --name)
      NAME="${2:-}"
      shift 2
      ;;
    --admin-key)
      ADMIN_KEY="${2:-}"
      shift 2
      ;;
    --limit)
      LIMIT="${2:-}"
      shift 2
      ;;
    --limit-reset)
      LIMIT_RESET="${2:-}"
      shift 2
      ;;
    --expires-at)
      EXPIRES_AT="${2:-}"
      shift 2
      ;;
    --include-byok-in-limit)
      INCLUDE_BYOK_IN_LIMIT=1
      shift
      ;;
    --out)
      OUT_PATH="${2:-}"
      shift 2
      ;;
    --json-out)
      JSON_OUT_PATH="${2:-}"
      shift 2
      ;;
    --print-key)
      PRINT_KEY=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

if [ -z "${NAME}" ]; then
  echo "Missing required --name" >&2
  usage >&2
  exit 1
fi

if [ -z "${ADMIN_KEY}" ]; then
  echo "Missing OpenRouter management key. Set OPENROUTER_ADMIN_KEY or pass --admin-key." >&2
  exit 1
fi

require_cmd curl
require_cmd jq

payload="$(
  jq -n \
    --arg name "${NAME}" \
    --arg limit "${LIMIT}" \
    --arg limit_reset "${LIMIT_RESET}" \
    --arg expires_at "${EXPIRES_AT}" \
    --argjson include_byok_in_limit "$( [ "${INCLUDE_BYOK_IN_LIMIT}" = "1" ] && printf 'true' || printf 'false' )" \
    '
    {
      name: $name
    }
    + (if $limit != "" then { limit: ($limit | tonumber) } else {} end)
    + (if $limit_reset != "" then { limit_reset: $limit_reset } else {} end)
    + (if $expires_at != "" then { expires_at: $expires_at } else {} end)
    + (if $include_byok_in_limit then { include_byok_in_limit: true } else {} end)
    '
)"

response="$(
  curl -fsS https://openrouter.ai/api/v1/keys \
    -H "Authorization: Bearer ${ADMIN_KEY}" \
    -H "Content-Type: application/json" \
    -d "${payload}"
)"

child_key="$(printf '%s' "${response}" | jq -r '.key')"
label="$(printf '%s' "${response}" | jq -r '.data.label // empty')"
hash="$(printf '%s' "${response}" | jq -r '.data.hash // empty')"

if [ -z "${child_key}" ] || [ "${child_key}" = "null" ]; then
  echo "OpenRouter did not return a child key." >&2
  printf '%s\n' "${response}" >&2
  exit 1
fi

if [ -n "${JSON_OUT_PATH}" ]; then
  mkdir -p "$(dirname "${JSON_OUT_PATH}")"
  printf '%s\n' "${response}" > "${JSON_OUT_PATH}"
fi

if [ -n "${OUT_PATH}" ]; then
  mkdir -p "$(dirname "${OUT_PATH}")"
  umask 077
  printf '%s\n' "${child_key}" > "${OUT_PATH}"
fi

echo "Created OpenRouter child key:"
echo "  Name: ${NAME}"
[ -n "${label}" ] && echo "  Label: ${label}"
[ -n "${hash}" ] && echo "  Hash: ${hash}"
if [ -n "${OUT_PATH}" ]; then
  echo "  Key file: ${OUT_PATH}"
else
  echo "  Key: ${child_key%%${child_key#????????}}..."
fi
if [ -n "${JSON_OUT_PATH}" ]; then
  echo "  Metadata file: ${JSON_OUT_PATH}"
fi

if [ "${PRINT_KEY}" = "1" ]; then
  printf '%s\n' "${child_key}"
fi
