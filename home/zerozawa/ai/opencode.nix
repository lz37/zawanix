{
  pkgs,
  lib,
  inputs,
  config,
  ...
}: let
  opencode-skills = pkgs.stdenvNoCC.mkDerivation {
    name = "opencode-skills";
    src = null;
    dontUnpack = true;
    dontBuild = true;
    installPhase = ''
      mkdir -p $out
      cp -r ${inputs.ast-grep-skill}/ast-grep/skills/* $out/
      cp -r ${inputs.anthropics-skills}/skills/frontend-design $out/
      cp -r ${inputs.anthropics-skills}/skills/pdf $out/
      cp -r ${inputs.ai-agent-skills}/skills/best-practices $out/
      cp -r ${inputs.openai-skills}/skills/.curated/gh-address-comments $out/
      cp -r ${inputs.awesome-copilot}/skills/gh-cli $out/
      cp -r ${inputs.awesome-copilot}/skills/mcp-cli $out/
    '';
  };
in
  with pkgs; {
    programs.opencode = {
      enable = true;
      package = opencode;
      enableMcpIntegration = true;
      settings = lib.removeAttrs (lib.importJSON ./opencode.json) ["$schema"];
    };
    xdg.configFile = {
      "opencode/oh-my-openagent.jsonc".source = ./oh-my-openagent.jsonc;
      "opencode/smart-title.jsonc".source = ./smart-title.jsonc;
      "opencode/octto.json".source = ./octto.json;
      "opencode/micode.jsonc".source = ./micode.jsonc;
      "opencode/dcp.jsonc".source = ./dcp.jsonc;
      "opencode/skills".source = opencode-skills;
      "opencode/agent-memory.json".source = ./agent-memory.json;
      "opencode/worktree.jsonc".source = ./worktree.jsonc;
      "opencode/opencode-mem.jsonc".text = lib.generators.toJSON {} {
        storagePath = "${config.xdg.configHome}/opencode/opencode-mem/data";
        userEmailOverride = config.zerozawa.git.userEmail;
        userNameOverride = config.zerozawa.git.userName;
        embeddingModel = "Xenova/nomic-embed-text-v1";
        webServerEnabled = true;
        webServerPort = 4747;
        autoCaptureEnabled = true;
        autoCaptureLanguage = "auto";
        opencodeProvider = "opencode-go";
        opencodeModel = "minimax-m2.7";
        showAutoCaptureToasts = true;
        showUserProfileToasts = true;
        showErrorToasts = true;
        userProfileAnalysisInterval = 10;
        maxMemories = 10;
        compaction = {
          enabled = true;
          memoryLimit = true;
        };
        chatMessage = {
          enabled = true;
          maxMemories = 3;
          excludeCurrentSession = true;
          maxAgeDays = 30;
          injectOn = "first";
        };
      };
    };

    # home.packages = [
    #   opencode-desktop
    # ];
  }
