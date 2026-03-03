# Telegram Group Manager

OpenClaw Telegram 群组配置管理工具集。安全、简洁、符合 claw-config 最佳实践。

## 特点

- ✅ **Proposal-first**: 默认显示变更计划，不直接修改
- ✅ **Rollback-ready**: 每次变更都有 git commit 或 backup
- ✅ **诊断驱动**: 自动检测配置问题并给出建议
- ✅ **源码验证**: 所有深层逻辑都查阅源码，不猜测

## 快速开始

### 1. 检查群组状态

```bash
./scripts/check-group.sh <group_id> [account_id]
```

**输出：**
- Channel-level 配置状态
- Account-level 配置状态
- Privacy Mode 状态
- 诊断建议

### 2. 添加群组

```bash
# 默认 requireMention=true
./scripts/add-group.sh -1003896370559 claw_3po

# 设置 requireMention=false
./scripts/add-group.sh -1003896370559 claw_3po false
```

**流程：**
1. 显示当前状态
2. 显示将要做的变更
3. 要求确认
4. 创建 git commit（rollback 点）
5. 执行变更
6. 显示验证命令

### 3. 切换到 channel-level 模式

```bash
./scripts/use-channel-level.sh claw_3po
```

**效果：**
- 删除 account-level groups
- 让 bot 使用 channel-level 配置
- 简化管理，一处修改全局生效

### 4. 列出所有群组

```bash
# 所有配置
./scripts/list-groups.sh

# 只看 channel-level
./scripts/list-groups.sh --level channel

# 只看特定 bot
./scripts/list-groups.sh --account claw_3po
```

## 核心概念

### Account-level vs Channel-level

**优先级规则：**
```typescript
const accountGroups = resolveAccountEntry(...)?.groups;
return accountGroups ?? channelConfig.groups;
```

- Account-level 存在 → **完全使用** account-level
- Account-level 不存在 → fallback 到 channel-level
- **没有混合模式**

### 两种配置模式

**模式 A：Account-level（完全自定义）**
```json
{
  "accounts": {
    "claw_3po": {
      "groups": {
        "-100AAA": {"requireMention": true},
        "-100BBB": {"requireMention": false}
      }
    }
  }
}
```

**模式 B：Channel-level（完全继承）**
```json
{
  "groups": {
    "-100AAA": {"requireMention": true},
    "-100BBB": {"requireMention": false}
  },
  "accounts": {
    "claw_3po": {
      // 没有 groups 字段
    }
  }
}
```

详见：[MODES.md](references/MODES.md)

## 常见问题

### Q: Bot 无法在群里回复消息？

1. 检查配置状态：
   ```bash
   ./scripts/check-group.sh <group_id>
   ```

2. 验证 Privacy Mode：
   ```bash
   cd ~/repo/apps/openclaw && pnpm openclaw doctor
   ```
   查找 "Config allows unmentioned group messages" 警告

3. 触发第一条消息：
   - 在群里发消息或 @bot
   - 等待 session 创建

详见：[DIAGNOSTICS.md](references/DIAGNOSTICS.md)

### Q: 我收到了 "This group is not allowed" 错误

群组未在配置中。使用 `check-group.sh` 诊断：

```bash
./scripts/check-group.sh <group_id>
```

### Q: 配置键名带引号怎么办？

```json
"\"-1003896370559\"": {}  // 错误！
```

删除并重新添加：
```bash
./scripts/remove-group.sh -1003896370559 claw_3po
./scripts/add-group.sh -1003896370559 claw_3po
```

### Q: Privacy Mode 警告

`pnpm openclaw doctor` 显示警告？

**这是正常的**，如果你的 bot 确实需要 `requireMention=false`。

只有当你**想让 bot 需要 @ 才回复**时才需要：
1. 在 BotFather 中关闭 Privacy Mode（`/setprivacy` → `Enable`）
2. 或修改配置为 `requireMention=true`

## 工作流程示例

### 场景 1：新群组，让所有 bot 都能访问

```bash
# 1. 添加到 channel-level
cd ~/repo/apps/openclaw
pnpm openclaw config set 'channels.telegram.groups["-100NEWGROUPID"]' '{}'

# 2. 切换所有 bot 到 channel-level 模式
./skills/telegram-group-manager/scripts/use-channel-level.sh claw_3po
./skills/telegram-group-manager/scripts/use-channel-level.sh platinum

# 3. 重启 gateway
pnpm openclaw gateway restart

# 4. 在群里发消息触发第一条对话
```

### 场景 2：只有特定 bot 能访问群组

```bash
# 1. 直接添加到 account-level
./skills/telegram-group-manager/scripts/add-group.sh -100NEWGROUPID claw_3po false

# 2. 重启 gateway
cd ~/repo/apps/openclaw && pnpm openclaw gateway restart

# 3. 在群里发消息触发第一条对话
```

## 文档

- **[SKILL.md](SKILL.md)** - 快速路由和完整文档索引
- **[CONCEPTS.md](references/CONCEPTS.md)** - Account-level vs Channel-level 核心概念
- **[DIAGNOSTICS.md](references/DIAGNOSTICS.md)** - 完整诊断流程
- **[MODES.md](references/MODES.md)** - 两种配置模式详解
- **[PITFALLS.md](references/PITFALLS.md)** - 常见错误和解决方案
- **[ARCHITECTURE.md](references/ARCHITECTURE.md)** - 源码级解释

## 脚本说明

| 脚本 | 功能 | 安全 |
|------|------|------|
| `check-group.sh` | 检查群组配置状态和诊断建议 | 只读，无风险 |
| `add-group.sh` | 添加群组到 account-level | ✅ Proposal + confirm + git commit |
| `remove-group.sh` | 删除群组配置 | ✅ Proposal + confirm + git commit |
| `use-channel-level.sh` | 切换到 channel-level 模式 | ✅ Proposal + confirm + git commit |
| `list-groups.sh` | 列出所有群组配置 | 只读，无风险 |

## 参考链接

- **OpenClaw 源码**: `src/config/group-policy.ts`
- **Telegram Bot API**: https://core.telegram.org/bots/features#privacy-mode
- **Public Repo**: https://github.com/RadonX/openclaw-agent-claw-config

## License

MIT
