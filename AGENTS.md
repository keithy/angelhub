# Agent Instructions for AngelHub

> A skill registry for angelic AI agent workflows.

## Project Overview

- **Purpose**: Provides reusable skills for AI agents across multiple ecosystems
- **Current Ecosystem**: picoclaw
- **License**: MIT
- **Repository**: `github.com/keithy/angelhub`

## Project Structure

```
angelhub/
├── .github/
│   └── workflows/
│       └── picoclaw-skills-index.yml      # Auto-generates skills index on push
├── picoclaw/
│   └── skills/                   # PicoClaw ecosystem skills
│       └── <category>/
│           └── <skill_name>/
│               └── SKILL.md
├── skills/                      # Ecosystem-agnostic skills (common to all)
│   └── <category>/
│       └── <skill_name>/
│           └── SKILL.md
└── README.md
```

## Adding New Skills

1. Create directory: `picoclaw/skills/<category>/<skill_name>/` (or `skills/<category>/<skill_name>/` for ecosystem-agnostic skills)
2. Add `SKILL.md` with frontmatter:
   ```yaml
   ---
   name: skill-name
   description: What the skill does
   ---
   ```
3. Push to main - CI automatically indexes skills to GitHub Wiki

## SKILL.md Format

Skills use YAML frontmatter followed by markdown:
```yaml
---
name: self-config
description: Allows the agent to safely update its own configuration files
---

# Skill Name

Description and capabilities...

## Tools used
- List of tools/scripts

## Usage
How to use the skill...
```

## CI/CD

**skills-index.yml**: Triggered on push to `main` when `SKILL.md` files change.
- Scans `picoclaw/skills/` for SKILL.md files
- Extracts name/description from frontmatter or first heading
- Generates `skills-index.json` and publishes to GitHub Wiki
- Can be manually triggered with custom search paths

## PicoClaw Integration

### Configuration

Add to picoclaw's `config.json`:

```json
{
  "tools": {
    "skills": {
      "registries": {
        "index:angelhub": {
          "enabled": true,
          "index_url": "https://raw.githubusercontent.com/wiki/keithy/angelhub/skills-index.json"
        }
      }
    }
  }
}
```

### Install a Skill

```bash
# Search first
picoclaw skills search self

# Install from index:angelhub registry
picoclaw skills install --registry index:angelhub self-config

# Or install directly from GitHub
picoclaw skills install keithy/angelhub/picoclaw/skills/self/self-config
```

## Index Registry Architecture

The Index registry (already in picoclaw at `pkg/skills/index_registry.go`) fetches `skills-index.json` from any HTTP URL:

- **Interface**: `SkillRegistry` in `pkg/skills/registry.go:46`
- **Config**: `IndexRegistryConfig` in `pkg/skills/registry.go:69`
- **Config options**:
  - `enabled` - Enable the registry
  - `index_url` - URL to skills-index.json
  - `extra_header` - Optional extra headers
  - `authorization_header` - Optional auth
  - `agent_header` - Optional user-agent
  - `allowed_prefixes` - Limit download sources

## Available Skills in AngelHub

| Category | Skill | Description |
|----------|-------|-------------|
| self | self-config | Safely update config with redaction and auto-rollback |
| self | self-debug | Inspect health, logs, and configuration |
| self | self-build | Build and compile the project |

## Skills Index JSON Format

The `skills-index.json` published to GitHub Wiki must follow this format:

```json
{
  "version": 1,
  "updated_at": "2026-03-03T00:00:00Z",
  "skills": [
    {
      "slug": "self-config",
      "name": "Self Config",
      "description": "Allows the agent to safely update its own configuration",
      "path": "picoclaw/skills/self/self-config",
      "download_url": "https://raw.githubusercontent.com/keithy/angelhub/main/picoclaw/skills/self/self-config",
      "files": ["SKILL.md", "scripts/config.sh", "scripts/config-patch.sh", "scripts/service.sh"]
    }
  ]
}
```
