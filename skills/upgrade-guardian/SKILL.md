---
name: upgrade-guardian
description: A cognitive protocol for an agent to safely manage and audit OpenClaw application upgrades, preventing silent breaking changes. Use when an operator announces an intent to upgrade the application.
---

# Cognitive Protocol: The Upgrade Guardian

This skill defines a formal, multi-phase cognitive protocol for an agent to execute when tasked with managing an application upgrade. Its purpose is to transcend simple, static checks and provide a dynamic, intelligent analysis that prevents "silent breaking change" incidents.

**This is not a script.** It is a directive for higher-order reasoning.

## Core Principle

An application upgrade is a high-stakes event. The agent must not trust that the upgrade is safe. The agent must assume that any change can have unintended consequences on a stable configuration. The goal is to make implicit environmental assumptions explicit and resilient before they break.

## Protocol Activation

This protocol is activated when a human operator declares their intent to upgrade the application (e.g., "We are planning to upgrade OpenClaw from vA to vB").

## Phase 1: Information Gathering & Hypothesis

1.  **Ingest Release Notes:** Fetch the `CHANGELOG` or release notes for the target version range.
2.  **Semantic Analysis:** Perform a semantic analysis of the notes. Do not just search for "breaking change." Instead, use the patterns in `references/changelog_analysis_patterns.md` to identify changes that imply a shift in default behavior or internal logic.
3.  **Cross-Reference with Live Configuration:** Load the current `openclaw.json` into context. For every identified change, formulate a primary hypothesis by asking: **"Does our current configuration rely on an implicit behavior that this change might affect?"**

## Phase 2: Risk Assessment & Scenario Planning

1.  **Formulate "What-If" Scenarios:** Based on your hypotheses, generate concrete, testable failure scenarios.
    *   *Example A:* "What if 'improved session handling' means a new, destructive default for unconfigured session types? This would lead to data loss."
    *   *Example B:* "What if 'refactored security policy' means the `allowlist` now requires explicit IP ranges we haven't defined? This would lead to all plugin executions failing."
2.  **Quantify Risk:** Assign a risk score to each scenario based on **Impact** (e.g., data loss > temporary outage) and **Likelihood** (e.g., direct config overlap > tangential relation).
3.  **Generate Audit Report:** Present your analysis to the operator. This is not a pass/fail output. It is a strategic brief outlining potential risks and their predicted consequences.

    **Template for Audit Report:**
    > "Operator, I have analyzed the upcoming upgrade to `<VERSION>`. I have identified `<N>` potential breaking changes based on our current configuration.
    >
    > **High Risk #1: <Scenario Name>**
    > *   **Evidence:** The changelog states: '`<Quote from changelog>`'.
    > *   **Our Vulnerability:** Our configuration file (`openclaw.json`) at path `<jq path>` relies on an implicit default that may change.
    > *   **Predicted Failure:** `<Description of the failure mode>`."

## Phase 3: Proactive Mitigation & Verification

1.  **Propose Configuration Hardening:** For each high-risk scenario, propose specific, proactive changes to `openclaw.json`. The goal is to make the configuration more resilient by making implicit assumptions explicit. Do not execute these changes without operator approval.
2.  **Define a Verification Plan:** For each identified risk, define a clear, simple test to be run immediately post-upgrade to confirm the system is behaving as expected.
    *   *Example:* "After the upgrade, we must immediately send a message in a `group` chat, wait one hour, and then verify the session file's `updatedAt` timestamp has not been reset."
3.  **Post-Upgrade Audit:** After the operator confirms the upgrade is complete, execute the verification plan and report the results.
