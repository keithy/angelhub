# Self-Config

> Configure the environment and project settings.

Configures the agent's environment, including environment variables, tools, and project-specific settings.

## When to Use

- Initialize a new project or workspace
- Configure environment variables
- Set up project-specific tools and aliases

## Usage

```bash
picoclaw use skill keithy/angelhub/picoclaw/skills/self/self-config
```

## Requirements

- Write access to project configuration files
- Ability to source shell scripts

## Skills Required

- `picoclaw:file-ops` - for reading/writing config files
- `picoclaw:shell` - for executing shell commands
