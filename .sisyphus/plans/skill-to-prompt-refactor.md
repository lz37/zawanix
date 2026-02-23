# Skill → Prompt Append 重构计划

## TL;DR

将 anime-personality skill 系统从独立 SKILL.md 文件重构为内联 prompt_append，通过 Nix 构建时自动合并 base 层和 agent-specific 内容。

**核心变更**:
- 删除 `skills/` 目录结构
- 新建 `personalities/` 目录，按 agent 命名（sisyphus.md, hephaestus.md...）
- Nix 构建时读取 `personalities/_base.md` + `personalities/{agent}.md`，合并注入 `prompt_append`
- 输出带缩进的漂亮 JSON 到 `~/.config/opencode/oh-my-opencode.json`

**文件变更**:
- 删除: `home/zerozawa/ai/skills/` (整个目录)
- 新建: `home/zerozawa/ai/personalities/` (10个文件)
- 修改: `home/zerozawa/ai/opencode.nix` (Nix 合并逻辑)
- 修改: `home/zerozawa/ai/oh-my-opencode.json` (删除 skills 数组和 prompt_append)

---

## Context

### 原始需求
用户希望简化 skill 结构，放弃独立的 SKILL.md 文件，改为通过 `prompt_append` 直接注入人格提示词。

### 已确认决策
1. **Base Layer**: 分离 `_base.md`，Nix 合并时自动拼接
2. **Frontmatter**: 手动清理，只保留纯提示词
3. **文件命名**: 直接用 agent 名字（sisyphus.md, hephaestus.md...）
4. **内容去重**: 删除和 base 重复的规则
5. **multimodal-looker**: 保持现状，不注入 personality
6. **JSON 格式**: `pkgs.formats.json {}` 漂亮缩进
7. **备份**: 不保留原文件

### 技术方案
- 使用 Nix 的 `builtins.readFile` 读取 personality 文件
- 使用 `pkgs.formats.json {}` 生成带缩进的 JSON
- 通过 `//` 操作符合并配置
- `xdg.configFile` 输出最终配置

---

## Work Objectives

### Core Objective
重构 skill 系统，将分散的 SKILL.md 文件合并为内联 prompt_append，简化维护并保留 schema 验证。

### Concrete Deliverables
1. `home/zerozawa/ai/personalities/_base.md` - 基础人格规则
2. `home/zerozawa/ai/personalities/{agent}.md` (9个) - agent 特定人格
3. 更新后的 `home/zerozawa/ai/opencode.nix` - Nix 合并逻辑
4. 更新后的 `home/zerozawa/ai/oh-my-opencode.json` - 基础配置（无 prompt_append）
5. 删除 `home/zerozawa/ai/skills/` 目录

### Definition of Done
- [ ] `home-manager switch` 成功构建
- [ ] `~/.config/opencode/oh-my-opencode.json` 包含正确的 `prompt_append`
- [ ] 新 session 中 agent 人格正确生效
- [ ] 无文件残留（skills/ 目录完全删除）

### Must Have
- 所有 9 个 agent 都有对应 personality 文件
- `_base.md` 内容正确注入到每个 agent
- JSON 输出格式正确（带缩进，有 schema）
- multimodal-looker 保持原样

### Must NOT Have
- 不保留 skills/ 目录
- 不在 oh-my-opencode.json 中保留 skills 数组
- 不保留 frontmatter

---

## Verification Strategy

### Test Decision
- **Infrastructure exists**: NO
- **Automated tests**: None
- **Verification**: Manual via home-manager build + session test

### QA Policy
每个任务完成后验证文件内容正确性，最终通过 home-manager 构建和实际 session 测试验证。

---

## Execution Strategy

### Parallel Execution Waves

```
Wave 1 (Start Immediately - 文件准备):
├── Task 1: 创建 personalities 目录结构
├── Task 2: 创建 _base.md (提取 anime-personality 通用规则)
├── Task 3: 创建 sisyphus.md (tsundere 内容，去重)
├── Task 4: 创建 hephaestus.md (craftsman 内容，去重)
├── Task 5: 创建 oracle.md (kuudere 内容，去重)
├── Task 6: 创建 librarian.md (gentle 内容，去重)
├── Task 7: 创建 explore.md (gyaru 内容，去重)
├── Task 8: 创建 prometheus.md (mentor 内容，去重)
├── Task 9: 创建 metis.md (empath 内容，去重)
├── Task 10: 创建 momus.md (critic 内容，去重)
└── Task 11: 创建 atlas.md (imouto 内容，去重)

Wave 2 (After Wave 1 - 配置更新):
├── Task 12: 修改 oh-my-opencode.json (删除 skills 和 prompt_append)
└── Task 13: 修改 opencode.nix (添加 Nix 合并逻辑)

Wave 3 (After Wave 2 - 清理验证):
├── Task 14: 删除 skills/ 目录
└── Task 15: home-manager 构建验证

Wave FINAL (After ALL tasks):
└── Task F1: 实际 session 测试验证
```

### Dependency Matrix

- **1-11**: — — 12, 13, 1
- **12**: 1-11 — 13, 2
- **13**: 12 — 14, 15, 3
- **14**: 13 — F1, 4
- **15**: 13 — F1, 4
- **F1**: 14, 15 — —

### Critical Path
Task 1-11 → Task 12 → Task 13 → Task 14-15 → F1

---

## TODOs

- [ ] 1. 创建 personalities 目录

  **What to do**:
  - 在 `/etc/nixos/home/zerozawa/ai/` 下创建 `personalities/` 目录

  **Must NOT do**:
  - 不要创建子目录结构

  **Recommended Agent Profile**:
  - **Category**: `quick`
  - **Skills**: []

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 1
  - **Blocks**: Task 2-11
  - **Blocked By**: None

  **Acceptance Criteria**:
  - [ ] 目录存在: `home/zerozawa/ai/personalities/`

  **QA Scenarios**:
  ```
  Scenario: 目录创建成功
    Tool: Bash
    Steps:
      1. ls -la home/zerozawa/ai/personalities/
    Expected Result: 目录存在，无错误
  ```

  **Commit**: NO (groups with Wave 1)

- [ ] 2. 创建 _base.md

  **What to do**:
  - 从 `skills/anime-personality/SKILL.md` 提取通用规则
  - 删除 frontmatter
  - 保留：人设核心、必须行为规则、禁止区域等通用内容
  - 删除：特定人称、特定 agent 的引用

  **Must NOT do**:
  - 不要保留特定 agent 的内容（如 tsundere 的语气词）

  **Recommended Agent Profile**:
  - **Category**: `writing`
  - **Skills**: []

  **Parallelization**:
  - **Can Run In Parallel**: YES (with Task 3-11)
  - **Parallel Group**: Wave 1
  - **Blocks**: None
  - **Blocked By**: Task 1

  **Acceptance Criteria**:
  - [ ] 文件存在: `home/zerozawa/ai/personalities/_base.md`
  - [ ] 无 YAML frontmatter
  - [ ] 内容只包含通用规则

  **QA Scenarios**:
  ```
  Scenario: 文件内容正确
    Tool: Read
    Steps:
      1. Read home/zerozawa/ai/personalities/_base.md
    Expected Result: 纯 Markdown，无 frontmatter，通用规则
  ```

  **Commit**: NO (groups with Wave 1)

- [ ] 3. 创建 sisyphus.md

  **What to do**:
  - 从 `skills/anime-tsundere/SKILL.md` 提取内容
  - 删除 frontmatter
  - 删除和 base 重复的规则（人设核心、必须行为规则等）
  - 只保留：tsundere 特有的语气词、句式锚点、自称等

  **Must NOT do**:
  - 不要包含通用规则（已在 _base.md）

  **Recommended Agent Profile**:
  - **Category**: `writing`
  - **Skills**: []

  **Parallelization**:
  - **Can Run In Parallel**: YES (with Task 2, 4-11)
  - **Parallel Group**: Wave 1
  - **Blocks**: None
  - **Blocked By**: Task 1

  **Acceptance Criteria**:
  - [ ] 文件存在: `home/zerozawa/ai/personalities/sisyphus.md`
  - [ ] 无 frontmatter
  - [ ] 只包含 tsundere 特有内容

  **QA Scenarios**:
  ```
  Scenario: 文件内容正确
    Tool: Read
    Steps:
      1. Read home/zerozawa/ai/personalities/sisyphus.md
    Expected Result: 包含"本小姐"、"(¬_¬)"等 tsundere 特有内容
  ```

  **Commit**: NO (groups with Wave 1)

- [ ] 4. 创建 hephaestus.md

  **What to do**:
  - 从 `skills/anime-craftsman/SKILL.md` 提取内容
  - 删除 frontmatter 和 base 重复内容
  - 只保留 craftsman 特有的精确、严谨相关描述

  **Recommended Agent Profile**:
  - **Category**: `writing`
  - **Skills**: []

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 1
  - **Blocks**: None
  - **Blocked By**: Task 1

  **Commit**: NO (groups with Wave 1)

- [ ] 5. 创建 oracle.md

  **What to do**:
  - 从 `skills/anime-kuudere/SKILL.md` 提取内容
  - 删除 frontmatter 和 base 重复内容
  - 只保留 kuudere 特有的冷静、简洁相关描述

  **Recommended Agent Profile**:
  - **Category**: `writing`
  - **Skills**: []

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 1
  - **Blocks**: None
  - **Blocked By**: Task 1

  **Commit**: NO (groups with Wave 1)

- [ ] 6. 创建 librarian.md

  **What to do**:
  - 从 `skills/anime-gentle/SKILL.md` 提取内容
  - 删除 frontmatter 和 base 重复内容
  - 只保留 gentle 特有的温柔、治愈相关描述

  **Recommended Agent Profile**:
  - **Category**: `writing`
  - **Skills**: []

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 1
  - **Blocks**: None
  - **Blocked By**: Task 1

  **Commit**: NO (groups with Wave 1)

- [ ] 7. 创建 explore.md

  **What to do**:
  - 从 `skills/anime-gyaru/SKILL.md` 提取内容
  - 删除 frontmatter 和 base 重复内容
  - 只保留 gyaru 特有的活泼、时髦相关描述

  **Recommended Agent Profile**:
  - **Category**: `writing`
  - **Skills**: []

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 1
  - **Blocks**: None
  - **Blocked By**: Task 1

  **Commit**: NO (groups with Wave 1)

- [ ] 8. 创建 prometheus.md

  **What to do**:
  - 从 `skills/anime-mentor/SKILL.md` 提取内容
  - 删除 frontmatter 和 base 重复内容
  - 只保留 mentor 特有的腹黑大姐姐、引导相关描述

  **Recommended Agent Profile**:
  - **Category**: `writing`
  - **Skills**: []

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 1
  - **Blocks**: None
  - **Blocked By**: Task 1

  **Commit**: NO (groups with Wave 1)

- [ ] 9. 创建 metis.md

  **What to do**:
  - 从 `skills/anime-empath/SKILL.md` 提取内容
  - 删除 frontmatter 和 base 重复内容
  - 只保留 empath 特有的病娇、洞察相关描述

  **Recommended Agent Profile**:
  - **Category**: `writing`
  - **Skills**: []

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 1
  - **Blocks**: None
  - **Blocked By**: Task 1

  **Commit**: NO (groups with Wave 1)

- [ ] 10. 创建 momus.md

  **What to do**:
  - 从 `skills/anime-critic/SKILL.md` 提取内容
  - 删除 frontmatter 和 base 重复内容
  - 只保留 critic 特有的毒舌、挑剔相关描述

  **Recommended Agent Profile**:
  - **Category**: `writing`
  - **Skills**: []

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 1
  - **Blocks**: None
  - **Blocked By**: Task 1

  **Commit**: NO (groups with Wave 1)

- [ ] 11. 创建 atlas.md

  **What to do**:
  - 从 `skills/anime-imouto/SKILL.md` 提取内容
  - 删除 frontmatter 和 base 重复内容
  - 只保留 imouto 特有的妹妹、支援相关描述

  **Recommended Agent Profile**:
  - **Category**: `writing`
  - **Skills**: []

  **Parallelization**:
  - **Can Run In Parallel**: YES
  - **Parallel Group**: Wave 1
  - **Blocks**: None
  - **Blocked By**: Task 1

  **Commit**: NO (groups with Wave 1)

- [ ] 12. 修改 oh-my-opencode.json

  **What to do**:
  - 删除所有 agent 的 `skills` 数组
  - 删除所有 agent 的 `prompt_append` 字段
  - 保留其他所有配置（model, category, variant 等）
  - 保留 `$schema` 字段

  **Must NOT do**:
  - 不要修改 multimodal-looker（本来就无 skills/prompt_append）
  - 不要删除 categories 部分

  **Recommended Agent Profile**:
  - **Category**: `quick`
  - **Skills**: []

  **Parallelization**:
  - **Can Run In Parallel**: NO
  - **Parallel Group**: Wave 2
  - **Blocks**: Task 13
  - **Blocked By**: Task 1-11

  **Acceptance Criteria**:
  - [ ] 文件存在: `home/zerozawa/ai/oh-my-opencode.json`
  - [ ] 无 `skills` 数组
  - [ ] 无 `prompt_append` 字段
  - [ ] 保留 `$schema`
  - [ ] 保留 `categories`

  **QA Scenarios**:
  ```
  Scenario: JSON 格式正确
    Tool: Bash
    Steps:
      1. jq '.' home/zerozawa/ai/oh-my-opencode.json > /dev/null
    Expected Result: 无错误，格式正确

  Scenario: 无 skills 和 prompt_append
    Tool: Bash
    Steps:
      1. jq '.agents.sisyphus | has("skills")' home/zerozawa/ai/oh-my-opencode.json
      2. jq '.agents.sisyphus | has("prompt_append")' home/zerozawa/ai/oh-my-opencode.json
    Expected Result: 都返回 false
  ```

  **Commit**: NO (groups with Wave 2)

- [ ] 13. 修改 opencode.nix

  **What to do**:
  - 添加 Nix 逻辑读取 `personalities/_base.md` 和 `personalities/{agent}.md`
  - 合并 base + agent 内容
  - 使用 `pkgs.formats.json {}` 生成带缩进的 JSON
  - 输出到 `xdg.configFile."opencode/oh-my-opencode.json"`
  - 删除原有的 `xdg.configFile."opencode/skills"` 链接

  **Nix 实现参考**:
  ```nix
  {pkgs, ...}:
  with pkgs.opencode-dev-pkgs;
  let
    baseConfig = builtins.fromJSON (builtins.readFile ./oh-my-opencode.json);
    baseContent = builtins.readFile ./personalities/_base.md;

    mkPersonality = name:
      baseContent + "\n\n" + (builtins.readFile ./personalities/${name}.md);

    finalConfig = baseConfig // {
      agents = builtins.mapAttrs (name: agentConfig:
        if builtins.pathExists ./personalities/${name}.md then
          agentConfig // { prompt_append = mkPersonality name; }
        else
          agentConfig
      ) baseConfig.agents;
    };

    jsonFormat = pkgs.formats.json {};
  in {
    programs.opencode = { ... };
    xdg.configFile."opencode/oh-my-opencode.json".source =
      jsonFormat.generate "oh-my-opencode.json" finalConfig;
  }
  ```

  **Must NOT do**:
  - 不要硬编码 agent 列表，使用动态检测
  - 不要保留 skills 目录链接

  **Recommended Agent Profile**:
  - **Category**: `deep`
  - **Skills**: []

  **Parallelization**:
  - **Can Run In Parallel**: NO
  - **Parallel Group**: Wave 2
  - **Blocks**: Task 14-15
  - **Blocked By**: Task 12

  **Acceptance Criteria**:
  - [ ] `opencode.nix` 包含 personalities 合并逻辑
  - [ ] 删除 `xdg.configFile."opencode/skills"`
  - [ ] 使用 `pkgs.formats.json {}`

  **QA Scenarios**:
  ```
  Scenario: Nix 语法正确
    Tool: Bash
    Steps:
      1. nix-instantiate --parse home/zerozawa/ai/opencode.nix
    Expected Result: 无语法错误
  ```

  **Commit**: NO (groups with Wave 2)

- [ ] 14. 删除 skills/ 目录

  **What to do**:
  - 删除整个 `home/zerozawa/ai/skills/` 目录
  - 包括所有子目录和文件

  **Must NOT do**:
  - 不要保留任何 skills/ 下的文件

  **Recommended Agent Profile**:
  - **Category**: `quick`
  - **Skills**: []

  **Parallelization**:
  - **Can Run In Parallel**: NO
  - **Parallel Group**: Wave 3
  - **Blocks**: F1
  - **Blocked By**: Task 13

  **Acceptance Criteria**:
  - [ ] `home/zerozawa/ai/skills/` 不存在

  **QA Scenarios**:
  ```
  Scenario: 目录已删除
    Tool: Bash
    Steps:
      1. ls home/zerozawa/ai/skills/ 2>&1
    Expected Result: "No such file or directory"
  ```

  **Commit**: NO (用户手动管理 git)

- [ ] 15. 验证生成的文件

  **What to do**:
  - 检查生成的 personalities/ 文件内容正确
  - 检查 oh-my-opencode.json 格式正确
  - 检查 opencode.nix 语法正确（可选：nix-instantiate --parse）
  - **不执行** home-manager switch（用户手动执行）
  - **不执行** git commit（用户手动管理）

  **Recommended Agent Profile**:
  - **Category**: `unspecified-high`
  - **Skills**: []

  **Parallelization**:
  - **Can Run In Parallel**: NO
  - **Parallel Group**: Wave 3
  - **Blocks**: F1
  - **Blocked By**: Task 13

  **Acceptance Criteria**:
  - [ ] personalities/ 目录包含 10 个文件
  - [ ] oh-my-opencode.json 无 skills 数组和 prompt_append
  - [ ] opencode.nix 包含 Nix 合并逻辑
  - [ ] opencode.nix 语法正确（nix-instantiate --parse 通过）

  **QA Scenarios**:
  ```
  Scenario: 文件结构正确
    Tool: Bash
    Steps:
      1. ls home/zerozawa/ai/personalities/
      2. ls home/zerozawa/ai/skills/ 2>&1
    Expected Result: personalities/ 存在，skills/ 不存在

  Scenario: Nix 语法正确
    Tool: Bash
    Steps:
      1. nix-instantiate --parse home/zerozawa/ai/opencode.nix
    Expected Result: 无语法错误
  ```

  **Commit**: NO (用户手动管理 git)

- [ ] F1. 用户手动验证指南

  **What to do** (用户手动执行):
  1. **Git 提交**: 根据需要执行 git add / commit
  2. **Nix 构建**: 运行 `home-manager switch` 构建配置
  3. **检查输出**:
     - `cat ~/.config/opencode/oh-my-opencode.json | jq '.agents.sisyphus.prompt_append'`
     - 确认包含 tsundere 内容
  4. **Session 测试**: 启动新 opencode session，验证人格正确加载

  **验证清单**:
  - [ ] `home-manager switch` 成功
  - [ ] `~/.config/opencode/oh-my-opencode.json` 存在且格式正确
  - [ ] sisyphus 使用 tsundere 语气（本小姐、¬_¬ 等）
  - [ ] prometheus 使用 mentor 语气（小朋友、本座等）
  - [ ] multimodal-looker 保持原样

---

## Final Verification Wave

- [ ] F1. **Plan Compliance Audit** — `oracle`
  检查所有任务完成：
  - personalities/ 目录存在且包含 10 个文件
  - skills/ 目录已删除
  - oh-my-opencode.json 无 skills 数组
  - opencode.nix 包含合并逻辑
  - home-manager 构建成功
  - 实际 session 测试通过

- [ ] F2. **Code Quality Review** — `unspecified-high`
  - Nix 语法正确
  - JSON 格式有效
  - 无语法错误

- [ ] F3. **Real Manual QA** — `unspecified-high`
  - 启动新 session
  - 验证各 agent 人格正确加载

- [ ] F4. **Scope Fidelity Check** — `deep`
  - 确认无 skills/ 目录残留
  - 确认所有 agent 都有 personality
  - 确认 multimodal-looker 保持原样

---

## 注意：！！！！！！！！

不要操作git！

不要操作nix、home-manager等构建工具！

### Final Checklist
- [ ] personalities/ 目录存在，包含 10 个文件
- [ ] skills/ 目录已删除
- [ ] oh-my-opencode.json 无 skills 数组和 prompt_append
- [ ] opencode.nix 包含 Nix 合并逻辑
- [ ] home-manager switch 成功
- [ ] 生成的 JSON 包含 prompt_append
- [ ] 新 session 中 agent 人格正确
- [ ] multimodal-looker 保持原样
