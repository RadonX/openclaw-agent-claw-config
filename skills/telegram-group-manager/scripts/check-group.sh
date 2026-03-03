#!/bin/bash
# check-group.sh: 检查群组配置状态

set -euo pipefail

OPENCLAW_DIR="${HOME}/.openclaw"
CONFIG_FILE="${OPENCLAW_DIR}/openclaw.json"
OPENCLAW_CLI="${HOME}/repo/apps/openclaw"

GROUP_ID="${1:-}"
ACCOUNT_ID="${2:-}"

if [[ -z "$GROUP_ID" ]]; then
  echo "❌ 用法: $0 <group_id> [account_id]"
  echo ""
  echo "示例:"
  echo "  $0 -1003896370559          # 检查所有 bot"
  echo "  $0 -1003896370559 claw_3po # 检查特定 bot"
  exit 1
fi

echo "🔍 检查群组配置: ${GROUP_ID}"
echo ""

# 1. 检查 channel-level
echo "📋 Channel-level 配置:"
CHANNEL_EXISTS=$(jq -r ".channels.telegram.groups[\"${GROUP_ID}\"] // \"不存在\"" "${CONFIG_FILE}")
if [[ "$CHANNEL_EXISTS" == "不存在" ]]; then
  echo "  ❌ 群组不在 channel-level groups 中"
else
  echo "  ✅ 群组在 channel-level groups 中"
  jq ".channels.telegram.groups[\"${GROUP_ID}\"]" "${CONFIG_FILE}" | sed 's/^/     /'
fi
echo ""

# 2. 检查所有 account-level
echo "🤖 Account-level 配置:"
ACCOUNTS=($(jq -r '.channels.telegram.accounts | keys[]' "${CONFIG_FILE}"))

FOUND=false
for acct in "${ACCOUNTS[@]}"; do
  if [[ -n "$ACCOUNT_ID" ]] && [[ "$acct" != "$ACCOUNT_ID" ]]; then
    continue
  fi

  ACCT_GROUPS=$(jq -r ".channels.telegram.accounts[\"${acct}\"].groups // \"{}\"" "${CONFIG_FILE}")
  GROUP_EXISTS=$(echo "$ACCT_GROUPS" | jq -r ".[\"${GROUP_ID}\"] // \"不存在\"")

  if [[ "$GROUP_EXISTS" != "不存在" ]]; then
    FOUND=true
    echo "  📌 ${acct}:"
    echo "$ACCT_GROUPS" | jq ".[\"${GROUP_ID}\"]" | sed 's/^/       /'
    echo ""
  fi
done

if [[ "$FOUND" == "false" ]]; then
  echo "  ℹ️  没有 account-level 配置此群组"
fi
echo ""

# 3. 诊断建议
echo "💡 诊断建议:"

if [[ "$CHANNEL_EXISTS" == "不存在" ]] && [[ "$FOUND" == "false" ]]; then
  echo "  ❌ 群组未在任何 level 配置"
  echo "  → 运行: scripts/add-group.sh ${GROUP_ID} <account_id>"
elif [[ "$CHANNEL_EXISTS" != "不存在" ]] && [[ "$FOUND" == "false" ]]; then
  echo "  ✅ 配置正确（channel-level）"
  echo "  → 所有 bot 都可以访问此群组"
elif [[ "$CHANNEL_EXISTS" == "不存在" ]] && [[ "$FOUND" == "true" ]]; then
  echo "  ⚠️  只有 account-level 配置"
  echo "  → 只有配置了的 bot 能访问"
else
  echo "  ⚠️  两个 level 都有配置"
  echo "  → Account-level 会覆盖 channel-level"
  echo "  → 建议统一到 channel-level 以简化管理"
fi
echo ""

# 4. Privacy Mode 检查
echo "🔒 Privacy Mode 状态:"
cd "$OPENCLAW_CLI" && pnpm openclaw doctor 2>&1 | grep -A 2 "telegram.*Config allows unmentioned" || echo "  ℹ️  无相关警告（或已正确配置）"
