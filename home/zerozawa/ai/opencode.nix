{...}: {
  programs.opencode = {
    enable = true;
    enableMcpIntegration = true;
    settings = {
      plugin = ["oh-my-opencode@latest" "@simonwjackson/opencode-direnv" "opencode-wakatime"];
    };
  };
  xdg.configFile = {
    "opencode/oh-my-opencode.json".source = ./oh-my-opencode.json;
  };
}
