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
      merge_skills() {
        local src="$1"
        for item in "$src"/*; do
          local name
          name=$(basename "$item")
          # Skip first-level directory if it already exists (no merging)
          if [ -d "$item" ] && [ -e "$out/$name" ]; then
            echo "Skipping already existing directory: $name"
            continue
          fi
          # --no-preserve=mode prevents Permission denied when nested
          # directories in the Nix store are read-only.
          cp -r --no-preserve=mode -n "$item" "$out/"
        done
        # Ensure everything stays writable for subsequent merges
        chmod -R u+w "$out"
      }
      merge_skills "${inputs.ast-grep-skill}/ast-grep/skills"
      merge_skills "${inputs.anthropics-skills}/skills"
      merge_skills "${inputs.ai-agent-skills}/skills"
      merge_skills "${inputs.openai-skills}/skills/.curated"
      merge_skills "${inputs.awesome-copilot}/skills"
      merge_skills "${inputs.zenmux-skill}/skills"
    '';
  };
in {
  programs.opencode = {
    package = pkgs.opencode;
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
  #   pkgs.opencode-desktop
  # ];
}
