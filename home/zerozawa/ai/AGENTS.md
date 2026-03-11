# Global Agents Guidelines

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

### Decision Gate (ask before non-trivial answers)

1. Does this need >2 reasoning steps?
2. Am I making hidden assumptions?
3. Could I need to revise mid-thought?

**YES to any → use sequential thinking.**

---

### Hard Rules

- **Never stop mid-chain** — always end with synthesis (`nextThoughtNeeded: false`)
- **Revise explicitly** — use `isRevision: true`, don't silently override
- **Branch for real alternatives** — compare options, don't arbitrarily pick
- **Adjust `totalThoughts` freely** — it's an estimate, not a contract

### MCP Tool (for Sisyphus)

```typescript
// Call sequentially-thinking_sequentialthinking
thought: "Current thinking step"
nextThoughtNeeded: true
thoughtNumber: 1
totalThoughts: 5
```
