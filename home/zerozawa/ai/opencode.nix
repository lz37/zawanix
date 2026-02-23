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
  xdg.configFile = {
    "opencode/oh-my-opencode.json".source = ./oh-my-opencode.json;
    "opencode/skills".source = ./skills;
  };
  home.packages = [
    # desktop
  ];
}
