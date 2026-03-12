# Configuration Change Examples

This document provides detailed examples of structured reporting for common OpenClaw configuration changes.

## Adding a New Telegram Binding

### Scenario
Add a new binding for `ginmoni` bot to route messages from group XYZ to an agent.

### Report

```markdown
**做了什么：** 新增 ginmoni → 群组 XYZ 的绑定，使用 requireMention=false
**如何验证：** tools/tg-compiled.sh --account ginmoni -g <群组ID>
**是否已生效：** gateway 已热加载，binding 已在 compiled config 中显示
**风险：** 低（新绑定不影响现有路由）；回滚：删除 binding 行，重启 gateway
```

### Verification Commands

```bash
# Check compiled config for the specific group
tools/tg-compiled.sh --account ginmoni -g <群组ID>

# Verify gateway status
openclaw status

# Check logs for errors
tail -f ~/.openclaw/logs/gateway.log | grep -i error
```

---

## Modifying Agent Prompts

### Scenario
Update `SOUL.md` to add a new behavioral principle ("不装死" - must report after changes).

### Report

```markdown
**做了什么：** 更新 SOUL.md，添加"不装死"原则（变更后必须汇报）
**如何验证：** git diff SOUL.md
**是否已生效：** 已 symlink 到 public repo，下次 session 重启后生效
**风险：** 低（行为变更，可回滚）；回滚：git checkout HEAD~ SOUL.md
```

### Verification Commands

```bash
# Show the diff
git diff SOUL.md

# Verify symlink is correct
ls -la ~/.openclaw/workspace-claw-config/SOUL.md
readlink ~/.openclaw/workspace-claw-config/SOUL.md

# Test in a new session (optional)
# Trigger a conversation with the agent to verify new behavior
```

---

## Restarting Gateway

### Scenario
Restart the gateway to apply new bindings configuration.

### Report

```markdown
**做了什么：** 重启 gateway 以应用新的 bindings 配置
**如何验证：** openclaw status（显示 gateway running）+ 最近 logs 无 409/crash
**是否已生效：** gateway 已重启，uptime 显示 5 秒
**风险：** 中（可能中断服务）；回滚：恢复 openclaw.json，再次重启
```

### Verification Commands

```bash
# Check gateway status
openclaw status

# Check uptime
openclaw gateway status | grep uptime

# Check logs for errors (last 50 lines)
tail -50 ~/.openclaw/logs/gateway.log | grep -i "error\|crash\|409"

# Send a test message (optional)
# Trigger a message in a Telegram group to verify routing works
```

---

## Changing Agent Binding

### Scenario
Modify an existing binding to change routing from agent A to agent B.

### Report

```markdown
**做了什么：** 把群组 -1003807184197 的绑定从 main 改为 claw-config
**如何验证：** tools/tg-compiled.sh --account ginmoni -g -1003807184197
**是否已生效：** gateway 已热加载，新绑定已生效
**风险：** 中（路由变更，可能影响消息处理）；回滚：恢复原绑定，重启 gateway
```

### Verification Commands

```bash
# Check compiled config for the group
tools/tg-compiled.sh --account ginmoni -g -1003807184197

# Verify the agent field shows the new agent
tools/tg-compiled.sh --account ginmoni -g -1003807184197 | jq '.bindings_hit | .[0].agent'

# Send a test message to verify routing
```

---

## Installing a New Skill

### Scenario
Install a new skill from a .skill file to the skills directory.

### Report

```markdown
**做了什么：** 安装 skill-creator.skill 到 skills/public/
**如何验证：** ls skills/public/skill-creator/SKILL.md
**是否已生效：** 已安装，下次 agent 重启后自动加载
**风险：** 低（新技能不影响现有行为）；回滚：删除 skill-creator/ 目录
```

### Verification Commands

```bash
# Check skill directory exists
ls -la skills/public/skill-creator/

# Verify SKILL.md has valid frontmatter
head -10 skills/public/skill-creator/SKILL.md

# Check for YAML syntax errors
python3 -c "import yaml; yaml.safe_load(open('skills/public/skill-creator/SKILL.md'))"
```

---

## Updating Configuration File

### Scenario
Update `openclaw.json` to add a new channel configuration.

### Report

```markdown
**做了什么：** 在 openclaw.json 添加新的 discord channel 配置
**如何验证：** jq '.channels.discord' ~/.openclaw/openclaw.json
**是否已生效：** 需要 restart gateway 才能生效（计划在维护窗口执行）
**风险：** 高（配置错误可能导致 gateway 启动失败）；回滚：git checkout HEAD~ openclaw.json
```

### Verification Commands

```bash
# Validate JSON syntax
jq empty ~/.openclaw/openclaw.json

# Check specific section
jq '.channels.discord' ~/.openclaw/openclaw.json

# Test configuration (dry run)
openclaw doctor --dry-run

# Backup before applying
cp ~/.openclaw/openclaw.json ~/.openclaw/openclaw.json.backup
```

---

## Troubleshooting Failed Changes

### Scenario
A configuration change caused an error. Rollback and report.

### Report

```markdown
**做了什么：** 尝试更新 ginmoni 绑定，导致 gateway 409 错误；已回滚
**如何验证：** openclaw status 显示 gateway 正常运行
**是否已生效：** 已回滚到之前的工作配置（git ref 62f3731）
**风险：** 无（已回滚）；下一步：检查 kb/ 中的已知问题，查找正确的绑定格式
```

### Recovery Commands

```bash
# Rollback to previous commit
git checkout 62f3731 -- ~/.openclaw/openclaw.json

# Restart gateway
openclaw gateway restart

# Verify status
openclaw status

# Check logs for root cause
tail -100 ~/.openclaw/logs/gateway.log | grep -B 5 "409"
```
