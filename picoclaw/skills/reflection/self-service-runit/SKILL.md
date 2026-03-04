---
name: self-service-runit
description: Install and manage picoclaw as a runit service.
license: MIT
metadata:
  author: keithy@consultant.com
  version: 1.0.0
  status: untested
---

# self-service-runit

Install and manage picoclaw as a runit service. Runit is commonly used in containers, Alpine Linux, and Void Linux.

## Installation

```bash
exec "scripts/install-service-runit.sh [service_name]"
```

### Arguments

| Argument | Description | Default |
|----------|-------------|---------|
| `service_name` | Name of the service | `picoclaw` |

### Examples

```bash
# Install service
exec "skills/self-service-runit/scripts/install-service-runit.sh picoclaw"
```

## Service Management

### Start/Stop/Restart

```bash
# Create the service directory if needed
mkdir -p /var/service/${service_name}

# Link service (enable)
ln -s /path/to/picoclaw-service /var/service/

# Remove link (disable)
rm /var/service/${service_name}

# Restart service
sv restart picoclaw

# Reload service
sv reload picoclaw
```

### View Status

```bash
# Check service status
sv status picoclaw

# Check if service is running
sv status picoclaw | grep -q "run:" && echo "running" || echo "stopped"

# Detailed status
sv -v status picoclaw
```

### View Logs

```bash
# View recent logs
sv log picoclaw

# Watch logs in real-time
tail -f /var/log/picoclaw/current

# Or using chpst
sv -f /var/service/picoclaw log
```

## Runit Service Structure

A runit service needs:

```
/etc/sv/<service_name>/
├── run          # Start script (required)
├── finish       # Stop script (optional)
└── log/         # Log directory (optional)
    └── run      # Log runner
```

## Example Run Script

```bash
#!/bin/sh
exec 2>&1
export PICOCLAW_HOME="/home/user/.picoclaw"
exec chpst -u user /usr/local/bin/picoclaw gateway
```

## Troubleshooting

### Service won't start?

```bash
# Check the run script is executable
chmod +x /etc/sv/picoclaw/run

# Test run script manually
/etc/sv/picoclaw/run

# Check logs
tail /var/log/picoclaw/current
```

### Service keeps stopping?

```bash
# Check if service is disabled
ls -la /var/service/ | grep picoclaw

# Enable by linking
ln -s /etc/sv/picoclaw /var/service/
```

## Requirements

- runit installed (`command -v sv`)
- Write access to `/etc/sv/` or `/var/service/`

## Skills Used

- `self-debug` - For viewing logs and diagnosing issues
