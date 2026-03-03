# Telegram Group Manager

管理 OpenClaw Telegram 群组配置的工具集。

**用途：**
- 检查群组配置状态
- 添加/删除群组到 account 或 channel level
- 诊断 bot 为什么无法在群里工作
- 理解 account-level vs channel-level 配置优先级

**何时使用：**
- Bot 无法在群里回复消息
- 需要让新 bot 加入现有群组
- 需要批量管理多个 bot 的群组权限
- 调试 "This group is not allowed" 错误

**工作流程：**

## 1. 检查群组配置状态

```bash
scripts/check-group.sh <group_id> [account_id]
```

示例：
```bash
# 检查群组 -1003896370559 在所有 bot 的配置状态
scripts/check-group.sh -1003896370559

# 检查特定 bot
scripts/check-group.sh -1003896370559 claw_3po
```

输出包括：
- Channel-level 是否有此群组
- 每个 account-level 是否有此群组
- `requireMention` 设置
- `allowFrom` 限制
- 推荐的修复方案

## 2. 添加群组到 bot

```bash
scripts/add-group.sh <group_id> <account_id> [require_mention]
```

示例：
```bash
# 添加群组，默认 requireMention=true
scripts/add-group.sh -1003896370559 claw_3po

# 添加群组，设置 requireMention=false
scripts/add-group.sh -1003896370559 claw_3po false
```

## 3. 删除群组配置

```bash
scripts/remove-group.sh <group_id> <account_id>
```

## 4. 切换到 channel-level 模式

```bash
scripts/use-channel-level.sh <account_id>
```

删除 account-level groups，让 bot 完全使用 channel-level 配置。

## 5. 列出所有群组

```bash
scripts/list-groups.sh [--account <account_id>] [--level channel|account]
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

### 常见错误

**错误 1：配置键名带引号**
```json
"\"-1003896370559\"": {}  // 错误！
"-1003896370559": {}      // 正确
```

**错误 2：期望混合模式**
```json
{
  "accounts": {
    "claw_3po": {
      "groups": {
        "-100AAA": {}  // 想用这个
        // 期望其他群组用 channel-level ← 不可能！
      }
    }
  }
}
```

**错误 3：Privacy Mode 未关闭**
- 即使配置正确，bot 也收不到消息
- 解决：BotFather → `/setprivacy` → `Disable`

## 诊断流程

当 bot 无法在群里工作时：

1. **检查配置状态**
   ```bash
   scripts/check-group.sh <group_id>
   ```

2. **验证 Privacy Mode**
   ```bash
   pnpm openclaw doctor
   ```
   查找 "Config allows unmentioned group messages" 警告

3. **检查日志**
   ```bash
   tail -100 ~/.openclaw/logs/gateway.log | grep <group_id>
   ```

4. **触发第一条消息**
   - 在群里发消息或 @bot
   - 等待 session 创建

## 参考

- **OpenClaw 源码**: `src/config/group-policy.ts`
- **Telegram Bot API**: https://core.telegram.org/bots/features#privacy-mode
- **相关 Skill**: `telegram-outage-debug`, `telegram-session-injection-debug`
