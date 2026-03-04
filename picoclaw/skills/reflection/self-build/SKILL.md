---
name: self-build
description: Build, test, and contribute to PicoClaw with safe rollout.
license: MIT
metadata:
  author: keithy@consultant.com
  version: 1.0.0
---

# Self-Build

> Build, test, and contribute to PicoClaw with safe rollout.

Tools for building PicoClaw, staging artifacts, and managing the contribution workflow.

## Build & Stage Workflow

### 1. Build (Creates Staged Artifact)
```bash
make build
# Output: build/picoclaw-linux-<arch> (staged)
```

The build artifact goes to `build/` — NOT overwriting the running binary.

### 2. Verify Before Switching

The new binary is at `build/picoclaw-linux-<arch>`. The symlink `build/picoclaw` points to the current version.

```bash
# Check version of new build
./build/picoclaw-linux-<arch> version

# Verify symlink target
ls -la build/picoclaw
```

### 3. Switch (Update Symlink)

The running binary is at `/infra/code/picoclaw/build/picoclaw` (symlink to versioned binary).

```bash
# Backup current symlink target
cp -L ~/.local/bin/picoclaw ~/.local/bin/picoclaw.bak

# Update symlink to new build
cd /infra/code/picoclaw/build
ln -sf picoclaw-linux-<arch> picoclaw

# Restart service (from self-config)
TIMEOUT=300 scripts/picoclaw-safe-restart restart-with-auto-rollback
```

**Note**: `make build` already updates the symlink. Just restart to switch.

### 4. Confirm or Rollback

```bash
# If works: cancel rollback
scripts/picoclaw-safe-restart cancel-auto-rollback

# If failed: restore previous binary
cd /infra/code/picoclaw/build
ln -sf picoclaw-linux-arm64.bak picoclaw
# OR manually restore:
# ln -sf <previous-version> picoclaw
systemctl --user restart picoclaw
```

---

## Quick Commands

### Build
```bash
make build              # Build for current platform (staged)
make generate           # Run go generate only
make build-all          # Build all platforms
make build-linux-arm    # Linux ARMv7
make build-linux-arm64  # Linux ARM64
make build-pi-zero      # Raspberry Pi Zero 2 W
```

### Test
```bash
make test                # Run all tests
make test PKG=./pkg/... # Specific package
make lint               # Run linter
make fmt                # Format code
make vet                # Static analysis
make check              # Full check: deps + fmt + vet + test
```

### Docker
```bash
make docker-build        # Build minimal Docker image
make docker-build-full  # Build with full MCP support
make docker-run         # Run gateway in Docker
```

---

## Contributing Workflow

### 1. Setup
```bash
# Fork on GitHub, then clone
git clone https://github.com/<your-username>/picoclaw.git
cd picoclaw
git remote add upstream https://github.com/sipeed/picoclaw.git
```

### 2. Create Feature Branch
```bash
git checkout main
git pull upstream main
git checkout -b feat/your-feature
# or: bugfix/issue-number, docs/description
```

### 3. Make Changes
- Write clear commit messages (imperative mood)
- Reference issues: `Fix issue (#123)`
- Keep commits focused and atomic

### 4. Before Opening PR
```bash
make check    # Must pass locally
```

### 5. Open PR
- Fill in the PR template completely
- **AI Disclosure Required** — must disclose if AI helped:
  - 🤖 Fully AI-generated
  - 🛠️ Mostly AI-generated  
  - 👨‍💻 Mostly Human-written
- Link related issue(s)

### 6. Update Based on Review
```bash
# Rebase if needed
git fetch upstream
git rebase upstream/main

# Amend or add commits (don't force push after review)
git commit --amend
# or
git add . && git commit -m "feedback: addressed comments"
```

---

## AI Contribution Disclosure

Every PR must disclose AI involvement honestly. There is no stigma — all levels are welcome.

| Level | Description |
|-------|-------------|
| 🤖 Fully AI-generated | AI wrote code; human reviewed |
| 🛠️ Mostly AI-generated | AI draft; significant human changes |
| 👨‍💻 Mostly Human-written | Human led; AI suggestions |

**You are responsible** for AI-generated code:
- Read and understand every line
- Test in real environment
- Check for security issues
- Verify correctness

---

## Requirements

- Go 1.25+
- `make`
- `golangci-lint` (for fmt/lint)

## Skills Used

- `picoclaw:shell` - for running build commands
- `picoclaw:file-ops` - for checking build outputs
- `self-config` - for service restart with auto-rollback
