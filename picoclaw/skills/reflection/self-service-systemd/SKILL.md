---
name: self-service-systemd
description: Install and manage picoclaw as a systemd service on Linux.
license: MIT
metadata:
  author: keithy@consultant.com
  version: 1.0.0
---

# self-service-systemd

Install and manage picoclaw as a systemd user service on Linux.

## Installation

```bash
exec "scripts/install-service-systemd.sh [service_name] [default|multi]"
```

### Arguments

| Argument | Description | Default |
|----------|-------------|---------|
| `service_name` | Name of the service | `picoclaw` |
| `template` | Template to use: `default` (single instance) or `multi` (multiple instances) | `default` |

### Examples

```bash
# Install single service
exec "skills/self-service-systemd/scripts/install-service-systemd.sh picoclaw"

# Install with multi-instance template
exec "skills/self-service-systemd/scripts/install-service-systemd.sh picoclaw multi"
```

## Service Management

### Start/Stop/Restart

```bash
# Start the service
systemctl --user start picoclaw

# Stop the service
systemctl --user stop picoclaw

# Restart the service
systemctl --user restart picoclaw

# Enable on boot
systemctl --user enable picoclaw

# Disable on boot
systemctl --user disable picoclaw
```

### View Status

```bash
# Check service status
systemctl --user status picoclaw

# Check if service is active
systemctl --user is-active picoclaw

# Check if service is enabled
systemctl --user is-enabled picoclaw
```

### View Logs

```bash
# View logs (real-time)
journalctl --user-unit picoclaw -f

# View last 50 lines
journalctl --user-unit picoclaw -n 50

# View only errors
journalctl --user-unit picoclaw -p err

# View logs since specific time
journalctl --user-unit picoclaw --since "1 hour ago"
```

### Multi-Instance

For multiple picoclaw instances (e.g., different configurations):

```bash
# Install multi-instance template
exec "skills/self-service-systemd/scripts/install-service-systemd.sh picoclaw multi"

# Start instance named 'test'
systemctl --user start picoclaw@test

# Start instance named 'prod'
systemctl --user start picoclaw@prod

# View logs for specific instance
journalctl --user-unit picoclaw@test -f
```

## Troubleshooting

### Logs not showing?

Ensure the user is in the `systemd-journal` group:

```bash
sudo usermod -a -G systemd-journal $(whoami)
```

### Service inactive?

```bash
systemctl --user start picoclaw
journalctl --user-unit picoclaw -e
```

### Service won't start on boot?

Enable linger for your user:

```bash
sudo loginctl enable-linger $(whoami)
```

## Requirements

- Linux with systemd
- User must have permission to run user services

## Skills Used

- `self-debug` - For viewing logs and diagnosing issues
