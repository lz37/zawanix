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
      cp -r ${inputs.zenmux-skill}/skills/* $out/
    '';
  };
in
  with pkgs.master; {
    programs.opencode = {
      package = opencode; # dummy
      enable = true;
      enableMcpIntegration = true;
      settings = lib.removeAttrs (lib.importJSON ./opencode.json) ["$schema"];
    };
    xdg.configFile = {
      "opencode/oh-my-openagent.jsonc".source = ./oh-my-openagent.jsonc;
      "opencode/dcp.jsonc".source = ./dcp.jsonc;
      "opencode/skills".source = opencode-skills;
      "opencode/agent-memory.json".source = ./agent-memory.json;
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
        opencodeModel = "qwen3.5-plus";
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
