{
  pkgs,
  lib,
  ...
}: let
  agentsys = pkgs.nur.repos.zerozawa.agentsys.override {
    frontmattersOverride = {};
  };
in
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
      "opencode/agents".source = "${agentsys}/share/opencode/agents";
      "opencode/skills".source = "${agentsys}/share/opencode/skills";
      "opencode/plugins".source = "${agentsys}/share/opencode/plugins";
      "opencode/commands".source = "${agentsys}/share/opencode/commands";
      "opencode/octto.json".source = ./octto.json;
    };

    home.packages = [
      opencode-desktop
      agentsys
    ];
  }
