---
name: self-config
description: Allows the agent to safely update its own configuration files
license: MIT
metadata:
  author: keithy@consultant.com
  version: 1.0.0
---

# Self-Config Skill Capabilities

1. Presentation of the `config.json` with secrets redacted.
2. Staging of a `config.new.json` with utilities for patching, sorting, diffing, and validation.
3. Safe service restarts with auto-rollback timers.

## Tools used
- `scripts/config.sh`: Base utility for presenting redacted JSON files.
- `scripts/config-patch.sh`: Tools for iterative patching of a staged `config.new.json` file.
- `scripts/picoclaw-safe-restart`: Manages service restarts with auto-rollback.
- `jq`: Used internally for JSON manipulation.

## View Current Configuration

### Show (Full redacted)
```bash
scripts/config.sh show
```

### Show (Part redacted)
```bash
scripts/config.sh show 'agents.defaults'
```

### Summary (Filtered)
Shows only configured models, agents, enabled tools, devices, and heartbeat settings.
```bash
scripts/config.sh summary
```

---

## Workflow: Safe Configuration Update

### 1. Start a Session
Initialize the staging environment. This redacts sensitive keys (tokens, passwords) into a separate hidden file so they aren't exposed in plain text during editing.
```bash
scripts/config-patch.sh start
```

### 2. Apply Patches
Apply `jq` filters to the **staged** file. You can run this multiple times.
```bash
scripts/config-patch.sh '.path.to.key = "new_value"'
```

### 3. Review Changes
Review the diff between the original and the staged (redacted) version.
```bash
scripts/config-patch.sh diff
```

### 4. View Staged Config
```bash
scripts/config-patch.sh show
# OR
scripts/config-patch.sh show 'agents.defaults'
# OR
scripts/config-patch.sh summary
```

### 5. Sort Keys (Optional)
Sort the keys in the staged file alphabetically.
```bash
scripts/config-patch.sh sort
```

### 6. Reset (Abort)
If you make a mistake *before* switching, clear the staging files.
```bash
scripts/config-patch.sh reset
```

### 7. Switch & Test (The "Hot" Update)
Commit the patch, restart the service, and create a timer that will rollback
unless 'confirm' action is performed. Default is 120 seconds. 

```bash
TIMEOUT=300 scripts/picoclaw-safe-restart restart-with-auto-rollback
```

### 8. Cancel Auto Rollback
If the agent is still working and the changes are correct, cancel the auto-rollback to lock in the update.
```bash
scripts/picoclaw-safe-restart cancel-auto-rollback
```

## Safety Rules
1. **Always** use `start` before applying patches.
2. **Never** manually or directly edit or view or grep the `.secrets.json` file, use `scripts/config.sh show [path.to.item]`
3. **Always** confirm your changes within the time limit after a `restart-with-auto-rollback`.
