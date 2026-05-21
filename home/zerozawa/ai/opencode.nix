{
  pkgs,
  lib,
  config,
  ...
}: {
  programs.opencode = {
    package = pkgs.opencode;
    enable = true;
    enableMcpIntegration = true;
    settings = lib.removeAttrs (lib.importJSON ./opencode.json) ["$schema"];
  };
  xdg.configFile = {
    "opencode/oh-my-openagent.jsonc".source = ./oh-my-openagent.jsonc;
    "opencode/dcp.jsonc".source = ./dcp.jsonc;
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
  #   pkgs.opencode-desktop
  # ];
}
