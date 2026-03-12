# Configuration Change Workflow

**Scope:** OpenClaw configuration management safety protocol and change reporting.

## When to Use

Use this workflow for ANY configuration changes that affect runtime behavior:
- Modifying `~/.openclaw/openclaw.json` (bindings, channels, agents)
- Changing workspace prompt files (SOUL.md, AGENTS.md, IDENTITY.md)
- Restarting gateway or agents
- Installing/removing skills or tools
- **Any action that may impact message routing or agent behavior**

---

## 📋 Event-Driven Reporting

When you complete a configuration change / bug fix / restart / or any operation that affects runtime state, **proactively report in the group chat** (concise but structured):

### Report Structure

1. **做了什么改动** (What changed)
   - Which files/parameters were modified
   - Before/after summary (if meaningful)

2. **如何验证** (How to verify)
   - Validation commands: `jq` checks, `openclaw doctor`, `openclaw status`
   - Functional test: trigger a test message, verify routing works

3. **当前是否已生效** (Current status)
   - Is restart/hot-reload needed? Already done?
   - Effective scope: which agents/channels affected?

4. **风险 & 下一步** (Risks & next steps)
   - Do you need user confirmation?
   - Rollback point/backup available?

### Example Report

```
• 做了什么：把 ginmoni 的绑定从 allowlist 改为 groups 模式，移除 3 个废弃的 group_id
• 如何验证：openclaw gateway call config.get | jq '.channels.telegram.accounts["8402020404"]'
• 是否已生效：已重启 gateway，所有使用 ginmoni 的群组已应用新规则
• 风险：无（allowlist → groups 是放宽限制）；回滚点：git ref 62f3731
```

---

## 🛡️ Safety Protocol

### Before Critical Actions

Before executing critical actions (communication deployment, configuration changes, irreversible operations):

1. **Search shared knowledge base** for known issues and playbooks:
   ```bash
   # Search for known issues
   kb/ | grep -i "Known.*Issues"

   # Search for relevant playbooks
   kb/ | grep -i "Playbook.*<topic>"
   ```

2. **Follow documented protocols** if found:
   - Read the playbook/issue document
   - Apply the recommended steps
   - Do not rely on personal memory

3. **Ask first** if uncertain:
   - When no documentation exists
   - When the operation is high-risk
   - When the outcome is uncertain

### Do NOT Rely on Memory

Configuration knowledge evolves. Always verify against:
- Source code (for OpenClaw internals)
- Documentation (docs/, skills/*/SKILL.md)
- Knowledge base (kb/ for playbooks and known issues)

---

## 🔧 Change Sequence

Follow this order for high-risk operations:

1. **`git status`** — Confirm no accidental deletions/modifications; commit what should be saved
2. **Execute** — Perform the risky/irreversible operation (delete/move/overwrite)
3. **Report** — Provide structured report (see above)
4. **Rollback info** — Always include recovery steps

---

## Common Patterns

### Adding a New Telegram Binding

```markdown
**做了什么：** 新增 ginmoni → 群组 XYZ 的绑定，使用 requireMention=false
**如何验证：** tools/tg-compiled.sh --account ginmoni -g <群组ID>
**是否已生效：** gateway 已热加载，binding 已在 compiled config 中显示
**风险：** 低（新绑定不影响现有路由）；回滚：删除 binding 行，重启 gateway
```

### Modifying Agent Prompts

```markdown
**做了什么：** 更新 SOUL.md，添加"不装死"原则（变更后必须汇报）
**如何验证：** git diff SOUL.md
**是否已生效：** 已 symlink 到 public repo，下次 session 重启后生效
**风险：** 低（行为变更，可回滚）；回滚：git checkout HEAD~ SOUL.md
```

### Restarting Gateway

```markdown
**做了什么：** 重启 gateway 以应用新的 bindings 配置
**如何验证：** openclaw status（显示 gateway running）+ 最近 logs 无 409/crash
**是否已生效：** gateway 已重启，uptime 显示 5 秒
**风险：** 中（可能中断服务）；回滚：恢复 openclaw.json，再次重启
```

---

## Integration with AGENTS.md

This skill complements the safety guidelines in `AGENTS.md`:
- **AGENTS.md**: Universal safety principles (`trash > rm`, ask before external actions)
- **This skill**: Configuration-specific workflow (change reporting, kb/ protocols)

When working with OpenClaw configuration:
1. Follow AGENTS.md safety rules
2. Apply this skill's reporting structure
3. Use `tools/tg-compiled.sh` and `tools/tg-routing-map.sh` for validation
