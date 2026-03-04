---
name: self-skill-audit
description: Debug environment variables and detect exposed secrets. SELF-VERIFY: Use this to check if sensitive credentials are being leaked to the AI process.
metadata: {"nanobot":{"emoji":"🔍","requires":{},"install":[]}}
---

# Debug Env - Security Self-Verify Skill

⚠️ **THIS IS A SECURITY-CRITICAL SKILL** - It exists to help you **detect** and **verify** that secrets are NOT being exposed to AI agents.

## Why This Skill Exists

Running `env` or similar commands can expose sensitive credentials that should NEVER reach an AI assistant:

### 🔴 EXPOSED SECRETS - EXAMPLE (DO NOT USE REAL VALUES):

```
GITHUB_TOKEN=gho_xxxxxxxxxxxxxxxxxxxx
OPENROUTER_API_KEY_picoclaw=sk-or-v1-xxxxxxxxxxxxxxxxxxxx
GEMINI_API_KEY=AIzaSyxxxxxxxxxxxxxxxxxxxx
TELEGRAM_TOKEN_infra=1234567890:ABCDefGhiJKlmnoPQRstuVWXyz
```

**This is a bug.** These tokens should NEVER be passed to the AI process.

## What Needs to Be Fixed

### 1. Environment Filtering Required

The service/system that spawns this AI agent MUST filter out sensitive environment variables before passing them to the child process.

**Recommended approach:**
- Use a blocklist of known secret variable names (e.g., `*_TOKEN`, `*_KEY`, `*_SECRET`, `*_PASSWORD`, `API_KEY`, etc.)
- Or use an allowlist of safe variables only

### 4. Example Fix (Go - before spawning process)

```go
func safeEnv() []string {
    unsafe := []string{
        "TOKEN", "KEY", "SECRET", "PASSWORD", "API_KEY",
    }
    var safe []string
    for _, e := range os.Environ() {
        key := strings.SplitN(e, "=", 2)[0]
        isUnsafe := false
        for _, u := range unsafe {
            if strings.Contains(strings.ToUpper(key), u) {
                isUnsafe = true
                break
            }
        }
        if !isUnsafe {
            safe = append(safe, e)
        }
    }
    return safe
}
```

## Usage - Self-Verify Mode

### To Check for Leaked Secrets:

```bash
env | grep -iE "(_TOKEN|_KEY|_SECRET|PASSWORD|GITHUB|TELEGRAM|OPENROUTER|GEMINI)" || echo "✓ No secrets detected"
```

### To Audit All Environment Variables (for debugging):

```bash
env
```

**IF SECRETS ARE FOUND:** This is a CRITICAL security bug. Report it immediately and do NOT share the output where it could be logged or cached.

## Best Practices

1. **Never pass secrets to AI agents** - They may be logged, cached, or displayed
2. **Use least-privilege environment** - Only pass what's absolutely needed
3. **Audit regularly** - Run this skill to verify no secrets are exposed
4. **Rotate exposed credentials immediately** - If you see them in output, assume compromise
