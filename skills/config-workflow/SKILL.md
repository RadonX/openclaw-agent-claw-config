---
name: config-workflow
description: OpenClaw configuration management safety protocol and change reporting. Use when modifying OpenClaw configuration that affects runtime behavior: (1) editing openclaw.json (bindings, channels, agents), (2) changing workspace prompt files (SOUL.md, AGENTS.md, IDENTITY.md), (3) restarting gateway or agents, (4) installing/removing skills or tools, or (5) any action that may impact message routing or agent behavior.
---

# Configuration Change Workflow

This skill provides safety protocols and structured reporting for OpenClaw configuration changes.

## Core Principles

**Report all runtime-affecting changes.** Any configuration change that impacts message routing, agent behavior, or service availability requires proactive reporting in the group chat.

**Never rely on memory.** Configuration knowledge evolves. Always verify against source code, documentation, or the shared knowledge base (kb/).

**Follow the change sequence.** For high-risk operations: git status → execute → report → rollback info.

---

## Change Reporting Structure

When you complete a configuration change, bug fix, restart, or any operation that affects runtime state, report in the group chat using this structure:

### Four Required Sections

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

For more examples, see [EXAMPLES.md](references/EXAMPLES.md).

---

## Safety Protocol

### Before Critical Actions

Before executing critical actions (configuration changes, deployments, irreversible operations):

1. **Search kb/ for known issues and playbooks:**
   ```bash
   kb/ | grep -i "Known.*Issues"
   kb/ | grep -i "Playbook.*<topic>"
   ```

2. **Follow documented protocols** if found:
   - Read the playbook/issue document
   - Apply the recommended steps

3. **Ask first** if uncertain:
   - When no documentation exists
   - When the operation is high-risk
   - When the outcome is uncertain

### Verification Sources

Always verify against authoritative sources:
- **Source code** (for OpenClaw internals)
- **Documentation** (docs/, skills/*/SKILL.md)
- **Knowledge base** (kb/ for playbooks and known issues)

---

## Change Sequence

For high-risk operations, follow this order:

1. **`git status`** — Confirm no accidental deletions/modifications; commit what should be saved
2. **Execute** — Perform the risky/irreversible operation (delete/move/overwrite)
3. **Report** — Provide structured report (see above)
4. **Rollback info** — Always include recovery steps

---

## Integration with AGENTS.md

This skill complements the safety guidelines in `AGENTS.md`:

- **AGENTS.md**: Universal safety principles (`trash > rm`, ask before external actions)
- **This skill**: Configuration-specific workflow (change reporting, kb/ protocols)

When working with OpenClaw configuration:
1. Follow AGENTS.md safety rules
2. Apply this skill's reporting structure
3. Use `tools/tg-compiled.sh` and `tools/tg-routing-map.sh` for validation

---

## References

- [EXAMPLES.md](references/EXAMPLES.md) - Detailed reporting examples for common operations
- [PLAYBOOKS.md](references/PLAYBOOKS.md) - Common configuration change patterns and troubleshooting
