---
name: self-debug
description: Tools for picoclaw to inspect its own health, logs, and configuration.
license: MIT
metadata:
  author: keithy@consultant.com
  version: 1.0.0
---
# self-debug

Tools for picoclaw to inspect its own health, logs, and configuration.

## Actions via `debug.sh`

This skill uses a helper script `scripts/debug.sh` to provide cross-platform diagnostics.

**Usage:** `exec "scripts/debug.sh [action] [log_lines]"`

Service name is read from `$PICOCLAW_SERVICE_NAME` environment variable (defaults to `picoclaw`).

| Action | Description | Default Lines |
|---|---|---|
| `logs` | Fetches recent logs for the agent service. | 50 |
| `logs-errors`| Fetches only error logs for the agent service. | 50 |
| `service-status`| Checks the status of the agent service. | N/A |
| `config-status`| Shows the agent's configuration status (`picoclaw status`).| N/A |
| `config-safe` | Displays the config file with sensitive keys redacted. | N/A |

### Examples

- **Get latest logs:**
  `exec "skills/self-debug/scripts/debug.sh logs"`

- **Get 100 lines of logs:**
  `exec "skills/self-debug/scripts/debug.sh logs 100"`

- **Check service status:**
  `exec "skills/self-debug/scripts/debug.sh service-status"`

- **Show the sanitized configuration:**
  `exec "skills/self-debug/scripts/debug.sh config-safe"`

## Troubleshooting

- **Logs not showing?** Ensure the user is in the `systemd-journal` group: `sudo usermod -a -G systemd-journal $(whoami)`
- **Service inactive?** Use `systemctl --user start picoclaw` (systemd) or `launchctl bootstrap` (launchd).
- **Workspace issues?** Use `picoclaw status` to verify the current workspace path.

## Related Skills

- **self-service-systemd** - Install and manage picoclaw as a systemd service (Linux)
- **self-service-launchd** - Install and manage picoclaw as a launchd service (macOS)
- **self-service-runit** - Install and manage picoclaw as a runit service
