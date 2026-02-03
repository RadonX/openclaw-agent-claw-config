---
name: telegram-proxy-post
description: Cross-group posting via Telegram proxy bot. Route messages from a high-privileged OpenClaw agent (main) to a low-privileged Telegram bot/agent by sending content into the target group/topic session (sessionKey like telegram:group:-100…[:topic:<id>]). Use when you need a proxy bot to post into another Telegram group/topic, or when validating forum topic routing after changing bindings.
---

# Telegram proxy post (main → 分身代发)

## Goal

让 **main** 在后台产出内容，但由 **群内的低权限 bot/agent（分身，比如 tg-botbot）** 去指定群/指定 topic 发帖。

核心手段：**把文案投递到“目标群/目标 topic”的 sessionKey**（等价于你在那个群里对 bot 说话）。

---

## 0) Preconditions（很重要）

- 目标群里必须已经把“分身对应的 bot 账号”拉进群。
- OpenClaw 必须能识别到目标群（allowlist / not-allowed 不拦）。
- **Forum topics：**每个 topic 需要一个 sessionKey（`:topic:<id>`）。

---

## 1) 找到目标会话的 sessionKey

### 1.1 规则

- 普通群：`telegram:group:-1001234567890`
- Topics 群某话题：`telegram:group:-1001234567890:topic:66`

### 1.2 获取方式

- 最稳：在目标群/目标 topic 里 **@ 一次 bot**，让 gateway 创建 session；然后在控制端查 sessionKey。
- 控制端查：用 `sessions_list` 过滤 telegram（或在 agent 的 sessions.json 里 grep）。

---

## 2) main 指示分身代发：投递消息到 session

用 `sessions_send(sessionKey, message)`：

- message = 要发布的文案（或命令）
- sessionKey = 目标群/目标 topic

> 这等价于“你在那个群里对 bot 说这句话”。

### 2.1 批量投递（多个 topics）

- 并行对多个 `telegram:group:-100…:topic:<id>` 调 `sessions_send`
- 常用于验证 bindings/topic 白名单

---

## 3) Topics 群的坑：topic session 没出现怎么办？

现象：你能构造出 `...:topic:<id>`，但群里没有任何消息出现。

原因（最常见）：**该 topic 从未有入站消息触发 OpenClaw 建 session / 补齐 deliveryContext.threadId**。

### 3.1 无法靠 Bot API “伪造入站”

- Bot API 只能出站 `sendMessage`，不能伪造 Telegram→bot 的 inbound update。
- 所以不能用 bot token 去“模拟入站触发 /status”。

### 3.2 可选解决方案

A) 人工 warm-up（最低成本）：在该 topic 里 @ 一次 bot。

B) 自动 warm-up / 端到端触发（更强）：**用用户号 MTProto** 在 topic 发 `@bot /status`。

- 工具脚本（本 workspace）：`tools/tg_user_topic_trigger.py`
- ⚠️ 如果使用主号：
  - 不要放 cron
  - 不要无人值守
  - session 文件等价登录态，严禁泄漏/提交 git

C) 仅验证“能发言”（不验证 OpenClaw /status）：用 Bot API 出站探针。

- 工具脚本：`tools/tg-topic-ping.mjs`

---

## 4) 安全建议（强烈）

- main 不常驻群：把群绑定到低权限 agent；main 只做后台决策。
- 代发采用 allowlist 的 topic 白名单策略：新 topic 默认不触达高权限。
- 对“主号 userbot”工具：只做临时诊断，不做长期自动化。
