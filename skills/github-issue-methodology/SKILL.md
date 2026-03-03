# How to Comprehensively Address GitHub Issues

A methodology for investigating, fixing, and validating issues in any open-source project.

## Overview

This skill provides a systematic approach to addressing GitHub issues, from initial investigation to merged PR. It emphasizes **autonomous research**, **exploration of existing patterns**, and **comprehensive testing**.

## When to Use This Skill

Use this methodology when:
- You encounter a bug in an open-source project
- You want to contribute a fix
- You need to understand a codebase quickly
- You want to avoid common pitfalls that slow down PR review

## Core Principles

### 1. Autonomous Research First

Before writing any code:

✅ **Read the project's documentation:**
- Check for `CLAUDE.md`, `CONTRIBUTING.md`, `README.md`
- Look for testing guidelines and development workflows
- Understand the project's structure and conventions

✅ **Explore existing code patterns:**
- Find related test files (`*.test.ts`, `*.spec.ts`)
- Look for test harnesses and fixtures
- Study how similar bugs were fixed before

❌ **Don't wait for reviewers to guide you:**
- Reviewers are there to validate, not teach
- Delaying until review feedback slows everyone down
- Be proactive in your research

### 2. Understand the Problem Deeply

Before proposing a solution:

✅ **Reproduce the bug:**
- Set up the project locally
- Create minimal reproduction cases
- Verify the issue actually exists

✅ **Investigate the root cause:**
- Use debuggers and logging
- Trace execution paths
- Identify edge cases

✅ **Document your findings:**
- Write clear issue descriptions
- Include diagnostic evidence (logs, screenshots)
- Link to relevant code sections

### 3. Explore Existing Solutions

Before implementing from scratch:

✅ **Check for similar fixes:**
- Search git history for related commits
- Look for similar PRs that were merged
- Study established patterns in the codebase

✅ **Use existing tooling:**
- Test harnesses and fixtures
- Helper functions and utilities
- CI/CD pipelines

### 4. Implement with Tests First

✅ **Write tests before or with your fix:**
- Tests document expected behavior
- Tests prevent regressions
- Tests speed up review (reviewers trust tests more than code)

✅ **Test edge cases:**
- Boundary conditions
- Error cases
- Platform-specific behavior

✅ **Use established test patterns:**
- Follow the project's testing conventions
- Use existing test harnesses
- Parameterize tests when appropriate

### 5. Validate Thoroughly

Before submitting:

✅ **Run the project's test suite:**
- `pnpm test`, `npm test`, `make test`, etc.
- Fix any failing tests
- Ensure coverage doesn't decrease

✅ **Test manually:**
- Verify the fix works in real scenarios
- Check for unintended side effects
- Test on multiple platforms if applicable

✅ **Check CI/CD requirements:**
- Linting passes
- Type checking passes
- All automated checks pass

### 6. Write Clear PRs

✅ **Title should be descriptive:**
- `[Bug] Fix: <what was broken>`
- `[Feature] Add: <what was added>`
- Include affected component or module

✅ **Description should include:**
- Problem summary (what & why)
- Root cause analysis
- Solution overview
- Testing evidence
- Breaking changes (if any)

✅ **Keep PRs focused:**
- One logical change per PR
- Don't mix refactoring with fixes
- Small, reviewable diffs

### 7. Respond to Reviews Quickly

✅ **Address feedback promptly:**
- Update code within hours, not days
- Clarify confusion immediately
- Don't let reviews stale

✅ **Iterative improvement:**
- Use new commits for improvements (not force-pushes unless agreed)
- Mark outdated conversations as resolved
- Keep the conversation moving forward

## Common Pitfalls to Avoid

### ❌ Reacting Instead of Researching

**Bad:** Waiting for reviewers to suggest the right approach

**Good:** Exploring the codebase and finding the solution yourself

### ❌ Writing Code Without Understanding

**Bad:** Implementing the first solution that comes to mind

**Good:** Investigating root cause, exploring patterns, then implementing

### ❌ Skipping Tests

**Bad:** "I'll add tests later" or "Tests are optional"

**Good:** Writing tests alongside the fix, using established harnesses

### ❌ Moving Too Slowly

**Bad:** Spending days perfecting a PR

**Good:** Shipping a functional fix quickly, iterating based on feedback

### ❌ Ignoring Project Conventions

**Bad:** Using your preferred style instead of project patterns

**Good:** Following established conventions in the codebase

## Example Workflow

### Step 1: Investigate (1-2 hours)

```bash
# Clone and explore
git clone <repo>
cd <repo>

# Read documentation
cat CLAUDE.md CONTRIBUTING.md README.md

# Find relevant code
grep -r "related_function" src/
find . -name "*.test.ts" | xargs grep -l "related"
```

### Step 2: Reproduce and Diagnose (1-2 hours)

```bash
# Set up environment
npm install

# Run existing tests
npm test

# Add debug logging
# Reproduce bug
# Identify root cause
```

### Step 3: Implement with Tests (2-4 hours)

```bash
# Write test first
cat > src/bug.fix.test.ts << 'EOF'
// Test case for the bug
EOF

# Implement fix
vim src/bug.ts

# Verify tests pass
npm test

# Add edge case tests
# Parameterize if needed
```

### Step 4: Validate and Submit (1 hour)

```bash
# Run full test suite
npm test

# Check linting
npm run lint

# Type check
npm run typecheck

# Commit and push
git add .
git commit -m "Fix: <description>"
git push
```

### Step 5: Open PR (30 minutes)

```bash
# Create PR with clear description
gh pr create --title "Fix: <description>" --body "$(cat PR_TEMPLATE.md)"
```

### Step 6: Address Reviews (1-2 hours)

- Respond within hours, not days
- Make requested changes promptly
- Keep conversation moving

**Total time:** 6-12 hours from issue to merged PR

## Advanced Techniques

### Leveraging Seed Documentation

Many projects provide AI/developer seed documentation:

- **`CLAUDE.md`**: Project-specific guidance for AI/human collaborators
- **`CONTRIBUTING.md`**: Contribution guidelines
- **`README.md`**: Project overview and setup

**How to use:**
1. Read these files first before exploring code
2. Follow the documented conventions
3. Use suggested workflows and tooling

### Finding Test Patterns

Every project has testing patterns. Find them:

```bash
# Find test files
find . -name "*.test.ts" -o -name "*.spec.ts"

# Look for test harnesses
grep -r "describe\|it\|test" --include="*.test.ts" | head

# Find fixtures
find . -name "*fixture*" -o -name "*harness*"
```

### Understanding CI/CD

Check how the project validates changes:

```bash
# GitHub Actions
cat .github/workflows/*.yml

# CI scripts
cat scripts/ci*

# Pre-commit hooks
cat .husky/*
```

## Measuring Success

You're addressing issues comprehensively if:

✅ **Speed:** PR submitted within 24 hours of starting
✅ **Quality:** All tests pass, no regressions
✅ **Review:** Merged within 1-2 review cycles
✅ **Impact:** Fix solves the problem without side effects

## Case Study: What Went Wrong

**Example:** Addressing a Telegram Forum bug

**What happened:**
1. Found bug, opened issue
2. Implemented fix quickly
3. Submitted PR without comprehensive tests
4. Another contributor submitted better PR with tests
5. Their PR was merged; mine was superseded

**What went wrong:**
- ❌ Didn't explore existing test harnesses
- ❌ Didn't write comprehensive tests upfront
- ❌ Waited for reviewer to suggest better approach
- ❌ Moved too slowly (took hours, they took minutes)

**What should have happened:**
1. ✅ Read `CLAUDE.md` and `CONTRIBUTING.md` first
2. ✅ Explored `src/telegram/*.test.ts` for patterns
3. ✅ Found test harness `bot-message-context.test-harness.ts`
4. ✅ Wrote tests alongside the fix
5. ✅ Submitted complete PR within 1-2 hours
6. ✅ Been the first PR merged

## Resources

- **GitHub Skills:** https://skills.github.com/
- **Open Source Guides:** https://opensource.guide/
- **How to Contribute to Open Source:** https://opensource.com/article/19/7/how-contribute-open-source

## See Also

- `skill-creator`: How to package skills for reuse
- `coding-agent`: How to delegate complex coding tasks
- `session-logs`: How to learn from past interactions