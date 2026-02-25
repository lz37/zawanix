{pkgs, ...}:
with pkgs.opencode-dev-pkgs; {
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
  xdg.configFile = {
    "opencode/oh-my-opencode.json".source = ./oh-my-opencode.json;
  };

  home.packages = [
    # desktop
  ];
}
