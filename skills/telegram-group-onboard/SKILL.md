---
name: telegram-group-onboard
description: End-to-end checklist + diagnosis playbook for onboarding the OpenClaw Telegram bot into a new Telegram group (including Topics). Use when someone says they added the bot to a group but it doesn’t reply, asks for the group chat_id, wants to route the group to a specific agent (main vs restricted bot), or you see symptoms like "no session created" / "not-allowed" / mention gating confusion.
---

# Telegram Group Onboard

把 OpenClaw bot 拉进一个新的 Telegram 群，并让它**能收**、**能回**、**能路由到正确 agent**，本质是三段链路：

1) **Telegram → Bot API 投递**（你 @ 了没？隐私模式？Topic/thread？）
2) **OpenClaw Channel 接收与准入**（是否被 allowlist / access-group / not-allowed 拦掉）
3) **OpenClaw Session/Binding 路由**（落到哪个 agent：main / tg-botbot；requireMention 等策略）

这份 skill 给出一个“从 0 到通”的最短流程 + 一套排障决策树。

---

## Workflow Decision Tree（先选路径）

- **目标是“拿 chat_id”**：跳到「A. 先拿 chat_id」
- **目标是“群里能正常触发回复”**：跳到「B. 打通入站与准入」
- **目标是“指定用 main 还是受限 agent”**：跳到「C. 路由/绑定策略」
- **遇到“我明明发了，但 sessions.json 没有新群”**：跳到「D. 排障：为什么 session 没产生？」

---

## A. 先拿 chat_id（最稳的方法：从 gateway logs 拿）

### A1) 让 Telegram 产生一条“肯定会投递”的消息
在目标群里发送（建议）：
- `@<bot_username> ping`

要点：
- **必须是蓝色 mention**（从自动补全点选），不是手打字符串。
- 如果群是 Topics/Forum：先在 **General/topic:1** 里发。

### A2) 在 OpenClaw 机器上看 gateway logs
**方法 1：用 CLI（推荐）**
```bash
openclaw logs --limit 200 --plain
```

**方法 2：直接看 log 文件**
```bash
tail -500 ~/.openclaw/logs/gateway.log | grep -E "(chatId|title|migrated|not-allowed)"
```

你要找的关键信息一般长这样：
- `chatId: -100...`
- `title: "群名"`
- `Group migrated: "群名" <old_id> → <new_id>`（群升级的情况）
- 以及可能的 `reason: not-allowed`

> 经验法则：
> - **如果 logs 里能看到 chatId/title**：说明 Telegram→OpenClaw 这段至少“到 gateway 了”。
> - **如果看到 `Group migrated`**：说明群从普通群升级成 supergroup，chat_id 会变，用新的那个。
> - 但如果同时出现 `not-allowed`：说明被 OpenClaw 的 Telegram channel 准入策略拦截（见 B）。

---

## B. 打通入站与准入（最常见卡点：not-allowed）

### B1) Telegram 侧确认（最少动作）
- 确认你拉进群的 bot 用户名是你想要的那个：`@<bot_username>`
- 如果想让 bot **不 @ 也能看到群消息**：
  - BotFather → `Group Privacy` → Disable
  - 把 bot **踢出群再拉进来**（Telegram 经常需要这一刀才生效）

> 但注意：就算 Telegram 投递成功，OpenClaw 也可能拦（下一步）。

### B2) OpenClaw 侧：把群加入 telegram allowlist
典型现象：
- 群里“@了”但 bot 不回
- `agents/*/sessions/sessions.json` 没有新 `telegram:group:-100...`
- gateway logs 里出现：`reason=not-allowed`

修复：在 `~/.openclaw/openclaw.json` 里加入：

```json5
{
  "channels": {
    "telegram": {
      "groups": {
        "-100xxxxxxxxxx": {
          "requireMention": false,
          "systemPrompt": "..."
        }
      }
    }
  }
}
```

**`requireMention` 怎么设？**
- `false`：bot 会回复群里所有消息（像私聊一样，适合只有你的群或“准私聊”群）
- `true`：只有被 @ 时才回复（适合多人群，避免刷屏）

**默认建议：**
- 如果是“你和 bot 的准私聊群”→ `requireMention: false`
- 如果是“多人群”→ `requireMention: true`（避免刷屏）

然后重启 gateway。

---

## C. 路由/绑定策略（main vs 受限 bot）

你需要明确：这个群到底是“真群”（多人）还是“你和 bot 的准私聊”。

### C1) 推荐默认：群 → 受限 agent（更安全）
用 `bindings` 把某个群固定路由到受限 agent（比如 `tg-botbot`）：

```json5
{
  "bindings": [
    {
      "agentId": "tg-botbot",
      "match": {
        "channel": "telegram",
        "peer": { "kind": "group", "id": "-100xxxxxxxxxx" }
      }
    }
  ]
}
```

### C2) 特例：你明确要暴露 main agent
适用：这个群只有你（且你接受 main 的 host 工具能力被“群消息”触发）。

建议同时做两件事降低误触发：
- `requireMention: true`（必须 @ 才响应）
- 把群当作 allowlist（只放这个群）

---

## D. 排障：为什么 session 没产生？（最关键的判定树）

### D1) 先看 gateway logs：有没有 chatId/title？
- **没有任何这条群消息的痕迹**：
  - Telegram 没投递到 bot（@错对象、隐私模式、权限、Topic/thread、群类型限制）
- **有 chatId/title 但 not-allowed**：
  - OpenClaw 拦在 channel 准入层（去 B2 加 groups allowlist）
- **没有 not-allowed，但仍然不回复**：
  - 可能是 routing/binding 走到了另一个 agent
  - 或者 requireMention / topic/thread 不一致导致你“看不到它回的那条”（尤其是 Topics 群）

### D2) 用 sessions.json 验证“是否进了会话系统”
一旦准入成功，应该能在某个 agent 的 `sessions.json` 看到类似：
- `telegram:group:-100...` 或 `telegram:group:-100...:topic:<n>`

**快速查看所有 Telegram 群会话：**
```bash
cat ~/.openclaw/agents/main/sessions/sessions.json | jq -r 'keys[]' | grep "telegram:group"
```

如果 logs 有但 sessions 没有：优先怀疑 **not-allowed / access-groups**。

---

## 常用检查清单（复制粘贴用）

- [ ] 群里 @ 的是 `@<bot_username>`（蓝色 mention）
- [ ] BotFather Group Privacy 是否符合预期（Disable 才能收普通消息）
- [ ] Topics 群：我发/我看的是否同一个 topic
- [ ] gateway logs 里能否看到 chatId/title（包括 `Group migrated` 消息）
- [ ] 是否出现 `reason=not-allowed`
- [ ] `openclaw.json` 里是否把该 `chat_id` 加进 `channels.telegram.groups`（或 per-account groups）
- [ ] 是否需要 `bindings` 固定路由到 main / tg-botbot
- [ ] 重启 gateway 后再验证一次（logs + sessions.json）

### 可选：变更后让 bot 在群里“自报到”一条

当你完成 allowlist/binding/requireMention 等变更，并准备向用户汇报进度时，可以加一个 **可选步骤**：

- 先问一句：**“要不要我让 bot 在目标群里发一条确认消息？”**
- 如果用户确认，就用 message tool 让对应账号在目标群/Topic 里发一条“已进驻/已生效/当前策略”的短消息。

这样用户不需要翻 logs，就能直接在群里看到变更是否生效。

---

## 快速搜索 chat_id 的命令速查

**方法 1：grep gateway.log（推荐）**
```bash
tail -2000 ~/.openclaw/logs/gateway.log | grep -E "(chatId|title|migrated)"
```

**方法 2：用 zsh/jq**
```bash
cat ~/.openclaw/agents/main/sessions/sessions.json | jq -r 'keys[]' | grep "telegram:group"
```

**方法 3：直接查某个群名**
```bash
grep -r "<your bot name>" ~/.openclaw/logs/
```

### 可选工具：Bot API Topic Ping

用 Bot API 验证 bot 能否在某个 topic 发言：

```bash
# 使用本 skill 的脚本
node scripts/tg-topic-ping.mjs <bot_token> <chat_id> <topic_id> "test message"
```

详见 `scripts/README-tg-topic-ping.md`。
