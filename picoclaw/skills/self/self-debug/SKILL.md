# Self-Debug

> Diagnose and troubleshoot issues autonomously.

Analyzes logs, errors, and system state to identify and suggest fixes for problems.

## When to Use

- Agent encounters errors or unexpected behavior
- Service failures or crashes
- Build or test failures

## Usage

```bash
picoclaw use skill keithy/angelhub/picoclaw/skills/self/self-debug
```

## Requirements

- Read access to logs and error outputs
- Ability to run diagnostic commands

## Skills Required

- `picoclaw:file-ops` - for reading logs
- `picoclaw:shell` - for running diagnostic commands
- `picoclaw:search` - for finding relevant error patterns
