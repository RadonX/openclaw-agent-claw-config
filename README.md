# openclaw-agent-claw-config

中文 | [English](./README.en.md)

这是一个**公开的、已脱敏的 OpenClaw Agent Workspace**，专门用于 **OpenClaw 配置管理**。

用途：你可以把它当作一个“可直接接入 OpenClaw 的现成工作区（Workspace）”，用来创建一个**隔离的 agent**（独立 sessions/记忆/人设文件）。

---

## 内容包含

- 人设/策略文件：`SOUL.md`, `AGENTS.md`, `USER.md`, `IDENTITY.md`, `TOOLS.md`, `HEARTBEAT.md`
- 一次性引导：`BOOTSTRAP.md`（完成引导后建议删除）
- 排障/Runbook（skills）：`skills/telegram-*/SKILL.md`
- 工具脚本/示例：`tools/`

## 快速开始（推荐：用 CLI 创建隔离 agent）

官方文档（建议先看）：
- Agent workspace 概念与布局：https://docs.openclaw.ai/concepts/agent-workspace
- Multi-agent / bindings 路由：https://docs.openclaw.ai/concepts/multi-agent
- CLI（`openclaw agents`）：https://docs.openclaw.ai/cli/agents
- Onboarding / bootstrap：https://docs.openclaw.ai/start/onboarding

> 提示：如果你是从 OpenClaw 源码仓库安装的，建议用 **pnpm** 来跑 CLI：
>
> ```bash
> cd <PATH_TO_OPENCLAW_REPO>
> pnpm openclaw ...
> ```
>
> 否则就用你机器上的 `openclaw` 二进制。

### 1）把 workspace 放到 `~/.openclaw/`

**方式 A：直接复制（最简单）**

```bash
cp -R ./openclaw-agent-claw-config ~/.openclaw/workspace-claw-config
```

**方式 B：git clone（推荐：方便更新）**

```bash
git clone <THIS_REPO_URL> ~/.openclaw/workspace-claw-config
```

### 2）创建 agent

```bash
pnpm openclaw agents add claw-config \
  --workspace ~/.openclaw/workspace-claw-config \
  --model openai-codex/gpt-5.2 \
  --non-interactive --json
```

这会把 agent 写入 `~/.openclaw/openclaw.json` 的 `agents.list[]`。

### 3）配置 bindings（把消息路由到这个 agent）

你需要在 `~/.openclaw/openclaw.json` 里添加一条 `bindings` 规则。

**例：把 Telegram bot account `claw_config_bot` 的消息都路由到该 agent**

```json5
{
  "agentId": "claw-config",
  "match": {
    "channel": "telegram",
    "accountId": "claw_config_bot"
  }
}
```

**例：只路由某个群/某个 topic（Forum thread）**

```json5
{
  agentId: "claw-config",
  match: {
    channel: "telegram",
    accountId: "claw_config_bot",
    peer: { kind: "group", id: "-1001234567890:topic:218" }
  }
}
```

### 4）重启 gateway 并验收

```bash
pnpm openclaw gateway restart
pnpm openclaw channels status --probe --timeout 20000
```

然后在目标 chat（DM/群/topic）里发一条测试消息，确认路由生效。

## Bootstrap / 本地化定制（OpenClaw 框架里的正确用法）

这个 workspace 自带 `BOOTSTRAP.md`，用于 **首次运行的一次性引导（ritual）**。

推荐流程是：
- 先把 agent 接入并开始对话（发一条消息触发首次 session）。
- 按 `BOOTSTRAP.md` 的引导完成“自我设定”。
- 引导会让你逐步完善/更新 `IDENTITY.md`、`USER.md`、`SOUL.md` 等文件。
- 完成后建议删除 `BOOTSTRAP.md`，避免以后重复触发。

**敏感信息**（bot token / API key）请只放在 **`~/.openclaw/openclaw.json`** 或本地 env 文件里，不要提交到 git。

## 安全与脱敏说明

本 repo 刻意避免包含：

- bot token / API key
- 设备标识、账号 id
- 作者机器的真实用户名/绝对路径
- runtime 产物（sessions/log/db）
