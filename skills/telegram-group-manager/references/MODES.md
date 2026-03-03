# Modes - Account-level vs Channel-level

详细说明两种配置模式的使用场景和优缺点。

## 模式 A：Account-level（完全自定义）

### 配置示例

```json
{
  "channels": {
    "telegram": {
      "groups": {
        "-100PUBLIC": {"requireMention": true}
      },
      "accounts": {
        "admin_bot": {
          "groups": {
            "-100PRIVATE1": {"requireMention": false},
            "-100PRIVATE2": {"requireMention": false}
          }
        },
        "public_bot": {
          "groups": {
            "-100PUBLIC": {"requireMention": true}
          }
        }
      }
    }
  }
}
```

### 使用场景

1. **不同 bot 有不同职责**
   - Admin bot 管理私有群组
   - Public bot 处理公共群组

2. **需要精细控制权限**
   - Bot A 能在群组 X 和 Y 工作
   - Bot B 只能在群组 X 工作

3. **Bot 需要不同的 requireMention 设置**
   - Admin bot 不需要 @（`requireMention: false`）
   - Public bot 需要 @（`requireMention: true`）

### 优点

- ✅ 每个 bot 独立配置
- ✅ 灵活性高
- ✅ 可以设置不同的 `allowFrom`、`requireMention` 等

### 缺点

- ❌ 配置冗余（每个 bot 都要列一遍）
- ❌ 管理复杂（添加新群组要改多个地方）
- ❌ 容易出错（可能漏掉某个 bot）

### 推荐使用

当你需要**不同 bot 有完全不同的群组权限**时。

## 模式 B：Channel-level（完全继承）

### 配置示例

```json
{
  "channels": {
    "telegram": {
      "groups": {
        "-100GROUP1": {"requireMention": true},
        "-100GROUP2": {"requireMention": false}
      },
      "accounts": {
        "bot1": {
          // 没有 groups 字段
        },
        "bot2": {
          // 没有 groups 字段
        }
      }
    }
  }
}
```

### 使用场景

1. **所有 bot 应该有相同的群组权限**
   - 所有 bot 都可以在相同的群组工作

2. **简化管理**
   - 添加新群组：只改一个地方
   - 添加新 bot：不需要配置群组

3. **统一配置**
   - 所有 bot 使用相同的 `requireMention` 设置

### 优点

- ✅ 配置简洁（一处修改全局生效）
- ✅ 易于管理（添加新 bot 不需要配置群组）
- ✅ 不容易出错（只有一份配置）

### 缺点

- ❌ 缺乏灵活性（所有 bot 必须相同）
- ❌ 无法针对特定 bot 设置不同权限

### 推荐使用

当你需要**所有 bot 有相同的群组权限**时（大多数情况）。

## 如何选择模式？

### 决策树

```
需要不同 bot 有不同权限？
├── 是 → 使用 Account-level
└── 否 → 使用 Channel-level
```

### 具体问题

1. **是否所有 bot 都应该能访问所有群组？**
   - 是 → Channel-level
   - 否 → Account-level

2. **是否有些 bot 需要不同的 requireMention 设置？**
   - 是 → Account-level
   - 否 → Channel-level

3. **是否想简化管理（添加新 bot 时不需要配置群组）？**
   - 是 → Channel-level
   - 否 → Account-level

## 混合场景

### 部分用 Account-level，部分用 Channel-level

**问题：** 能不能有些 bot 用 account-level，有些用 channel-level？

**答案：** 可以！

```json
{
  "channels": {
    "telegram": {
      "groups": {
        "-100COMMON": {"requireMention": true}
      },
      "accounts": {
        "special_bot": {
          "groups": {
            "-100SPECIAL": {"requireMention": false}
          }
        },
        "normal_bot": {
          // 没有 groups → 使用 channel-level
        }
      }
    }
  }
}
```

**效果：**
- `special_bot` 只能访问 `-100SPECIAL`
- `normal_bot` 只能访问 `-100COMMON`

## 迁移指南

### 从 Account-level 到 Channel-level

```bash
# 1. 确保所有需要的群组都在 channel-level
pnpm openclaw config set 'channels.telegram.groups["-100GROUP"]' '{}'

# 2. 删除 account-level 配置
scripts/use-channel-level.sh bot1
scripts/use-channel-level.sh bot2

# 3. 重启 gateway
pnpm openclaw gateway restart
```

### 从 Channel-level 到 Account-level

```bash
# 1. 为每个 bot 添加需要的群组
scripts/add-group.sh -100GROUP bot1
scripts/add-group.sh -100GROUP bot2

# 2. （可选）删除 channel-level 配置
pnpm openclaw config delete 'channels.telegram.groups["-100GROUP"]'

# 3. 重启 gateway
pnpm openclaw gateway restart
```

## 最佳实践

1. **默认使用 Channel-level**
   - 除非你有明确的理由使用 Account-level

2. **保持一致性**
   - 不要在同一个项目中混用两种模式（除非有特殊需求）

3. **文档化你的选择**
   - 在项目的 README 中说明为什么选择某种模式

4. **定期审查**
   - 如果发现 account-level 配置变得冗余，考虑迁移到 channel-level
