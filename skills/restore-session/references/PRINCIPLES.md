# Session Restoration Principles & Safety Guide

## Session File Architecture

### JSONL Format
Each `.jsonl` file contains line-delimited JSON:
```json
{"type":"session","version":3,"id":"...","userId":"...","timestamp":"...","cwd":"..."}
{"type":"message","timestamp":"...","message":{"role":"user","content":[{"type":"text","text":"..."}]}}
{"type":"message","timestamp":"...","message":{"role":"assistant","content":[...]}}
{"type":"message","timestamp":"...","message":{"role":"toolResult",...}}
```

### Key Insight
The **first line is metadata** (session header), subsequent lines are conversation messages. When restoring:
- **MUST** preserve target session ID in header
- **SHOULD** update `cwd` to match target workspace
- **MUST NOT** change session ID mid-file

## Restoration Mechanism

### How It Works (Content Replacement Method)

```
Step 1: Extract source content (minus header)
        │
        ▼
Step 2: Read target header (preserve session ID)
        │
        ▼
Step 3: Combine:
        [Target Header] + [Source Messages]
        │
        ▼
Step 4: Write to target file
        │
        ▼
Step 5: Write new session entry with fork metadata
```

### Why This Method Is Safe

1. **Session ID Unchanged** - Gateway continues to find the session
2. **No Cache Invalidation Needed** - `.jsonl` is read per-request, no TTL
3. **Reversible** - Restore from backup resets to original state
4. **Atomic** - Single write operation (if using proper temp file pattern)

## Critical Safety Rules

### Rule 1: Backup Target
```bash
TARGET_FILE="$SESSIONS_DIR/${TARGET_SESSION_ID}.jsonl"
BACKUP_DIR="$SESSIONS_DIR/.backups/$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"
cp "$TARGET_FILE" "$BACKUP_DIR/$(basename $TARGET_FILE).backup"
```

### Rule 2: Verify Source Before Use
```bash
# Check source has expected content
wc -l "$SOURCE_FILE"                          # Should be > 20 lines
head -1 "$SOURCE_FILE" | jq '.timestamp'       # Verify readable
jq 'select(.message.role=="user")' "$SOURCE_FILE" | head -3  # Sample messages
```

### Rule 3: Workspace Path Compatibility
For cross-agent restoration, the source `cwd` in metadata may point to wrong workspace.

**Fix during restoration:**
```bash
# Extract source metadata
cat "$SOURCE_FILE" | head -1 | jq ".cwd = \"$TARGET_WORKSPACE\"" > "$TEMP_FILE"
# Append rest of source content
tail -n +2 "$SOURCE_FILE" >> "$TEMP_FILE"
```

### Rule 4: No Concurrent Access
Session files can be corrupted if accessed simultaneously:
- Check for `.lock` files
- Never restore while Gateway is actively using the file
- Best practice: restore during idle periods

## Common Failure Modes

| Symptom | Cause | Fix |
|---------|-------|-----|
| Session appears empty after restore | Overwrote header line | Restore from backup |
| Gateway shows old content | sessions.json cache (45s) | Wait or restart Gateway |
| Cross-agent session missing history | Wrong workspace path in metadata | Re-apply with path fix |
| "Session not found" | Wrong session ID | Check sessions.json index |

## Rollback Procedure

```bash
# If restoration fails:
BACKUP_DIR="$SESSIONS_DIR/.backups/20260207-142400"
TARGET_ID="c36b85be-0937-46ca-95e2-7d89eba0e8df"

# Restore from backup
cp "$BACKUP_DIR/${TARGET_ID}.jsonl.backup" \
  "$SESSIONS_DIR/${TARGET_ID}.jsonl"

# Verify
wc -l "$SESSIONS_DIR/${TARGET_ID}.jsonl"
```

## Cross-Agent Considerations

**When restoring from one agent to another:**

1. **workspace-ginmoni** sessions may contain ginmoni-specific file paths
2. **workspace-main** sessions may reference main agent context
3. **Model-specific behavior** - History from one model may confuse another

**Mitigation:**
- Always update `cwd` in header metadata
- Add fork metadata entry documenting source
- Test with simple message before relying on restored context

## Compact Interactions

Session compacting may remove tool results and compress message pairs.

**Restoration after compact:**
- Source "pre-compact" session may be larger than current
- Restoration works but new messages trigger re-compact
- Consider disabling auto-compact if frequent restoration needed
