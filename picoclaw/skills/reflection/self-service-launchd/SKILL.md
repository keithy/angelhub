---
name: self-service-launchd
description: Install and manage picoclaw as a launchd service on macOS.
license: MIT
metadata:
  author: keithy@consultant.com
  version: 1.0.0
  status: untested
---

# self-service-launchd

Install and manage picoclaw as a launchd service on macOS.

## Installation

```bash
exec "scripts/install-service-launchd.sh [service_name]"
```

### Arguments

| Argument | Description | Default |
|----------|-------------|---------|
| `service_name` | Name of the service | `picoclaw` |

### Examples

```bash
# Install service
exec "skills/self-service-launchd/scripts/install-service-launchd.sh picoclaw"
```

## Service Management

### Start/Stop/Restart

```bash
# Load (enable) the service
launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/picoclaw.plist

# Unload (disable) the service
launchctl bootout gui/$(id -u) ~/Library/LaunchAgents/picoclaw.plist

# Reload the service
launchctl bootout gui/$(id -u) ~/Library/LaunchAgents/picoclaw.plist
launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/picoclaw.plist
```

### View Status

```bash
# List all loaded services
launchctl list | grep picoclaw

# Check specific service
launchctl list | grep picoclaw
```

### View Logs

Logs are sent to:

- **stdout**: `~/Library/Logs/picoclaw.log`
- **stderr**: `~/Library/Logs/picoclaw.err.log`

```bash
# View stdout logs
tail -f ~/Library/Logs/picoclaw.log

# View stderr logs
tail -f ~/Library/Logs/picoclaw.err.log

# View both
tail -f ~/Library/Logs/picoclaw*.log
```

## Troubleshooting

### Service won't start?

```bash
# Check for errors in stderr
cat ~/Library/logs/picoclaw.err.log

# Check launchd diagnostics
launchctl diagnose
```

### Service not loading?

```bash
# Validate plist
plutil ~/Library/LaunchAgents/picoclaw.plist

# Check if file exists
ls -la ~/Library/LaunchAgents/picoclaw.plist
```

## Requirements

- macOS
- User must have permission to use launchd

## Skills Used

- `self-debug` - For viewing logs and diagnosing issues
