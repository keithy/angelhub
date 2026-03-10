# AngelHub Skills Registry - Federation Plan

## Overview

Extend the AngelHub skills registry to support external skill repositories, curated thematic indexes, and standardized data collection using Nickel.

## Current State

- **Source:** `keithy/angelhub` (GitHub)
- **Format:** SKILL.md files + JSON index via GitHub Wiki
- **Index URL:** `https://raw.githubusercontent.com/wiki/keithy/angelhub/picoclaw-skills-index.json`

### Current Index Schema
```json
{
  "skills": [{
    "slug": "self-config",
    "name": "self-config",
    "description": "Allows the agent to safely update...",
    "_path": "picoclaw/skills/reflection/self-config",
    "download_url": "https://raw.githubusercontent.com/keithy/angelhub/main/...",
    "files": ["SKILL.md", "test.md"]
  }],
  "updated_at": "2026-03-05T00:00Z"
}
```

## Phase 1: Mirror Workflows

Create workflows that fetch skills from external repos and convert them to AngelHub format.

### Mirror Workflow Design

**Inputs:**
- `owner` — GitHub owner (e.g., `anthropics`)
- `repo` — Repository name (e.g., `claude-code`)
- `skill_path` — Path to skills (e.g., `plugins`)

**Process:**
1. Clone/fetch external repo
2. Normalize to AngelHub format:
   - README.md → SKILL.md (or extract description)
   - plugin.json → metadata
3. Generate `<repo>-skills-index.json`
4. Publish to Wiki

### External Formats to Support

| Source | Format | Size | Notes |
|--------|--------|------|-------|
| **ClawHub** | SKILL.md + JSON API | ~5000 | Public OpenClaw registry |
| **awesome-agent-skills** | SKILL.md | 500+ | VoltAgent's curated list |
| **claude-skills** | SKILL.md | 180+ | alirezarezvani's production skills |
| **GitHub topic: agent-skill** | SKILL.md | 270 repos | Various community skills |
| **GitHub topic: claude-code-skills** | SKILL.md | 364 repos | Claude Code specific |
| **Claude Code plugins** | README.md + plugin.json | ~20 | Official Anthropic plugins |
| **MCP Servers** | package.json | - | Future consideration |

## Phase 2: Themed Indexes

Curated indexes that combine skills from multiple sources.

### Index Types

1. **Source-specific mirrors**
   - `clawhub-skills-index.json` - Public OpenClaw registry (~5000 skills)
   - `awesome-agent-skills-index.json` - VoltAgent's curated list (500+)
   - `claude-skills-index.json` - alirezarezvani's production skills (180+)
   - `claude-code-skills-index.json` - GitHub topic collection
   - `openclaw-skills-index.json`

2. **Use-case indexes**
   - `devops-skills-index.json`
   - `frontend-skills-index.json`
   - `security-skills-index.json`

3. **"Awesome" index**
   - Popular/raved-about skills (inspired by Awesome lists)
   - Manual curation + automated discovery

### Aggregation Strategy

```nickel
{
  sources = [
    { name = "claude-code", url = "..." },
    { name = "angelhub", url = "..." },
  ],
  indexes = {
    awesome = { sources = ["claude-code", "angelhub"], filter = "stars>100" },
    devops = { sources = [...], tags = ["docker", "kubernetes", "ci"] },
  }
}
```

## Phase 3: Nickel Data Collection

Standardize skill testing and monitoring data using Nickel.

### Skill Status Schema

```nickel
{
  skills = [
    {
      slug = "self-config",
      source = "angelhub",
      status = "active" | "testing" | "deprecated",
      last_tested = "2026-03-10",
      outcome = "pass" | "fail" | "partial",
      tests = [
        {
          name = "config-patch",
          result = "pass",
          duration_ms = 150,
          notes = "Successfully patched config",
        }
      ],
      metadata = {
        owner = "keithy",
        category = "reflection",
        tags = ["config", "self-management"],
      }
    }
  ],
  generated_at = "2026-03-10T11:00:00Z",
  generator = "angelhub-test-agent",
}
```

### Outputs

- **Full JSON** — Machine consumption / API
- **Wiki table** — Human-readable status
- **Subset exports** — Different views for different consumers

## Implementation Tasks

- [ ] Create mirror workflow template
- [ ] Mirror Claude Code skills
- [ ] Create "awesome" index workflow
- [ ] Define Nickel schema for skill testing
- [ ] Add test runner workflow → Nickel output
- [ ] Generate Wiki status page from Nickel

## Agent Roles

Three core roles for skill management, each with distinct personality and responsibilities:

### Coding
**Focus:** Build and generate
- Workflow creation and maintenance
- Importers for external skill formats
- Dashboard builders and UI generators
- Output generation (JSON, Markdown, Nickel)

### Researching
**Focus:** Discovery and analysis
- Skills exploration and discovery
- Comparing skill options
- Writing reviews and documentation
- Finding dependencies and relationships

### Auditing
**Focus:** Quality and safety
- Code review for imported skills
- Security auditing
- Quarantine management (isolating bad skills)
- Evaluating specificity vs. genericness
- Dependency awareness and conflict detection

### Sub-roles (Future)

| Role | Parent | Notes |
|------|--------|-------|
| skill-explorer | Researching | Find skills across registries |
| skills-reviewer | Researching | Write skill reviews |
| security-auditor | Auditing | Check for vulnerabilities |
| dependency-tracker | Auditing | Map skill dependencies |
| quarantine-guard | Auditing | Manage blocked/removed skills |
| workflow-writer | Coding | Create automation workflows |
| importer | Coding | Convert external formats |
| dashboard-builder | Coding | Build status/display UIs |

## Notes

- **YAML-free** — All outputs in JSON/Nickel
- **Agents-first** — Data structured for agent consumption
- **Federated** — Each source maintains its own; we aggregate
- **Extensible** — New sources just need a mirror workflow
