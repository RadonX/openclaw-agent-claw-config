#!/bin/bash
set -euo pipefail

# Find the OpenClaw configuration file and the skill's reference data.
# This makes the script runnable from anywhere.
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
CONFIG_PATH="${OPENCLAW_CONFIG:-$HOME/.openclaw/openclaw.json}"
RULES_PATH="$SCRIPT_DIR/../references/best_practices.json"

if [[ ! -f "$CONFIG_PATH" ]]; then
  echo "ERROR: OpenClaw config not found at $CONFIG_PATH" >&2
  exit 1
fi

echo "🛡️  Auditing OpenClaw configuration: $CONFIG_PATH"
echo "룰  Using rules from: $RULES_PATH"
echo ""

# Read the checks from our best practices knowledge base.
CHECKS=$(jq -c '.checks[]' "$RULES_PATH")
HAS_WARNINGS=0

# Iterate over each check defined in best_practices.json.
while IFS= read -r CHECK; do
  CHECK_ID=$(echo "$CHECK" | jq -r '.id')
  DESCRIPTION=$(echo "$CHECK" | jq -r '.description')
  JQ_PATH=$(echo "$CHECK" | jq -r '.path')
  
  # Check if the target path exists in the user's config.
  TARGET_VALUE=$(jq -r "$JQ_PATH" "$CONFIG_PATH")

  if [[ "$TARGET_VALUE" != "null" && -n "$TARGET_VALUE" ]]; then
    # The configuration path exists, now we perform the specific check logic.
    case "$CHECK_ID" in
      "SESSION_RESET_POLICY_INCOMPLETE")
        EXPECTED_KEYS=$(echo "$CHECK" | jq -r '.expected_keys[]')
        
        for KEY in $EXPECTED_KEYS; do
          # Check if each expected key is present in the user's config.
          if ! jq -e "$JQ_PATH | has(\"$KEY\")" "$CONFIG_PATH" > /dev/null; then
            HAS_WARNINGS=1
            REMEDIATION=$(echo "$CHECK" | jq -r '.remediation')
            RECOMMENDATION=$(echo "$CHECK" | jq -c '.recommendation')
            
            echo "🚨 WARNING: Incomplete Session Reset Policy Detected!"
            echo "   ------------------------------------------------"
            echo "   Check ID:      $CHECK_ID"
            echo "   Missing Type:  '$KEY'"
            echo ""
            echo "   Risk:"
            echo "   $REMEDIATION"
            echo ""
            echo "   Recommended explicit configuration for '$KEY':"
            echo "   $RECOMMENDATION"
            echo ""
            echo "   To fix, run: openclaw config set session.resetByType.$KEY '$RECOMMENDATION'"
            echo "   ------------------------------------------------"
            echo ""
          fi
        done
        ;;
    esac
  fi
done <<< "$CHECKS"

if [[ "$HAS_WARNINGS" -eq 0 ]]; then
  echo "✅  Configuration audit passed. No common issues found."
fi

exit "$HAS_WARNINGS"
