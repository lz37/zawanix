{
  pkgs,
  lib,
  config,
  ...
}:
with pkgs.opencode-dev-pkgs; let
  # 读取 sequential thinking prompt
  sequentialPrompt = builtins.readFile ./prompts/sequential-thinking-enable.md;

  # 读取原始 oh-my-opencode.json (移除 schema)
  ohMyOrig = lib.removeAttrs (lib.importJSON ./oh-my-opencode.json) ["$schema"];

  # 为指定 agents 添加 prompt_append
  agentsWithPrompt = lib.recursiveUpdate ohMyOrig.agents {
    sisyphus.prompt_append = sequentialPrompt;
    hephaestus.prompt_append = sequentialPrompt;
    oracle.prompt_append = sequentialPrompt;
    prometheus.prompt_append = sequentialPrompt;
    metis.prompt_append = sequentialPrompt;
    momus.prompt_append = sequentialPrompt;
    atlas.prompt_append = sequentialPrompt;
  };

  # 为指定 categories 添加 prompt_append
  categoriesWithPrompt = lib.recursiveUpdate ohMyOrig.categories {
    ultrabrain.prompt_append = sequentialPrompt;
    deep.prompt_append = sequentialPrompt;
    artistry.prompt_append = sequentialPrompt;
    unspecified-high.prompt_append = sequentialPrompt;
  };

  # 重建完整配置
  ohMyModified =
    ohMyOrig
    // {
      agents = agentsWithPrompt;
      categories = categoriesWithPrompt;
    };
in {
  programs.opencode = {
    enable = true;
    enableMcpIntegration = true;
    package = (opencode.override {bun = pkgs.master.bun;}).overrideAttrs (oldAttrs: {
      # 修复 .github/TEAM_MEMBERS 缺失问题
      postPatch = ''
        ${oldAttrs.postPatch or ""}
        mkdir -p .github
        echo "# Placeholder team members file for Nix build" > .github/TEAM_MEMBERS
      '';
    });
    settings = lib.recursiveUpdate (lib.removeAttrs (lib.importJSON ./opencode.json) ["$schema"]) {
      provider."bailian-coding-plan".options.apiKey = config.zerozawa.bailian-coding-plan.apiKey;
    };
  };

  # 生成最终的 oh-my-opencode.json (带 prompt_append)
  xdg.configFile = {
    "opencode/oh-my-opencode.json".text = builtins.toJSON ohMyModified;
  };

  home.packages = [
    # desktop
  ];
}
