# Learnings — per-agent-personality

## [2026-02-23] Session Init

### Skills 加载机制
- SKILL.md 是最高优先级；顺序为 skill → prompt_append → 用户消息
- 目录映射：opencode.nix 通过 xdg.configFile 将 ./skills 映射到 ~/.config/opencode/skills，新建子目录会被自动识别
- 需要 nixos-rebuild switch 部署才能生效

### anime-personality/SKILL.md 现状
- 当前已是强化版（含强制性格规则、few-shot 示例、动态语言适配）
- 目前 personality_type: tsundere-anime — 含傲娇专属内容
- Task 1 目标：重写为通用基础层（personality_type: base-layer，≤60行）
- 合成策略：取旧版(backup)的颜文字通用规则结构 + 取新版的强制执行机制骨架，移除所有傲娇专属内容

### 9 个 Agent 人设映射（已确认）
| Agent | Skill | 自称 | 对用户称呼 |
|-------|-------|------|-----------|
| sisyphus | anime-tsundere | 本小姐/吾辈 | 你/笨蛋 |
| oracle | anime-kuudere | 吾/我 | 你（极简）|
| librarian | anime-gentle | 我/人家 | 主人/您 |
| explore | anime-gyaru | 人家/我 | 你 |
| prometheus | anime-mentor | 本座/吾辈/姐姐我 | 小朋友/你 |
| metis | anime-empath | 妾身/我 | 你/亲爱的 |
| hephaestus | anime-craftsman | 在下/僕 | 您/阁下 |
| momus | anime-critic | 人家/本小姐 | 大哥哥 |
| atlas | anime-imouto | 妹妹我/我 | 欧尼酱/哥哥 |

## [2026-02-23] Task 1 Complete: Base-layer Rewrite

### Strategy Used
- **Synthesis approach**: Combined backup version's kaomoji structure (lines 103-106) with current version's enforcement mechanism format (## ⚡ 强制性格规则, priority declaration)
- **Tsundere removal**: Eliminated all character-exclusive patterns (本小姐, this lady, あたし, 啧/哼 openings, 既然你这么诚恳地求, 怎么样很厉害吧, sentence templates table, all few-shot examples)
- **Universal preservation**: Kept forbidden zones, 90/10 balance, kaomoji requirement, tech excellence, language adaptation principles

### Structure (44 lines total)
```
Frontmatter (8 lines) + personality_type: base-layer
通用强制规则 (17 lines) = priority + must-do (4) + must-not (4)
动态语言适配 (3 lines)
性格平衡 (5 lines)
技术卓越 (6 lines)
```

### Key Changes from 176→44 lines
- Removed: 83 lines of sentence templates table + language-specific anchors
- Removed: 28 lines of few-shot examples (4 scenarios × 7 lines each)
- Removed: All self-referential content (本小姐 patterns)
- Kept: All generic enforcement mechanisms that all 9 agents will use

### Validation
- Line count: 44 ≤ 60 ✓
- personality_type: base-layer ✓
- Zero tsundere markers ✓
- All required sections present ✓
- Evidence file: task-1-base-layer-check.txt ✓

## [2026-02-23] Task 1 Rewrite Complete (Session 2)
- anime-personality/SKILL.md 重写完成，行数: 33
- personality_type: base-layer ✓
- 无傲娇专属内容 ✓
## [2026-02-23] Task: anime-kuudere/SKILL.md created, 73 lines

## [2026-02-23] Task 2 Done: anime-tsundere/SKILL.md created, 64 lines
## [2026-02-23] Task 4 Done: anime-gentle/SKILL.md created, 75 lines

## [2026-02-23] Task 7 Done: anime-empath/SKILL.md created, 85 lines
## [2026-02-23] Task 8 Done: anime-craftsman/SKILL.md created, 120 lines
## [2026-02-23] Task 9 Done: anime-critic/SKILL.md created, 112 lines
## [2026-02-23] Task 10 Done: anime-imouto/SKILL.md created, 121 lines
