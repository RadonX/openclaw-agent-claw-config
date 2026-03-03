#!/bin/bash
# list-groups.sh: 列出群组配置

set -euo pipefail

OPENCLAW_DIR="${HOME}/.openclaw"
CONFIG_FILE="${OPENCLAW_DIR}/openclaw.json"

ACCOUNT_ID=""
LEVEL=""

while [[ $# -gt 0 ]]; do
  case $1 in
    --account)
      ACCOUNT_ID="$2"
      shift 2
      ;;
    --level)
      LEVEL="$2"
      shift 2
      ;;
    *)
      echo "❌ 未知参数: $1"
      exit 1
      ;;
  esac
done

echo "📋 群组配置列表"
echo ""

# Channel-level
if [[ -z "$LEVEL" ]] || [[ "$LEVEL" == "channel" ]]; then
  echo "🌐 Channel-level groups:"
  echo ""

  CHANNEL_GROUPS=$(jq -r '.channels.telegram.groups | keys[]' "${CONFIG_FILE}" 2>/dev/null || echo "")

  if [[ -z "$CHANNEL_GROUPS" ]]; then
    echo "  (无)"
  else
    for group in $CHANNEL_GROUPS; do
      REQUIRE_MENTION=$(jq -r ".channels.telegram.groups[\"${group}\"].requireMention // \"未设置\"" "${CONFIG_FILE}")
      echo "  📌 ${group}"
      echo "     requireMention: ${REQUIRE_MENTION}"
    done
  fi
  echo ""
fi

# Account-level
if [[ -z "$LEVEL" ]] || [[ "$LEVEL" == "account" ]]; then
  echo "🤖 Account-level groups:"
  echo ""

  ACCOUNTS=($(jq -r '.channels.telegram.accounts | keys[]' "${CONFIG_FILE}"))

  for acct in "${ACCOUNTS[@]}"; do
    if [[ -n "$ACCOUNT_ID" ]] && [[ "$acct" != "$ACCOUNT_ID" ]]; then
      continue
    fi

    ACCT_GROUPS=$(jq -r ".channels.telegram.accounts[\"${acct}\"].groups // \"{}\"" "${CONFIG_FILE}")
    GROUP_COUNT=$(echo "$ACCT_GROUPS" | jq 'length')

    if [[ "$GROUP_COUNT" -eq 0 ]]; then
      continue
    fi

    echo "  🤖 ${acct} (${GROUP_COUNT} groups)"

    echo "$ACCT_GROUPS" | jq -r 'keys[]' | while read -r group; do
      REQUIRE_MENTION=$(echo "$ACCT_GROUPS" | jq -r ".[\"${group}\"].requireMention // \"未设置\"")
      ALLOW_FROM=$(echo "$ACCT_GROUPS" | jq -r ".[\"${group}\"].allowFrom // \"无限制\"")
      echo "    📌 ${group}"
      echo "       requireMention: ${REQUIRE_MENTION}"
      echo "       allowFrom: ${ALLOW_FROM}"
    done
    echo ""
  done
fi
