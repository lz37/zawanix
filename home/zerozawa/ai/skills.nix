_: {
  # Agent Skills, replacing the apm-managed set that used to live in
  # ~/.apm (see git history). Sources are pinned by flake.lock alone.
  #
  # structure = "link" (home.file symlinks) instead of the default
  # "symlink-tree" activation: the layout stays declarative and rollback-able,
  # and it needs a static dest -- which is also why dest is set explicitly
  # rather than left at the "$HOME/.agents/skills" default.
  #
  # Both destinations are scanned by the agents that read them one level deep
  # (OMP: .agents/skills/<name>/SKILL.md), so every skill must be a direct
  # child, including ones nested upstream.
  programs.agent-skills = {
    enable = true;
    sources = {
      awesome = {
        input = "skills-awesome";
        subdir = "skills";
        filter.maxDepth = 1;
      };
      claude-code = {
        input = "skills-claude-code";
        subdir = "skills";
        filter.maxDepth = 1;
      };
      officecli = {
        input = "skills-officecli";
        subdir = "skills";
        filter.maxDepth = 1;
      };
    };
    skills = {
      enable = [
        "grill-me"
        "morph-ppt"
        "morph-ppt-3d"
        "officecli"
        "officecli-academic-paper"
        "officecli-data-dashboard"
        "officecli-docx"
        "officecli-financial-model"
        "officecli-pitch-deck"
        "officecli-pptx"
        "officecli-word-form"
        "officecli-xlsx"
      ];
      # Upstream path is nested; publish it as a flat skill dir.
      explicit.tdd-workflow = {
        from = "awesome";
        path = "workflow/engineering/tdd-workflow";
      };
    };
    targets = {
      agents = {
        dest = ".agents/skills";
        structure = "link";
      };
      claude = {
        dest = ".claude/skills";
        structure = "link";
      };
    };
  };
}
