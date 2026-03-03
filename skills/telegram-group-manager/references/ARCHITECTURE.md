# Architecture - 源码级解释

## 核心函数

### resolveChannelGroups

**文件**: `src/config/group-policy.ts`
**行号**: 290-299

```typescript
function resolveChannelGroups(
  cfg: OpenClawConfig,
  channel: GroupPolicyChannel,
  accountId?: string | null,
): ChannelGroups | undefined {
  const normalizedAccountId = normalizeAccountId(accountId);
  const channelConfig = cfg.channels?.[channel] as
    | {
        accounts?: Record<string, { groups?: ChannelGroups }>;
        groups?: ChannelGroups;
      }
    | undefined;
  if (!channelConfig) {
    return undefined;
  }
  const accountGroups = resolveAccountEntry(channelConfig.accounts, normalizedAccountId)?.groups;
  return accountGroups ?? channelConfig.groups;
}
```

### 关键逻辑

```typescript
const accountGroups = resolveAccountEntry(channelConfig.accounts, normalizedAccountId)?.groups;
return accountGroups ?? channelConfig.groups;
```

**解读：**
1. 先尝试获取 account-level 的 `groups`
2. 如果存在（非 null/undefined），返回它
3. 如果不存在，返回 channel-level 的 `groups`

**注意：**
- `??` 是 nullish coalescing operator
- 只在左边是 `null` 或 `undefined` 时才返回右边
- 空对象 `{}` 不是 null/undefined，所以会使用它

## 群组允许检查

### resolveChannelGroupPolicy

**文件**: `src/config/group-policy.ts`
**行号**: 340-380

```typescript
export function resolveChannelGroupPolicy(params: {
  cfg: OpenClawConfig;
  channel: GroupPolicyChannel;
  groupId?: string | null;
  accountId?: string | null;
  groupIdCaseInsensitive?: boolean;
  /** When true, sender-level filtering (groupAllowFrom) is configured upstream. */
  hasGroupAllowFrom?: boolean;
}): ChannelGroupPolicy {
  const { cfg, channel } = params;
  const groups = resolveChannelGroups(cfg, channel, params.accountId);
  const groupPolicy = resolveChannelGroupPolicyMode(cfg, channel, params.accountId);
  const hasGroups = Boolean(groups && Object.keys(groups).length > 0);
  const allowlistEnabled = groupPolicy === "allowlist" || hasGroups;
  const normalizedId = params.groupId?.trim();
  const groupConfig = normalizedId
    ? resolveChannelGroupConfig(groups, normalizedId, params.groupIdCaseInsensitive)
    : undefined;
  const defaultConfig = groups?.["*"];
  const allowAll = allowlistEnabled && Boolean(groups && Object.hasOwn(groups, "*"));
  // When groupPolicy is "allowlist" with groupAllowFrom but no explicit groups,
  // allow the group through — sender-level filtering handles access control.
  const senderFilterBypass =
    groupPolicy === "allowlist" && !hasGroups && Boolean(params.hasGroupAllowFrom);
  const allowed =
    groupPolicy === "disabled"
      ? false
      : !allowlistEnabled || allowAll || Boolean(groupConfig) || senderFilterBypass;
  return {
    allowlistEnabled,
    allowed,
    groupConfig,
    defaultConfig,
  };
}
```

### 关键逻辑

```typescript
const allowed =
  groupPolicy === "disabled"
    ? false
    : !allowlistEnabled || allowAll || Boolean(groupConfig) || senderFilterBypass;
```

**解读：**
- `groupPolicy === "disabled"` → 不允许
- `!allowlistEnabled` → 如果没有启用 allowlist，允许
- `allowAll` → 如果有 `*` 通配符，允许
- `Boolean(groupConfig)` → 如果群组有配置，允许
- `senderFilterBypass` → 如果有 sender-level 过滤，允许

## "This group is not allowed" 错误

### 触发位置

**文件**: `src/telegram/bot-native-commands.ts`

```typescript
if (policyAccess.reason === "group-chat-not-allowed") {
  return await sendAuthMessage("This group is not allowed.");
}
```

### 何时触发

`resolveChannelGroupPolicy` 返回：
```typescript
{
  allowed: false,
  reason: "group-chat-not-allowed"
}
```

**条件：**
- `allowlistEnabled = true`
- `allowAll = false`
- `Boolean(groupConfig) = false`（群组没有配置）
- `senderFilterBypass = false`

## resolveChannelGroupConfig

**文件**: `src/config/group-policy.ts`
**行号**: 230-245

```typescript
function resolveChannelGroupConfig(
  groups: ChannelGroups | undefined,
  groupId: string,
  caseInsensitive = false,
): ChannelGroupConfig | undefined {
  if (!groups) {
    return undefined;
  }
  const direct = groups[groupId];
  if (direct) {
    return direct;
  }
  if (!caseInsensitive) {
    return undefined;
  }
  const target = groupId.toLowerCase();
  const matchedKey = Object.keys(groups).find((key) => key !== "*" && key.toLowerCase() === target);
  if (!matchedKey) {
    return undefined;
  }
  return groups[matchedKey];
}
```

### 关键逻辑

1. 先尝试直接匹配 `groups[groupId]`
2. 如果没有找到且 `caseInsensitive = true`，尝试大小写不敏感匹配
3. 如果还是没有，返回 `undefined`

## groupPolicy 解析

### resolveChannelGroupPolicyMode

**文件**: `src/config/group-policy.ts`
**行号**: 301-323

```typescript
function resolveChannelGroupPolicyMode(
  cfg: OpenClawConfig,
  channel: GroupPolicyChannel,
  accountId?: string | null,
): ChannelGroupPolicyMode | undefined {
  const normalizedAccountId = normalizeAccountId(accountId);
  const channelConfig = cfg.channels?.[channel] as
    | {
        groupPolicy?: ChannelGroupPolicyMode;
        accounts?: Record<string, { groupPolicy?: ChannelGroupPolicyMode }>;
      }
    | undefined;
  if (!channelConfig) {
    return undefined;
  }
  const accountPolicy = resolveAccountEntry(
    channelConfig.accounts,
    normalizedAccountId,
  )?.groupPolicy;
  return accountPolicy ?? channelConfig.groupPolicy;
}
```

### 关键逻辑

```typescript
return accountPolicy ?? channelConfig.groupPolicy;
```

**和 `resolveChannelGroups` 一样的模式：**
- Account-level 优先
- Fallback 到 channel-level

## 完整流程图

```
用户消息 → Telegram
  ↓
Gateway 接收
  ↓
resolveChannelGroupPolicy()
  ├─ resolveChannelGroups()
  │   ├─ account-level groups 存在？
  │   │   ├─ 是 → 使用 account-level
  │   │   └─ 否 → 使用 channel-level
  │   ↓
  │   返回 groups 对象
  │
  ├─ resolveChannelGroupPolicyMode()
  │   ├─ account-level groupPolicy 存在？
  │   │   ├─ 是 → 使用 account-level
  │   │   └─ 否 → 使用 channel-level
  │   ↓
  │   返回 groupPolicy ("open" | "allowlist" | "disabled")
  │
  ├─ resolveChannelGroupConfig()
  │   ├─ 群组在 groups 中？
  │   │   ├─ 是 → 返回 groupConfig
  │   │   └─ 否 → 返回 undefined
  │   ↓
  │   返回群组配置或 undefined
  │
  └─ 计算 allowed
      ├─ groupPolicy === "disabled" → false
      ├─ !allowlistEnabled → true
      ├─ allowAll (有 "*") → true
      ├─ Boolean(groupConfig) → true
      └─ senderFilterBypass → true
  ↓
allowed?
  ├─ true → 处理消息
  └─ false → 返回 "This group is not allowed"
```

## 在线参考

- **源码**: https://github.com/openclaw/openclaw/blob/main/src/config/group-policy.ts
- **类型定义**: `src/config/types.telegram.ts`
- **Telegram Bot API**: https://core.telegram.org/bots/api
