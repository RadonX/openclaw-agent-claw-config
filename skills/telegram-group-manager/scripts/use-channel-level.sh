#!/bin/bash
# use-channel-level.sh: 删除 account-level groups，使用 channel-level

set -euo pipefail

OPENCLAW_DIR="${HOME}/.openclaw"
CONFIG_FILE="${OPENCLAW_DIR}/openclaw.json"

ACCOUNT_ID="${1:-}"

if [[ -z "$ACCOUNT_ID" ]]; then
  echo "❌ 用法: $0 <account_id>"
  echo ""
  echo "示例:"
  echo "  $0 claw_3po"
  exit 1
fi

echo "🔄 切换到 channel-level 模式"
echo "   Bot: ${ACCOUNT_ID}"
echo ""

# 检查是否有 groups
HAS_GROUPS=$(jq -e ".channels.telegram.accounts[\"${ACCOUNT_ID}\"].groups" "${CONFIG_FILE}" 2>/dev/null && echo "yes" || echo "no")

if [[ "$HAS_GROUPS" == "no" ]]; then
  echo "ℹ️  ${ACCOUNT_ID} 没有 account-level groups"
  echo "   已经在使用 channel-level"
  exit 0
fi

# 显示当前 groups
echo "📋 当前 account-level groups:"
jq ".channels.telegram.accounts[\"${ACCOUNT_ID}\"].groups | keys" "${CONFIG_FILE}" | sed 's/^/  /'
echo ""

COUNT=$(jq ".channels.telegram.accounts[\"${ACCOUNT_ID}\"].groups | length" "${CONFIG_FILE}")
echo "⚠️  将删除 ${COUNT} 个群组配置"
echo "   删除后，此 bot 将使用 channel-level groups"
echo ""

# 确认
read -p "确认切换? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo "❌ 已取消"
  exit 0
fi

# 使用 Python 删除
python3 << EOF
import json

with open('${CONFIG_FILE}', 'r') as f:
    config = json.load(f)

if 'groups' in config['channels']['telegram']['accounts']['${ACCOUNT_ID}']:
    count = len(config['channels']['telegram']['accounts']['${ACCOUNT_ID}']['groups'])
    del config['channels']['telegram']['accounts']['${ACCOUNT_ID}']['groups']
    print(f"✅ 已删除 {count} 个 account-level groups")
    print("ℹ️  现在使用 channel-level groups")

with open('${CONFIG_FILE}', 'w') as f:
    json.dump(config, f, indent=2)
EOF

if [[ $? -eq 0 ]]; then
  echo ""
  echo "📋 配置已更新"
  echo ""
  echo "🔄 下一步: 重启 gateway"
  echo "   cd ${HOME}/repo/apps/openclaw && pnpm openclaw gateway restart"
fi
