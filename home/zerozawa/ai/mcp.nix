{
  lib,
  pkgs,
  config,
  ...
}: {
  programs.mcp = {
    enable = true;
    servers = with pkgs; {
      nixos = {
        command = lib.getExe mcp-nixos;
      };
      playwright = {
        command = lib.getExe playwright-mcp;
        args = [
          "--isolated"
          "--browser"
          "chrome"
          "--executable-path"
          (lib.getExe ungoogled-chromium)
        ];
      };
      github = {
        command = lib.getExe github-mcp-server;
        args = ["stdio"];
        env = {
          GITHUB_PERSONAL_ACCESS_TOKEN = config.zerozawa.github.access-token.classic;
        };
      };
    };
  };
}
