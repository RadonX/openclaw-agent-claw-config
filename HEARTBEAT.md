# HEARTBEAT.md

# Checklist（仅放“周期性检查”，不要放事件触发流程）

- gateway/agent 是否健康：`openclaw status` / 最近 logs 是否有 409 / not-allowed / crash
- 本 workspace 是否有未提交的 persona/policy 变更：`git status`（仅提醒，不要自动提交/推送）
- 是否需要把最近的重要配置决策整理进 `MEMORY.md`
