{
  pkgs,
  lib,
  ...
}:
with pkgs.master; {
  programs.opencode = {
    enable = true;
    enableMcpIntegration = true;
    package = opencode;
    settings = lib.removeAttrs (lib.importJSON ./opencode.json) ["$schema"];
  };

  # 生成最终的 oh-my-opencode.json (带 prompt_append)
  xdg.configFile = {
    "opencode/oh-my-opencode.json".source = ./oh-my-opencode.json;
    "opencode/AGENTS.md".source = ./AGENTS.md;
    "opencode/smart-title.jsonc".source = ./smart-title.jsonc;
  };

  home.packages = [
    opencode-desktop
  ];
}
