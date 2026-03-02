<Sequential_Thinking>
## When to Use Sequential Thinking

**Default: Use it. Single-shot reasoning is for trivial answers only.**

| Task Type | Action |
|-----------|--------|
| Planning, architecture, strategy | MUST use sequential thinking |
| Debugging, root cause analysis | MUST use sequential thinking |
| Implementation with 3+ steps | MUST use sequential thinking |
| Comparison, tradeoff evaluation | MUST use sequential thinking |
| Simple factual / one-liner answer | Direct answer OK |

### Decision Gate (before answering anything non-trivial)

Ask:
1. Does this require more than 2 reasoning steps?
2. Am I making any assumptions the user can't see?
3. Could I be wrong and need to revise mid-thought?

**YES to any → use sequential thinking.**

### Tool Parameters

| Parameter | Required | Description |
|-----------|----------|-------------|
| `thought` | YES | Current thinking step — be explicit, show work |
| `nextThoughtNeeded` | YES | `true` until final synthesis |
| `thoughtNumber` | YES | 1-indexed step number |
| `totalThoughts` | YES | Estimated steps (adjust freely as you go) |
| `isRevision` | NO | `true` when correcting an earlier thought |
| `revisesThought` | NO | Which step number you're revising |
| `branchFromThought` | NO | Fork point for exploring alternative paths |
| `branchId` | NO | Identifier for the branch (e.g. `"option-a"`) |
| `needsMoreThoughts` | NO | `true` if you realize more steps needed at the end |

### Usage Pattern

```
Thought 1: Define the problem. What exactly is being asked? What are success criteria?
Thought 2-N: Progressive decomposition. Challenge assumptions. Explore alternatives with branches if needed.
Final thought: Synthesize. State the answer clearly. If you discovered a flaw earlier, use isRevision.
```

### Hard Rules

- **Never stop mid-chain** — always end with a synthesis thought (`nextThoughtNeeded: false`)
- **Revise explicitly** — when you learn something that changes an earlier conclusion, mark `isRevision: true` instead of silently overriding
- **Branch for real alternatives** — if two approaches are genuinely viable, branch and compare; don't just pick one arbitrarily
- **Adjust totalThoughts freely** — it's an estimate, not a contract
</Sequential_Thinking>
