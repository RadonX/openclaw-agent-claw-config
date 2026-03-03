# GitHub Issue Methodology

A comprehensive methodology for addressing GitHub issues in open-source projects.

## Overview

This skill teaches a systematic approach to investigating, fixing, and validating issues in any open-source project. It emphasizes autonomous research, exploration of existing patterns, and comprehensive testing.

## Key Principles

1. **Autonomous Research First** - Read documentation, explore code patterns, don't wait for reviewers
2. **Understand Deeply** - Reproduce bugs, investigate root causes, document findings
3. **Explore Existing Solutions** - Use test harnesses, follow established patterns
4. **Implement with Tests** - Write tests alongside fixes, cover edge cases
5. **Validate Thoroughly** - Run test suites, check CI/CD requirements
6. **Write Clear PRs** - Descriptive titles, clear descriptions, focused changes
7. **Respond Quickly** - Address feedback within hours, not days

## What You'll Learn

- How to explore a new codebase efficiently
- How to find and use existing test patterns
- How to write comprehensive tests that speed up review
- How to avoid common pitfalls that slow down PRs
- How to ship quality fixes quickly (6-12 hours from issue to merge)

## Target Audience

- AI agents contributing to open-source
- Developers new to open-source contributions
- Anyone who wants to improve their PR workflow

## Installation

This skill is designed to be part of an OpenClaw agent's skill collection. To add it:

```bash
# Clone to your skills directory
git clone https://github.com/your-org/awesome-moltbot-skills.git
cp -r awesome-moltbot-skills/github-issue-methodology /path/to/your/skills/
```

## Usage

When you encounter a GitHub issue:

1. **Read this skill first** - Internalize the methodology
2. **Follow the workflow** - Step-by-step from investigation to PR
3. **Avoid pitfalls** - Learn from common mistakes
4. **Ship quickly** - Submit complete PRs within 24 hours

## Case Study

This skill was distilled from a real-world experience where a PR was superseded because:
- Tests were not written upfront
- Existing test harnesses were not explored
- The contributor waited for reviewer guidance instead of researching autonomously
- Another contributor shipped faster with comprehensive tests

The skill captures lessons learned to help you avoid the same mistakes.

## Resources

- [GitHub Skills](https://skills.github.com/)
- [Open Source Guides](https://opensource.guide/)
- [How to Contribute to Open Source](https://opensource.com/article/19/7/how-contribute-open-source)

## License

MIT License - See LICENSE file for details