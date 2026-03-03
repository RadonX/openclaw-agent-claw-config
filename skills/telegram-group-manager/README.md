# Telegram Group Manager

OpenClaw Telegram 群组配置管理工具集。

## 快速开始

### 1. 检查群组状态

```bash
# 检查特定群组在所有 bot 的配置
./scripts/check-group.sh -1003896370559

# 检查特定 bot
./scripts/check-group.sh -1003896370559 claw_3po
```

### 2. 添加群组到 bot

```bash
# 添加群组（默认 requireMention=true）
./scripts/add-group.sh -1003896370559 claw_3po

# 设置 requireMention=false
./scripts/add-group.sh -1003896370559 claw_3po false
```

### 3. 切换到 channel-level 模式

```bash
# 删除 account-level groups，使用 channel-level
./scripts/use-channel-level.sh claw_3po
```

### 4. 列出所有群组

```bash
# 列出所有配置
./scripts/list-groups.sh

# 只看 channel-level
./scripts/list-groups.sh --level channel

# 只看特定 bot
./scripts/list-groups.sh --account claw_3po
```

## 核心概念

### Account-level vs Channel-level

**优先级规则（重要）：**
- Account-level groups 存在 → **完全使用** account-level
- Account-level groups 不存在（null） → fallback 到 channel-level
- **没有混合模式** —— 不能"部分用 account，部分用 channel"

代码逻辑：
```typescript
const accountGroups = resolveAccountEntry(...)?.groups;
return accountGroups ?? channelConfig.groups;
//         ↑              ↑
//    如果存在就用它    否则用 channel-level
```

### 两种配置模式

**模式 A：Account-level 完全自定义**
```json
{
  "channels": {
    "telegram": {
      "accounts": {
        "claw_3po": {
          "groups": {
            "-1003357882514": {...},
            "-1003593489589": {...}
          }
        }
      }
    }
  }
}
```
- 每个 bot 独立管理自己的群组列表
- 适合：不同 bot 需要不同群组权限的场景

**模式 B：Account-level 完全继承**
```json
{
  "channels": {
    "telegram": {
      "groups": {
        "-1003357882514": {...},
        "-1003593489589": {...}
      },
      "accounts": {
        "claw_3po": {
          // 没有 groups 字段
        }
      }
    }
  }
}
```
- 所有 bot 共享同一个群组列表
- 适合：所有 bot 应该有相同群组权限的场景

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

3. 检查日志：
   ```bash
   tail -100 ~/.openclaw/logs/gateway.log | grep <group_id>
   ```

4. 触发第一条消息：
   - 在群里发消息或 @bot
   - 等待 session 创建

### Q: 我收到了 "This group is not allowed" 错误

这意味着群组配置有问题。使用 `check-group.sh` 诊断：

```bash
./scripts/check-group.sh <group_id>
```

### Q: 配置键名带引号怎么办？

如果看到：
```json
"\"-1003896370559\"": {}  // 错误！
```

删除并重新添加：
```bash
./scripts/remove-group.sh -1003896370559 claw_3po
./scripts/add-group.sh -1003896370559 claw_3po
```

### Q: Privacy Mode 警告

`pnpm openclaw doctor` 显示 "Config allows unmentioned group messages" 警告？

**这是正常的**，如果你的 bot 确实需要 `requireMention=false`。

只有在你**想让 bot 需要 @ 才回复**时才需要：
1. 在 BotFather 中关闭 Privacy Mode（`/setprivacy` → `Enable`）
2. 或修改配置为 `requireMention=true`

## 工作流程示例

### 场景 1：新群组，让所有 bot 都能访问

```bash
# 1. 添加到 channel-level
cd ~/repo/apps/openclaw
pnpm openclaw config set 'channels.telegram.groups["-100NEWGROUPID"]' '{}'

# 2. 删除 account-level 配置（如果有）
./skills/telegram-group-manager/scripts/use-channel-level.sh claw_3po
./skills/telegram-group-manager/scripts/use-channel-level.sh platinum
# ... 对每个 bot 重复

# 3. 重启 gateway
pnpm openclaw gateway restart
```

### 场景 2：只有特定 bot 能访问群组

```bash
# 直接添加到 account-level
./skills/telegram-group-manager/scripts/add-group.sh -100NEWGROUPID claw_3po false

# 重启 gateway
cd ~/repo/apps/openclaw && pnpm openclaw gateway restart
```

## 脚本说明

| 脚本 | 功能 |
|------|------|
| `check-group.sh` | 检查群组配置状态，提供诊断建议 |
| `add-group.sh` | 添加群组到 account-level |
| `remove-group.sh` | 删除群组配置 |
| `use-channel-level.sh` | 切换到 channel-level 模式 |
| `list-groups.sh` | 列出所有群组配置 |

## 参考

- **OpenClaw 源码**: `src/config/group-policy.ts`
- **Telegram Bot API**: https://core.telegram.org/bots/features#privacy-mode
- **相关 Skill**:
  - `telegram-outage-debug`
  - `telegram-session-injection-debug`
