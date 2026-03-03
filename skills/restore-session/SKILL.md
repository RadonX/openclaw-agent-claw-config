---
name: restore-session
description: Restore or migrate OpenClaw session history from a source session to a target session. Use when recovering lost context, migrating sessions after Telegram topic migration, or transferring conversation history between sessions. WARNING This is a HIGH-RISK operation that modifies session files directly.
---

# restore-session

Restore session conversation history while preserving the target session ID. This is useful when:
- Telegram topic migration creates a new empty session
- Recovery from corrupted or compacted session files
- Forking conversation history to another agent/session

**⚠️ HIGH-RISK OPERATION:** This skill modifies session files directly. Always backup before proceeding.

## When to Use

**Use this skill when:**
1. User explicitly requests session restoration
2. Telegram topic migration causes context loss
3. Session file corruption requires recovery
4. Cross-agent session fork/transfer requested

## Quick Reference

```bash
# Basic usage: restore to main session
./restore-session.sh <agent-id> <source-session-id>

# Target specific session (e.g., topic-214)
./restore-session.sh <agent-id> <source-session-id> <target-session-key>

# With delay flag (waits 45s after restoration)
./restore-session.sh <agent-id> <source-session-id> --delay

# Example
./restore-session.sh ginmoni af3226eb-e0c2-46ac-aa88-cefa802ede21
./restore-session.sh claw-config c36b85be-0937-46ca-95e2-7d89eba0e8df \
  agent:claw-config:telegram:group:-1003797724681:topic:214
```

## ⚠️ CRITICAL: Pre-Restore Setup

### MUST Use `/new` Before Restore

**⚠️ NEVER use `/reset` before session restore.** Always use `/new`.

**Why?**
- `/reset` keeps the same session ID; gateway caches the "cleared" state in memory
- Restoring the file on disk doesn't refresh gateway's in-memory cache
- Result: restored content is ignored, session stays empty

**`/new` creates a fresh session ID:**
- Forces gateway to load from disk
- Restored content is immediately visible
- No cache conflicts

**Correct workflow:**
1. User sends `/new` → creates clean session with new ID
2. Agent validates source session and outputs restore plan
3. User sends trigger word (e.g., "执行")
4. Agent executes restore
5. Wait 5 seconds, then test with a message

### Self-Restore Requires Two Turns

**If restoring YOUR OWN current session**, you MUST split into two agent turns:

### Turn 1: Explore & Prepare (DO NOT EXECUTE)
1. **Extract your own session key from message metadata**
   - Look at incoming message: `[Telegram xxx id:-100xxx topic:NNN ...]`
   - Build key: `agent:<agent-id>:telegram:group:<group-id>:topic:<topic-id>`
   - Example: `agent:claw-config:telegram:group:-1003593489589:topic:298`
2. Validate source session exists
3. Confirm target session key matches your current session
4. Output the execution plan **with the exact command including session key**
5. Prompt user: "发送 `执行` 来触发恢复"
6. **STOP. Do not run the script.**

### Turn 2: Execute & Silent
1. Receive trigger word (e.g., "执行")
2. Immediately run the restore script
3. **Reply with ONLY `NO_REPLY`** — no summary, no confirmation

**Why two turns?**
- Gateway writes the entire turn (user msg + tool calls + AI output) to session file
- If you explore AND execute in one turn, all that content overwrites the restored session
- Two turns minimizes pollution: Turn 2 only adds trigger message + tool result

### Cross-Session Restore (Single Turn OK)

If restoring **another session** (not your own), single turn is fine:
- Your tool calls modify the **target** session file, not yours
- You can output summaries normally

## Core Principles

**ALWAYS follow these rules:**

1. **Backup First** - Never modify without backing up target session
2. **Verify Source** - Confirm source session exists and contains expected history
3. **Single Target** - One restoration per execution, no batch operations
4. **Atomic Operation** - Use file operations that complete or fail entirely

## Session Structure

**Key Files:**
- `sessions.json` - Session index (maps session keys → session IDs)
- `<session-id>.jsonl` - Conversation history (JSON Lines format)
- `.jsonl` files self-contained; sessions.json only stores metadata pointers

**Session Key Format:**
```
agent:<agent-id>:<provider>:<chat-type>:<chat-id>[:topic:<topic-id>]
```

## Restoration Methods

### Method A: Content Replacement (Recommended)

Replace target `.jsonl` content with source content, preserving target session ID.

**Pros:** No delay, immediate effect, no sessions.json changes  
**Cons:** Source session must be compatible (same agent type)

**Implementation:** See references/PRINCIPLES.md for detailed workflow

### Method B: Session ID Reassignment

Update sessions.json to point to a different session ID.

**Pros:** Simple mapping change  
**Cons:** 45-second cache delay, cross-agent path issues

## Risk Assessment

| Risk Level | Scenario | Mitigation |
|------------|----------|------------|
| **LOW** | Same agent, same workspace | Verify backup exists |
| **MEDIUM** | Cross-agent, same user | Check workspace path compatibility |
| **HIGH** | Cross-user, cross-chat | Requires explicit confirmation + extra testing |

## Safety Checklist

Before executing ANY restoration:
- [ ] Source session verified (contains expected history)
- [ ] Target session backed up
- [ ] Agent workspace paths compatible (for cross-agent)
- [ ] User confirmed the specific source → target mapping
- [ ] No other processes writing to target session

See [references/PRINCIPLES.md](references/PRINCIPLES.md) for detailed safety procedures.

See [references/COMMANDS.md](references/COMMANDS.md) for technical command reference.

## Bundled Scripts

**Main script:** `scripts/restore-session.sh`
- Cross-platform bash script
- Automatic backup before modification
- Workspace path repair for cross-agent restoration
- Fork metadata injection
- Rollback capability

## Files and Git Tracking

⚠️ **Do not commit to git:** Session files in `scratch/` or test output.

**Track in git:**
- `SKILL.md` - Core skill documentation
- `references/*.md` - Safety guides and command reference
- `scripts/restore-session.sh` - Main restoration script

**Do NOT track:**
- Session backup files (in `.backups/`)
- Test output files
- Temporary `.jsonl` files
