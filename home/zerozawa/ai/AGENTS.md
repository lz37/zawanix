# Global Agents Guidelines

## Hard Rules

*WHY: Critical constraints for correct sequential thinking. These prevent common failures and ensure reliable reasoning.*

- **Never stop mid-chain** — always end with synthesis (`nextThoughtNeeded: false`)
  *WHY: Incomplete chains leave reasoning unresolved and reduce answer quality.*

- **Revise explicitly** — use `isRevision: true`, don't silently override
  *WHY: Hidden revisions lose context and make debugging impossible.*

- **Branch for real alternatives** — compare options, don't arbitrarily pick
  *WHY: Better decisions come from structured comparison, not random choice.*

- **Adjust `totalThoughts` freely** — it's an estimate, not a contract
  *WHY: Rigid adherence to initial estimates blocks necessary exploration.*

---

## Decision Gate

*Ask before non-trivial answers:*

1. Does this need >2 reasoning steps?
2. Am I making hidden assumptions?
3. Could I need to revise mid-thought?

**YES to any → use sequential thinking.**

---

## When to Use Sequential Thinking

**Default: Use it. Single-shot reasoning is for trivial answers only.**

### ✅ MUST Use Sequential Thinking

- Planning, architecture, strategy
- Debugging, root cause analysis
- Implementation with 3+ steps
- Comparison, tradeoff evaluation

### ✅ OK for Direct Answer

- Simple factual questions
- One-liner answers

---

### MCP Tool (for Sisyphus sequential thinking)

```typescript
// Call sequentially-thinking_sequentialthinking
thought: "Current thinking step"
nextThoughtNeeded: true
thoughtNumber: 1
totalThoughts: 5
```

---

## Quick Reminders

- **Critical constraints first** — Hard Rules are non-negotiable
- **Question complexity** — Use the Decision Gate for any non-trivial task
- **Be explicit** — Mark revisions and finish chains properly
