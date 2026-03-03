# Core Concepts - Account-level vs Channel-level

## 优先级规则（最重要）

```typescript
// src/config/group-policy.ts:298-299
const accountGroups = resolveAccountEntry(...)?.groups;
return accountGroups ?? channelConfig.groups;
```

| Account-level | 返回值 | 意味着 |
|---------------|--------|--------|
| 存在（非 null/undefined）| `accountGroups` | **完全使用** account-level |
| `null` 或 `undefined` | `channelConfig.groups` | **fallback 到** channel-level |

**关键：没有混合模式！** 不能"部分用 account，部分用 channel"。

## 两种配置模式

### 模式 A：Account-level 完全自定义

```json
{
  "channels": {
    "telegram": {
      "accounts": {
        "claw_3po": {
          "groups": {
            "-100AAA": {"requireMention": true},
            "-100BBB": {"requireMention": false}
          }
        }
      }
    }
  }
}
```

**特点：**
- 每个 bot 独立管理自己的群组列表
- 适合：不同 bot 需要不同群组权限的场景
- 缺点：配置冗余，管理复杂

### 模式 B：Channel-level 完全继承

```json
{
  "channels": {
    "telegram": {
      "groups": {
        "-100AAA": {"requireMention": true},
        "-100BBB": {"requireMention": false}
      },
      "accounts": {
        "claw_3po": {
          // 没有 groups 字段，或者 groups: null
        }
      }
    }
  }
}
```

**特点：**
- 所有 bot 共享同一个群组列表
- 适合：所有 bot 应该有相同群组权限的场景
- 优点：配置简洁，一处修改全局生效

## 如何检查当前模式

```bash
# 检查特定 bot
jq '.channels.telegram.accounts.claw_3po.groups' ~/.openclaw/openclaw.json

# 如果返回 null 或报错 → channel-level 模式
# 如果返回对象 → account-level 模式
```

## 如何切换模式

### 从 account-level 到 channel-level

```bash
scripts/use-channel-level.sh claw_3po
```

### 从 channel-level 到 account-level

```bash
# 添加第一个群组即可自动切换
scripts/add-group.sh -100NEWGROUP claw_3po true
```

## 常见误解

### ❌ 误解 1: "我可以混合使用"

```json
{
  "accounts": {
    "claw_3po": {
      "groups": {
        "-100AAA": {}
        // 期望其他群组用 channel-level ← 不可能！
      }
    }
  }
}
```

**真相：** 一旦 `groups` 字段存在，就**完全使用**它，不会再看 channel-level。

### ❌ 误解 2: "空对象 {} 会 fallback 到 channel-level"

```json
{
  "accounts": {
    "claw_3po": {
      "groups": {}  // 空对象 ≠ null/undefined
    }
  }
}
```

**真相：** 空对象 `{}` 仍然是 account-level，只是里面没有群组。要 fallback 必须**删除整个 `groups` 字段**或设为 `null`。

### ❌ 误解 3: "requireMention 会自动继承"

如果 channel-level 有 `requireMention: false`，但 account-level 没有这个配置：

```json
{
  "channels": {
    "telegram": {
      "groups": {
        "-100AAA": {"requireMention": false}
      },
      "accounts": {
        "claw_3po": {
          "groups": {
            "-100AAA": {}  // 不会继承 false！
          }
        }
      }
    }
  }
}
```

**真相：** `requireMention` 默认是 `true`，不会从 channel-level 继承。必须明确设置。

## 源码参考

- **文件**: `src/config/group-policy.ts`
- **函数**: `resolveChannelGroups()`
- **行号**: 298-299
- **在线**: https://github.com/openclaw/openclaw/blob/main/src/config/group-policy.ts
