{pkgs, ...}:
with pkgs.opencode-dev-pkgs; let
  # 读取基础配置
  baseConfig = builtins.fromJSON (builtins.readFile ./oh-my-opencode.json);

  # 读取 base personality
  baseContent = builtins.readFile ./personalities/_base.md;

  # 合并 personality 的辅助函数
  mkPersonality = name: baseContent + "\n\n" + (builtins.readFile ./personalities/${name}.md);

  # 生成最终配置：为每个有 personality 文件的 agent 添加 prompt_append
  finalConfig =
    baseConfig
    // {
      agents =
        builtins.mapAttrs (
          name: agentConfig:
            if builtins.pathExists ./personalities/${name}.md
            then agentConfig // {prompt_append = mkPersonality name;}
            else agentConfig
        )
        baseConfig.agents;
    };

  # 使用 pkgs.formats.json 生成带缩进的漂亮 JSON
  jsonFormat = pkgs.formats.json {};
in {
  programs.opencode = {
    enable = true;
    enableMcpIntegration = true;
    package = opencode;
    settings = {
      plugin = [
        "oh-my-opencode"
        "@simonwjackson/opencode-direnv"
        "opencode-wakatime"
        "opencode-agent-memory"
        "opencode-mem"
      ];
    };
  };

  # 生成最终的 oh-my-opencode.json（包含合并后的 prompt_append）
  xdg.configFile."opencode/oh-my-opencode.json".source =
    jsonFormat.generate "oh-my-opencode.json" finalConfig;

  home.packages = [
    # desktop
  ];
}
