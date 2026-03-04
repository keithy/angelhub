# Self-Build

> Build and compile the project.

Executes build commands, compiles code, and produces artifacts.

## When to Use

- Need to compile or build the project
- Generate binaries, containers, or other artifacts
- Run build pipelines

## Usage

```bash
picoclaw use skill keithy/angelhub/picoclaw/skills/self/self-build
```

## Requirements

- Build tools installed (make, go, cargo, etc.)
- Write access to build output directories

## Skills Required

- `picoclaw:shell` - for running build commands
- `picoclaw:file-ops` - for checking build outputs
