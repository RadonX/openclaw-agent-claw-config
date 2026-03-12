# Configuration Change Playbooks

This document contains common patterns and troubleshooting procedures for OpenClaw configuration changes.

## Table of Contents

- [Common Change Patterns](#common-change-patterns)
- [Troubleshooting](#troubleshooting)
- [Safety Checklist](#safety-checklist)

---

## Common Change Patterns

### Pattern 1: Low-Risk Additive Changes

**Use when:** Adding new configuration that doesn't affect existing functionality.

**Examples:**
- Adding a new Telegram binding
- Installing a new skill
- Creating a new agent workspace

**Procedure:**
1. Make the change
2. Verify with appropriate tools (`jq`, `openclaw doctor`, etc.)
3. Report with "Low risk" assessment

**Rollback:** Usually simple deletion or `git checkout`

---

### Pattern 2: Medium-Risk Routing Changes

**Use when:** Changing how messages are routed or which agent handles them.

**Examples:**
- Modifying an existing binding
- Changing agent assignments
- Updating channel gates

**Procedure:**
1. Document current state (`git diff`, `tools/tg-compiled.sh`)
2. Make the change
3. Verify with compiled config inspection
4. Send test message to confirm routing
5. Report with "Medium risk" assessment

**Rollback:** Restore previous configuration, restart gateway

---

### Pattern 3: High-Risk Core Configuration

**Use when:** Modifying core files that affect gateway startup or overall system behavior.

**Examples:**
- Updating `openclaw.json` structure
- Changing channel-level configuration
- Modifying authentication credentials

**Procedure:**
1. **Create backup:** `cp openclaw.json openclaw.json.backup`
2. **Search kb/:** Look for relevant playbooks or known issues
3. **Validate syntax:** `jq empty openclaw.json`
4. **Make change** with minimal scope
5. **Test locally:** `openclaw doctor --dry-run` if available
6. **Apply during maintenance window** if possible
7. **Monitor logs:** `tail -f logs/gateway.log`
8. Report with "High risk" assessment and explicit rollback steps

**Rollback:** Restore from backup, restart gateway, verify logs

---

## Troubleshooting

### Gateway Won't Start After Config Change

**Symptoms:**
- `openclaw status` shows gateway not running
- Logs show configuration parse errors

**Diagnosis:**
```bash
# Check logs for specific error
tail -50 ~/.openclaw/logs/gateway.log

# Validate JSON syntax
jq empty ~/.openclaw/openclaw.json
```

**Solution:**
1. Restore backup configuration
2. Identify syntax error (missing comma, wrong type, etc.)
3. Fix the error
4. Retry

**Prevention:** Always run `jq empty` before applying config changes

---

### Binding Not Working As Expected

**Symptoms:**
- Messages not routing to expected agent
- `requireMention` not being respected
- Group allowlist/blocklist not working

**Diagnosis:**
```bash
# Check compiled config
tools/tg-compiled.sh --account <account_id> -g <group_id>

# Check effective gate
tools/tg-compiled.sh --account <account_id> -g <group_id> | jq '.effective_group_gate'

# List all bindings for account
tools/tg-routing-map.sh --account <account_id>
```

**Solution:**
1. Verify binding syntax in `openclaw.json`
2. Check account-level vs channel-level groups precedence
3. Verify group_id is correct (negative for supergroups)
4. Restart gateway after changes

**Prevention:** Use `tools/tg-compiled.sh` before and after changes

---

### Symlink Issues After Workspace Reorganization

**Symptoms:**
- Agent not loading updated prompts
- Changes to public repo not reflecting in private workspace
- `git status` shows symlink confusion

**Diagnosis:**
```bash
# Check if file is symlink
ls -la <workspace>/SOUL.md

# Verify symlink target
readlink <workspace>/SOUL.md

# Check what git sees
git status <workspace>/SOUL.md
```

**Solution:**
1. Remove broken symlink: `rm <workspace>/SOUL.md`
2. Recreate symlink: `ln -s <public-repo>/SOUL.md <workspace>/SOUL.md`
3. Verify: `ls -la <workspace>/SOUL.md`

**Prevention:** Document public repo paths in TOOLS.md or workspace README

---

### Skill Not Loading After Installation

**Symptoms:**
- Newly installed skill not triggering
- Agent says "skill not found"
- `openclaw skills list` doesn't show skill

**Diagnosis:**
```bash
# Check skill directory exists
ls -la skills/<skill-name>/

# Verify SKILL.md has valid frontmatter
head -5 skills/<skill-name>/SKILL.md

# Check for YAML syntax errors
python3 -c "import yaml; yaml.safe_load(open('skills/<skill-name>/SKILL.md'))"
```

**Solution:**
1. Fix YAML frontmatter syntax (name and description required)
2. Ensure skill is in correct directory (`skills/public/` or `skills/local/`)
3. Restart agent or gateway to reload skills
4. Check skill description clarity (affects triggering)

**Prevention:** Run `package_skill.py` to validate before distribution

---

## Safety Checklist

Use this checklist before applying any configuration change:

### Pre-Change Checklist

- [ ] Searched `kb/` for relevant playbooks or known issues
- [ ] Read relevant documentation (docs/, skills/*/SKILL.md)
- [ ] Created backup of files to be modified
- [ ] Validated syntax (JSON for config files, YAML for skills)
- [ ] Identified rollback procedure
- [ ] Assessed risk level (low/medium/high)

### Post-Change Checklist

- [ ] Applied the change
- [ ] Verified with appropriate tools (`jq`, `openclaw status`, etc.)
- [ ] Tested functionality (sent test message, triggered skill)
- [ ] Checked logs for errors
- [ ] Documented the change in git (committed if appropriate)
- [ ] Reported in group chat with all four sections

### High-Risk Changes Require

- [ ] Maintenance window scheduled
- [ ] Stakeholder notification
- [ ] Rollback plan tested
- [ ] Monitoring plan in place
- [ ] Post-change review scheduled

---

## Common Commands Reference

### Config Validation

```bash
# Validate JSON syntax
jq empty ~/.openclaw/openclaw.json

# Check specific section
jq '.channels.telegram' ~/.openclaw/openclaw.json

# Gateway status
openclaw status

# Gateway health check
openclaw doctor
```

### Telegram Binding Inspection

```bash
# Compiled config for account
tools/tg-compiled.sh --account <account_id>

# Compiled config for specific group
tools/tg-compiled.sh --account <account_id> -g <group_id>

# All bindings for account
tools/tg-routing-map.sh --account <account_id>
```

### Log Inspection

```bash
# Last 50 lines of gateway log
tail -50 ~/.openclaw/logs/gateway.log

# Follow gateway log in real-time
tail -f ~/.openclaw/logs/gateway.log

# Search for errors
grep -i "error\|crash\|409" ~/.openclaw/logs/gateway.log
```

### Git Operations

```bash
# Check git status before changes
git status

# Create backup commit
git commit -am "backup before config change"

# Rollback to previous commit
git checkout HEAD~ -- <file>

# View diff
git diff <file>
```
