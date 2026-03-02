# Skill: config-guardian

**A proactive auditor for your `openclaw.json` configuration.**

This skill encodes hard-won lessons from past incidents into an automated checkup. It helps you identify "silent breaking change" risks in your configuration *before* you upgrade and experience unexpected behavior.

## Description

The `config-guardian` reviews your `openclaw.json` against a knowledge base of known configuration "traps" and best practices. It's designed to catch issues like:

*   **Incomplete Configurations**: Where omitting a key causes the system to fall back to a new, potentially destructive default behavior after an application update.
*   **Legacy Settings**: Highlighting deprecated fields that should be migrated.
*   **Risky Defaults**: Pointing out settings that rely on an application's implicit defaults, which might change in a future version.

The goal is to make your configuration more explicit, resilient, and future-proof.

## Usage

To run the configuration audit, simply execute the skill's primary script.

### Syntax
```bash
/path/to/your/skills/config-guardian/scripts/audit.sh
```

### Example
```bash
./skills/config-guardian/scripts/audit.sh
```

### Example Output (if an issue is found)
```
🛡️  Auditing OpenClaw configuration: /Users/user/.openclaw/openclaw.json
룰  Using rules from: skills/config-guardian/references/best_practices.json

🚨 WARNING: Incomplete Session Reset Policy Detected!
   ------------------------------------------------
   Check ID:      SESSION_RESET_POLICY_INCOMPLETE
   Missing Type:  'group'

   Risk:
   Your 'session.resetByType' configuration is missing entries for one or more session types. This can cause them to fall back to the application's default reset policy (e.g., 'daily'), leading to unexpected data loss after an upgrade. It is strongly recommended to explicitly define a policy for all types: 'direct', 'group', and 'thread'.

   Recommended explicit configuration for 'group':
   {"mode":"idle","idleMinutes":43200}

   To fix, run: openclaw config set session.resetByType.group '{"mode":"idle","idleMinutes":43200}'
   ------------------------------------------------
```

## How it Works

The skill uses a simple but powerful mechanism:
1.  **`audit.sh`**: The main script that orchestrates the check.
2.  **`references/best_practices.json`**: A JSON file containing a list of checks to perform. Each check includes:
    *   A `path` to query in `openclaw.json` using `jq`.
    *   The `expected_keys` or values for that path.
    *   A human-readable `remediation` message explaining the risk.
    *   A `recommendation` for the fix.

This design is extensible. As we learn from new incidents, we can simply add more checks to the `best_practices.json` file without needing to modify the script.
