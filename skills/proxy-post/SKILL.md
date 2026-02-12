---
name: proxy-post
description: Cross-group posting via proxy bot. Route messages from a high-privileged agent (main) to a low-privileged bot account in another group/channel. Use message tool with accountId to specify which bot sends. Covers warm-up strategies for topics/threads and troubleshooting why proxy messages don't appear.
---

# Proxy post (main → 分身代发)

## Goal

让 **main agent** 产出内容，但由 **另一个 bot 账户（分身）** 去指定群/频道/话题发帖。

核心手段：**`message` tool + `accountId` 参数**。

---

## 0) Preconditions

- 目标 bot 账户已在 `channels.{platform}.accounts` 配置
- 目标 bot 已加入目标群/频道
- 目标群在 bot 的 allowlist
- Topics/Threads 需要 `threadId` 参数

---

## 1) 代发方法

```
message(
    action="send",
    channel="telegram",      # telegram | discord | ...
    target="-100xxx",        # 群 ID
    message="内容",
    accountId="target_bot"   # 用哪个 bot 发
)
```

### 1.1 发到 Topic/Thread

```
message(
    action="send",
    channel="telegram",
    target="-100xxx",
    threadId=66,             # topic/thread ID
    message="内容",
    accountId="target_bot"
)
```

---

## 2) 为什么消息没出现？

| 原因 | 现象 | 解决 |
|------|------|------|
| Session 未创建 | 新 topic/thread 首次使用 | warm-up（见 2.1）|
| not-allowed | 群不在 allowlist | 加 allowlist |
| delivery 失败 | 网络/权限问题 | 查 logs |

### 2.1 Warm-up 方案

| 平台 | 方案 |
|------|------|
| Telegram | A) 人工 @ bot；B) MTProto user 发消息；C) Bot API 探针 |
| Discord | 人工在 thread 发消息触发 session |
| 通用 | 人工先发一条消息，让 OpenClaw 创建 session |

---

## 3) 关于 sessions_send（坑）

⚠️ **`sessions_send` 不适合代发**：

- 触发目标 agent 后，回复走 `announce` 模式
- announce 返回给调用者，**不会**自动发到目标群

**正确做法**：始终用 `message` tool + `accountId`。

---

## 4) 安全建议

- main 不常驻群：把群绑定到低权限 agent
- 代发用 allowlist 策略
- 高风险 warm-up 工具（如 user API）只做临时诊断
