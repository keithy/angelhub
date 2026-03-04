#!/bin/bash

# service.sh - Service management with auto-rollback support
# A "dead man's switch" for configuration changes.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Validate identifier (alphanumeric, dash, underscore)
assert_is_identifier() {
    if ! echo "$1" | grep -qE '^[a-zA-Z_][a-zA-Z0-9_-]*$'; then
        echo "Error: $2" >&2
        return 1
    fi
}

assert_is_number ()
{
    # Use grep for robust, portable POSIX regex matching.
    if ! echo "$1" | grep -qE '^[0-9]+$';
    then
        echo "Error: $2" >&2
        return 1
    fi
}

SERVICE_NAME="${PICOCLAW_SERVICE_NAME:-picoclaw}"

# Service management function - can be sourced by other scripts
service_restart() {
    local service="${1:-$SERVICE_NAME}"
    echo "Restarting service: $service"
    systemctl --user restart "$service"
    echo "Done."
}

# Only run main logic when executed (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then

COMMAND="${1:-help}"
assert_is_identifier "$COMMAND" "Action must be a valid identifier" || exit 1

SERVICE="${2:-$SERVICE_NAME}"
assert_is_identifier "$SERVICE" "Service name must be a valid identifier" || exit 1

CONFIG="${PICOCLAW_CONFIG:-$HOME/.picoclaw/config.json}"

[[ -n "$CONFIG" ]] && ! [[ -f "$CONFIG" ]] && echo "Expected file" && exit 1

case "$COMMAND" in

    restart)

        service_restart "$SERVICE"
    ;;

    _rollback)
        # Use argument directly - always passed by caller
        CONFIG="$3"
        
        # Check if marker file exists (auto-rollback was set)
        MARKER="${CONFIG}-PENDING-ROLLBACK"

        if [ ! -f "$MARKER" ]; then
            # No marker = nothing to rollback = success
            exit 0
        fi
    
        # Marker exists - perform rollback
        rm -f "$MARKER"
    
        "$SCRIPT_DIR/config.sh" rollback "$CONFIG"

        echo "[ROLLBACK] Restarting service: $SERVICE"
        service_restart "$SERVICE" || true
        echo "Rollback complete."

    ;;

    restart-with-auto-rollback)

        TIMEOUT="${4:-${TIMEOUT:-120}}"
        assert_is_number "$TIMEOUT" "Timer must be number of seconds" || exit 1

        # Create marker file
        MARKER="${CONFIG}-PENDING-ROLLBACK"
        
        # Restart service first
        service_restart "$SERVICE"
        
        echo "Auto-rollback armed for $SERVICE (timeout: ${TIMEOUT}s)"
        echo "Marker: $MARKER"
        
        # Start background timer
        (
            sleep "$TIMEOUT"
            if [ -f "$MARKER" ]; then
                echo "[TIMEOUT] Auto-rollback triggered for $SERVICE"
                bash "$0" _rollback "$SERVICE" "$CONFIG"
            fi
        ) &
        TIMER_PID=$!

        {        
            echo "Timer PID: $TIMER_PID"
            echo "----------------------------------------------------"
            echo "Service will ROLLBACK in $TIMEOUT seconds if not confirmed."
            echo "To confirm: service.sh cancel-auto-rollback $SERVICE"
            echo "----------------------------------------------------"
        } | tee "$MARKER"

    ;;

    cancel-auto-rollback)

        MARKER="${CONFIG}-PENDING-ROLLBACK"
            
        if [ -n "$MARKER" ] && [ -f "$MARKER" ]; then
            rm -f "$MARKER"
            echo "Rollback cancelled. Changes confirmed."
        else
            echo "No pending rollback to cancel."
        fi
    
    ;;

    help)
        echo "Usage: $0 <command> [args...]"
        echo ""
        echo "Commands:"
        echo "  restart [service]           Restart service (default: \$PICOCLAW_SERVICE_NAME or picoclaw)"
        echo "  restart-with-auto-rollback [service] [config] [timeout]"
        echo "                              Arm rollback timer, restart service"
        echo "  cancel-auto-rollback [service] [config]"
        echo "  _rollback [service] [config]"
        echo "                              Internal: check marker, rollback if present"
        echo ""
        echo "Environment:"
        echo "  PICOCLAW_SERVICE_NAME       Default service name (default: picoclaw)"
        echo "  PICOCLAW_CONFIG             Default config file  (default: ~/.picoclaw/config.json)"
        exit 0
        ;;

    *)
        echo "Unknown command: $COMMAND"
        echo "Run '$0 help' for usage."
        exit 1
        ;;
esac

fi  # End sourced execution guard
