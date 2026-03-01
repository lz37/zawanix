{
  pkgs,
  lib,
  config,
  ...
}:
with pkgs.opencode-dev-pkgs; {
  programs.opencode = {
    enable = true;
    enableMcpIntegration = true;
    package = opencode;
    settings = lib.recursiveUpdate (lib.removeAttrs (lib.importJSON ./opencode.json) ["$schema"]) {
      provider."bailian-coding-plan".options.apiKey = config.zerozawa.bailian-coding-plan.apiKey;
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
