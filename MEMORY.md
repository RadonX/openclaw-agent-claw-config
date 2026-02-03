# MEMORY.md - Claw Config Bot

Curated long-term memory for configuration management.

## 重要决策

- **2026-02-01**: 创建独立的 claw-config agent，专门处理配置管理
  - 原因：避免 claw_config_bot 和 main agent 混淆
  - claw_config_bot 账号绑定到此 agent

- **2026-02-01**: 将 `default` 账户重命名为 `platinum`
  - 原因：`default` 命名容易混淆，`platinum` 更清晰（白金之星的 bot）

- **2026-02-02**: skill 来源（"skills 大超市"）以以下两个索引/目录为 source of truth
  - <https://github.com/VoltAgent/awesome-moltbot-skills>
  - <https://clawdhub.com>

## 配置架构理解

### Agents vs Bindings vs Channels

- **agents.list**: 定义 agent（工作空间 + 模型配置）
- **bindings**: 将 channel accounts 映射到 agents
- **channels.telegram.accounts**: 定义 Telegram bot 账户（token + 策略）

### OpenClaw 对 Bot 的认知

- OpenClaw 只知道 **bot token**，不知道 @username
- @username 是通过 `getMe()` API 获取的，仅用于日志显示
- 同一个 token 不能被多个进程同时使用（409 Conflict 错误）

## 常见问题

### 409 Conflict 错误
- 原因：同一个 bot token 被多个进程轮询
- 解决：确保只有一个 OpenClaw 实例在使用该 token
- 诊断：检查 `bindings` 和 `channels.telegram.accounts` 配置

### Workspace 默认值
- `agents.defaults.workspace`: `~/.openclaw/workspace`
- 如果 agent 不指定 workspace，会使用这个默认值
- 最佳实践：每个 agent 都应有独立的 workspace
