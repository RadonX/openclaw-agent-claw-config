# Changelog Analysis Patterns for Silent Breaking Changes

This document contains patterns and keywords to aid in the semantic analysis of application release notes. The goal is to identify changes that, while not explicitly labeled "breaking," have a high potential to alter default behavior or invalidate existing configurations.

## High-Risk Keywords

These words often signal deep architectural changes where unintended side effects are common.

- `refactor`
- `rework`
- `unify`
- `centralize`
- `modernize`
- `improve handling of`
- `streamline`
- `overhaul`

## Behavioral Change Keywords

These words point directly to changes in application logic or defaults.

- `new default`
- `behavior changed`
- `now falls back to`
- `validation logic`
- `schema updated`
- `policy` (e.g., "add new ... policy")

## Deprecation & Migration Keywords

These words signal a future breaking change and require proactive configuration updates.

- `deprecate`
- `legacy`
- `migrated to`
- `no longer supports`
- `will be removed in`

## Analysis Process

When reviewing a changelog for a pending upgrade:
1.  Scan for any of the keywords listed above.
2.  For each match, identify the specific feature area (e.g., `session`, `security`, `plugins`).
3.  Cross-reference this feature area with your live `openclaw.json` configuration.
4.  Ask the critical question: **"Does my current configuration rely on an implicit behavior in this area that this change might affect?"**
5.  Formulate a "what-if" failure scenario based on a potential change in the default behavior.
