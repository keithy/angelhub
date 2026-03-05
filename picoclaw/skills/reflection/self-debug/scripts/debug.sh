#!/bin/sh

picoclaw_plugin_init() {
    # Try to find picoclaw-manager or picoclaw in PATH
    if command -v picoclaw 2>/dev/null; then
        PICOCLAW_MANAGER='picoclaw'
    fi

    if command -v picoclaw-manager 2>/dev/null; then
        PICOCLAW_MANAGER='picoclaw-manager'
    fi

    [ -z "${PICOCLAW_MANAGER:-}" ] && echo "Picoclaw plugin handler not found" && exit 1

    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    export PICOCLAW_SERVICE_NAME="${PICOCLAW_SERVICE_NAME:-picoclaw}"
    export PICOCLAW_CONFIG="${PICOCLAW_CONFIG:-$HOME/.picoclaw/config.json}"
    export PICOCLAW_HOME="${PICOCLAW_HOME:-${PICOCLAW_CONFIG%/*}}"
}

picoclaw_plugin_init

assert_is_identifier ()
{
  if ! echo "$1" | grep -qE '^[a-zA-Z0-9_.-]+$';
  then
    echo "Error: $2" >&2
    return 1
  fi
}

assert_is_number ()
{
    if ! echo "$1" | grep -qE '^[0-9]+$';
    then
        echo "Error: $2" >&2
        return 1
    fi
}

assert_is_identifier "$1" "Action selector must be a simple identifier" || exit 1

case "$1" in
    logs)
        LOG_N="${2:-50}"
        assert_is_number "$LOG_N" "Log lines parameter must be numeric" || exit 1
        "$PICOCLAW_MANAGER" service logs "$LOG_N"
        ;;
    logs-errors)
        LOG_N="${2:-50}"
        assert_is_number "$LOG_N" "Log lines parameter must be numeric" || exit 1
        "$PICOCLAW_MANAGER" service logs-errors "$LOG_N"
        ;;
    service-status)
        "$PICOCLAW_MANAGER" service status
        ;;
    config-status)
        picoclaw status
        ;;
    config-safe)
        jq 'walk(if type == "object" then with_entries(if .key | ascii_downcase |
            (contains("key") or contains("token") or contains("secret") or contains("pass")) 
            then .value = "REDACTED" else . end) else . end)' "${PICOCLAW_CONFIG}"
        ;;
    *)
        echo "Usage: $0 logs|logs-errors|service-status|config-status|config-safe [n_lines]"
        exit 1
        ;;
esac
