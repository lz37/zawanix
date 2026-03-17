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

  xdg.configFile = {
    "opencode/oh-my-opencode.json".source = ./oh-my-opencode.json;
    "opencode/AGENTS.md".source = ./AGENTS.md;
    "opencode/smart-title.jsonc".source = ./smart-title.jsonc;
    "opencode/octto.json".source = ./octto.json;
    "opencode/micode.jsonc".source = ./micode.jsonc;
    "opencode/dcp.jsonc".source = ./dcp.jsonc;
  };

  home.packages = [
    opencode-desktop
  ];
}
