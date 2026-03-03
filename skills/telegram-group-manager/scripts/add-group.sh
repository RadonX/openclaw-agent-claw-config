#!/bin/bash
# add-group.sh: 添加群组到 account-level

set -euo pipefail

OPENCLAW_DIR="${HOME}/.openclaw"
CONFIG_FILE="${OPENCLAW_DIR}/openclaw.json"
OPENCLAW_CLI="${HOME}/repo/apps/openclaw"

GROUP_ID="${1:-}"
ACCOUNT_ID="${2:-}"
REQUIRE_MENTION="${3:-true}"

if [[ -z "$GROUP_ID" ]] || [[ -z "$ACCOUNT_ID" ]]; then
  echo "❌ 用法: $0 <group_id> <account_id> [require_mention]"
  echo ""
  echo "示例:"
  echo "  $0 -1003896370559 claw_3po           # requireMention=true"
  echo "  $0 -1003896370559 claw_3po false      # requireMention=false"
  exit 1
fi

echo "➕ 添加群组配置"
echo "   群组: ${GROUP_ID}"
echo "   Bot: ${ACCOUNT_ID}"
echo "   RequireMention: ${REQUIRE_MENTION}"
echo ""

# 检查 account 是否存在
if ! jq -e ".channels.telegram.accounts[\"${ACCOUNT_ID}\"]" "${CONFIG_FILE}" >/dev/null 2>&1; then
  echo "❌ 错误: account '${ACCOUNT_ID}' 不存在"
  echo ""
  echo "可用的 accounts:"
  jq -r '.channels.telegram.accounts | keys[]' "${CONFIG_FILE}" | sed 's/^/  - /'
  exit 1
fi

# 检查是否已存在
EXISTS=$(jq -r ".channels.telegram.accounts[\"${ACCOUNT_ID}\"].groups[\"${GROUP_ID}\"] // \"不存在\"" "${CONFIG_FILE}")
if [[ "$EXISTS" != "不存在" ]]; then
  echo "⚠️  群组已存在于 ${ACCOUNT_ID} 的配置中"
  echo ""
  echo "当前配置:"
  jq ".channels.telegram.accounts[\"${ACCOUNT_ID}\"].groups[\"${GROUP_ID}\"]" "${CONFIG_FILE}"
  echo ""
  read -p "是否覆盖? (y/N) " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ 已取消"
    exit 1
  fi
fi

# 使用 Python 脚本安全地添加（避免 jq 引号问题）
python3 << EOF
import json

with open('${CONFIG_FILE}', 'r') as f:
    config = json.load(f)

# 确保 groups 对象存在
if 'groups' not in config['channels']['telegram']['accounts']['${ACCOUNT_ID}']:
    config['channels']['telegram']['accounts']['${ACCOUNT_ID}']['groups'] = {}

# 添加群组配置
config['channels']['telegram']['accounts']['${ACCOUNT_ID}']['groups']['${GROUP_ID}'] = {
    "requireMention": ${REQUIRE_MENTION}
}

with open('${CONFIG_FILE}', 'w') as f:
    json.dump(config, f, indent=2)

print("✅ 配置已更新")
EOF

if [[ $? -eq 0 ]]; then
  echo ""
  echo "📋 验证配置:"
  jq ".channels.telegram.accounts[\"${ACCOUNT_ID}\"].groups[\"${GROUP_ID}\"]" "${CONFIG_FILE}"
  echo ""
  echo "🔄 下一步: 重启 gateway 或等待热加载"
  echo "   cd ${OPENCLAW_CLI} && pnpm openclaw gateway restart"
fi
