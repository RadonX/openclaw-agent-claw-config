# Common Pitfalls - 常见错误

## Pitfall 1: 配置键名带引号

### 症状

```json
"\"-1003896370559\"": {}  // 错误！
"-1003896370559": {}      // 正确
```

或者 `jq` 查询时找不到：
```bash
$ jq '.channels.telegram.accounts.claw_3po.groups["-1003896370559"]' ~/.openclaw/openclaw.json
null  # 应该有值但返回 null
```

### 原因

`pnpm openclaw config set` 在处理某些键名时会错误地添加引号。

### 解决

**不要使用：**
```bash
pnpm openclaw config set 'channels.telegram.accounts.claw_3po.groups["-1003896370559"]' '{}'
```

**使用脚本（推荐）：**
```bash
scripts/add-group.sh -1003896370559 claw_3po
```

脚本使用 Python，不会有引号问题。

### 验证

```bash
# 检查键是否正确
jq '.channels.telegram.accounts.claw_3po.groups | keys' ~/.openclaw/openclaw.json

# 应该看到：
# ["-100AAA", "-100BBB"]
# 而不是：
# ["\"-100AAA\"", "\"-100BBB\""]
```

## Pitfall 2: 期望混合模式

### 错误想法

"我想让 bot A 在群组 X 和 Y 工作，群组 Z 使用 channel-level。"

### 错误配置

```json
{
  "channels": {
    "telegram": {
      "groups": {
        "-100Z": {}
      },
      "accounts": {
        "bot_a": {
          "groups": {
            "-100X": {},
            "-100Y": {}
            // 期望 -100Z 也生效 ← 不可能！
          }
        }
      }
    }
  }
}
```

### 为什么不行

```typescript
const accountGroups = resolveAccountEntry(...)?.groups;
return accountGroups ?? channelConfig.groups;
//         ↑              ↑
//    如果存在就用它    否则用 channel-level
```

一旦 `accountGroups` 存在（哪怕只有一个群组），就**完全使用**它，不会再看 `channelConfig.groups`。

### 解决

**选项 1：** 完全使用 Account-level
```json
{
  "accounts": {
    "bot_a": {
      "groups": {
        "-100X": {},
        "-100Y": {},
        "-100Z": {}  // 也加到这里
      }
    }
  }
}
```

**选项 2：** 完全使用 Channel-level
```json
{
  "groups": {
    "-100X": {},
    "-100Y": {},
    "-100Z": {}
  },
  "accounts": {
    "bot_a": {
      // 删除 groups 字段
    }
  }
}
```

## Pitfall 3: 空对象 vs null

### 症状

设置了 `groups: {}`，但 bot 还是看不到 channel-level 的群组。

### 错误配置

```json
{
  "accounts": {
    "bot_a": {
      "groups": {}  // 空对象 ≠ null/undefined
    }
  }
}
```

### 为什么不行

- `groups: {}` → 空对象，仍然是 account-level，只是里面没有群组
- `groups: null` → null，会 fallback 到 channel-level
- 删除 `groups` 字段 → undefined，会 fallback 到 channel-level

### 解决

```bash
# 删除整个 groups 字段
pnpm openclaw config delete 'channels.telegram.accounts.bot_a.groups'

# 或设置为 null
pnpm openclaw config set 'channels.telegram.accounts.bot_a.groups' 'null'
```

## Pitfall 4: requireMention 不继承

### 症状

Channel-level 设置了 `requireMention: false`，但 bot 还是需要 @。

### 错误理解

"我设置了 channel-level 的 `requireMention: false`，所以所有 bot 都会继承这个设置。"

### 实际情况

```json
{
  "channels": {
    "telegram": {
      "groups": {
        "-100GROUP": {
          "requireMention": false
        }
      },
      "accounts": {
        "bot_a": {
          "groups": {
            "-100GROUP": {}  // 不会继承 false！默认是 true
          }
        }
      }
    }
  }
}
```

### 原因

`requireMention` 不会自动继承。如果 account-level 没有设置，默认值是 `true`。

### 解决

在 account-level 明确设置：
```bash
scripts/add-group.sh -100GROUP bot_a false
```

## Pitfall 5: Privacy Mode 警告误读

### 症状

`pnpm openclaw doctor` 显示：
```
telegram bot_a: Config allows unmentioned group messages
(requireMention=false). Telegram Bot API privacy mode will block
most group messages unless disabled.
```

### 错误理解

"这是错误，我需要修复它。"

### 实际情况

**这是正常警告，不是错误。**

如果你确实设置了 `requireMention=false`，这个警告是提醒你：
- Bot 的 Privacy Mode 需要关闭才能接收所有消息
- 如果你想让 bot 需要 @ 才回复，那么：
  - 要么改配置为 `requireMention=true`
  - 要么在 BotFather 关闭 Privacy Mode（`/setprivacy` → `Enable`）

### 何时需要修复

**只有在以下情况才需要修复：**
- 你**想要** bot 需要 @ 才回复，但设置了 `requireMention=false`

**修复：**
```bash
pnpm openclaw config set 'channels.telegram.accounts.bot_a.groups["-100GROUP"].requireMention' 'true'
```

## Pitfall 6: 修改配置后忘记重启

### 症状

修改了配置，但 bot 还是不工作。

### 原因

Gateway 还在使用旧配置。

### 解决

**重启 gateway：**
```bash
cd ~/repo/apps/openclaw && pnpm openclaw gateway restart
```

**或者等待热加载（某些修改）：**
- 修改 `groups` 配置会自动热加载
- 但建议总是重启以确保生效

### 验证

```bash
# 检查日志确认重启
tail -50 ~/.openclaw/logs/gateway.log | grep "starting provider"
```

## Pitfall 7: 没有触发第一条消息

### 症状

配置都正确，但 bot 还是不会回复。

### 原因

群里还没有发生过任何对话，所以：
- 没有创建 session
- 没有创建 binding
- Bot 不知道要在这个群里工作

### 解决

**在群里：**
1. 发送任何消息
2. 或者 @bot

**然后等待：**
- Gateway 会自动创建 session
- 会自动创建 binding
- 之后 bot 就能正常工作了

### 验证

```bash
# 检查是否有 session
ls -la ~/.openclaw/agents/<agent-id>/sessions/

# 检查是否有 binding
jq '.bindings[] | select(.conversation.chatId == "<group_id>")' ~/.openclaw/openclaw.json
```

## Pitfall 8: 误删配置

### 症状

不小心删除了重要配置。

### 预防

**在修改前先提交 git：**
```bash
cd ~/.openclaw
git add openclaw.json
git commit -m "before modifying group config"
```

**或创建 backup：**
```bash
cp ~/.openclaw/openclaw.json ~/.openclaw/openclaw.json.bak
```

### 恢复

**从 git 恢复：**
```bash
cd ~/.openclaw
git checkout HEAD -- openclaw.json
```

**从 backup 恢复：**
```bash
cp ~/.openclaw/openclaw.json.bak ~/.openclaw/openclaw.json
```

## 检查清单

在修改配置前，检查：

- [ ] 我理解 account-level vs channel-level 的优先级吗？
- [ ] 我知道我在用哪种模式吗？
- [ ] 我修改配置前提交 git 了吗？
- [ ] 我修改完后会重启 gateway 吗？
- [ ] 我会在群里发消息触发第一条对话吗？
- [ ] 我知道如何验证配置是否生效吗？

如果所有问题都是"是"，那你准备好了！
