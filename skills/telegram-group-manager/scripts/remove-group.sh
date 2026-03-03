#!/bin/bash
# remove-group.sh: 删除群组配置

set -euo pipefail

OPENCLAW_DIR="${HOME}/.openclaw"
CONFIG_FILE="${OPENCLAW_DIR}/openclaw.json"

GROUP_ID="${1:-}"
ACCOUNT_ID="${2:-}"

if [[ -z "$GROUP_ID" ]] || [[ -z "$ACCOUNT_ID" ]]; then
  echo "❌ 用法: $0 <group_id> <account_id>"
  echo ""
  echo "示例:"
  echo "  $0 -1003896370559 claw_3po"
  exit 1
fi

echo "🗑️  删除群组配置"
echo "   群组: ${GROUP_ID}"
echo "   Bot: ${ACCOUNT_ID}"
echo ""

# 检查是否存在
EXISTS=$(jq -r ".channels.telegram.accounts[\"${ACCOUNT_ID}\"].groups[\"${GROUP_ID}\"] // \"不存在\"" "${CONFIG_FILE}")
if [[ "$EXISTS" == "不存在" ]]; then
  echo "❌ 错误: 群组不在 ${ACCOUNT_ID} 的配置中"
  exit 1
fi

# 显示当前配置
echo "当前配置:"
jq ".channels.telegram.accounts[\"${ACCOUNT_ID}\"].groups[\"${GROUP_ID}\"]" "${CONFIG_FILE}"
echo ""

# 确认
read -p "确认删除? (y/N) " -n 1 -r
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

if '${GROUP_ID}' in config['channels']['telegram']['accounts']['${ACCOUNT_ID}']['groups']:
    del config['channels']['telegram']['accounts']['${ACCOUNT_ID}']['groups']['${GROUP_ID}']
    print("✅ 已删除群组配置")

    # 如果 groups 为空，删除整个 groups 字段
    if not config['channels']['telegram']['accounts']['${ACCOUNT_ID}']['groups']:
        del config['channels']['telegram']['accounts']['${ACCOUNT_ID}']['groups']
        print("ℹ️  groups 字段已删除（将使用 channel-level）")

with open('${CONFIG_FILE}', 'w') as f:
    json.dump(config, f, indent=2)
EOF

if [[ $? -eq 0 ]]; then
  echo ""
  echo "📋 配置已更新"
fi
