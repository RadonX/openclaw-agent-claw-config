# Diagnostics - "This group is not allowed"

当 bot 无法在群里工作时，按照此流程诊断。

## 第一步：检查配置状态

```bash
scripts/check-group.sh <group_id>
```

**输出解读：**
- ✅ Channel-level 有 → 所有 bot 都可以访问
- 📌 Account-level 有 → 只有配置了的 bot 能访问
- ❌ 两个都没有 → 群组未配置

**预期结果：**
- 如果你想让**所有 bot** 访问 → 应该在 channel-level
- 如果你只想让**特定 bot** 访问 → 应该在 account-level

## 第二步：验证 Privacy Mode

```bash
cd ~/repo/apps/openclaw && pnpm openclaw doctor
```

**查找警告：**
```
telegram <bot>: Config allows unmentioned group messages
(requireMention=false). Telegram Bot API privacy mode will block
most group messages unless disabled.
```

**这是什么意思？**
- 这是**正常警告**，不是错误
- 如果你确实设置了 `requireMention=false`，可以忽略
- 只有当你**想让 bot 需要 @ 才回复**时才需要：
  - 在 BotFather 中关闭 Privacy Mode（`/setprivacy` → `Enable`）
  - 或修改配置为 `requireMention=true`

**如何关闭 Privacy Mode：**
1. 在 Telegram 中打开 [@BotFather](https://t.me/BotFather)
2. 发送 `/botlist`
3. 选择你的 bot
4. 发送 `/setprivacy`
5. 选择 `Disable`
6. 重启 OpenClaw gateway

## 第三步：检查 Gateway 日志

```bash
tail -100 ~/.openclaw/logs/gateway.log | grep <group_id>
```

**查找：**
- `starting provider` → bot 已启动
- `sendMessage ok` → bot 发送消息成功
- `group-chat-not-allowed` → 群组不在 allowlist 中
- `health-monitor: restarting` → bot 频繁重启（可能卡死）

## 第四步：检查 Session 和 Binding

```bash
# 检查是否有 session
ls -la ~/.openclaw/agents/<agent-id>/sessions/

# 检查是否有 binding
jq '.bindings[] | select(.conversation.chatId == "<group_id>")' ~/.openclaw/openclaw.json
```

**如果都没有：**
- 说明群组里**还没有发生过任何对话**
- 解决：在群里发一条消息或 @bot，触发第一条对话

## 第五步：触发第一条消息

**在群里：**
1. 发送任何消息
2. 或者 @bot

**然后等待：**
- Gateway 会自动创建 session
- 会自动创建 binding
- 之后 bot 就能正常工作了

## 常见错误及解决

### 错误 1: "This group is not allowed"

**原因：** 群组未在配置中

**解决：**
```bash
# 添加到 channel-level（所有 bot）
pnpm openclaw config set 'channels.telegram.groups["<group_id>"]' '{}'

# 或添加到 account-level（特定 bot）
scripts/add-group.sh <group_id> <account_id>
```

### 错误 2: 配置了但 bot 不回复

**原因 1：** 还没触发第一条消息
**解决：** 在群里发消息

**原因 2：** Privacy Mode 开启
**解决：** BotFather → `/setprivacy` → `Disable`

**原因 3：** `requireMention=true` 但你没有 @
**解决：** @bot 或改为 `requireMention=false`

### 错误 3: 配置键名带引号

**症状：**
```json
"\"-1003896370559\"": {}  // 错误！
```

**原因：** `pnpm openclaw config set` 的 bug

**解决：**
```bash
# 删除错误的键
scripts/remove-group.sh -1003896370559 claw_3po

# 重新添加（脚本用 Python，不会出错）
scripts/add-group.sh -1003896370559 claw_3po
```

## 完整示例

### 场景：新群组，让所有 bot 都能访问

```bash
# 1. 添加到 channel-level
cd ~/repo/apps/openclaw
pnpm openclaw config set 'channels.telegram.groups["-100NEWGROUP"]' '{}'

# 2. 检查状态
skills/telegram-group-manager/scripts/check-group.sh -100NEWGROUP

# 3. 删除 account-level 配置（如果有）
skills/telegram-group-manager/scripts/use-channel-level.sh claw_3po
skills/telegram-group-manager/scripts/use-channel-level.sh platinum

# 4. 重启 gateway
pnpm openclaw gateway restart

# 5. 在群里发消息触发第一条对话
```

### 场景：只有特定 bot 能访问

```bash
# 1. 直接添加到 account-level
skills/telegram-group-manager/scripts/add-group.sh -100NEWGROUP claw_3po false

# 2. 检查状态
skills/telegram-group-manager/scripts/check-group.sh -100NEWGROUP claw_3po

# 3. 重启 gateway
cd ~/repo/apps/openclaw && pnpm openclaw gateway restart

# 4. 在群里发消息触发第一条对话
```

## 何时需要重启 Gateway？

**需要重启：**
- 修改了 `channels.telegram.groups`
- 修改了 `channels.telegram.accounts.*.groups`
- 修改了 `channels.telegram.accounts.*.groupPolicy`

**不需要重启（热加载）：**
- 修改了 bindings（自动生效）

**如何重启：**
```bash
cd ~/repo/apps/openclaw && pnpm openclaw gateway restart
```

## 相关文档

- **Telegram Bot API**: https://core.telegram.org/bots/features#privacy-mode
- **OpenClaw 源码**: `src/config/group-policy.ts`
- **相关 Skill**:
  - `telegram-outage-debug`
  - `telegram-session-injection-debug`
