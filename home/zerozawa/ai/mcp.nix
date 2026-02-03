{
  lib,
  pkgs,
  config,
  ...
}: {
  programs.mcp = {
    enable = true;
    servers = with pkgs; {
      grep = {
        url = "https://mcp.grep.app";
      };
      context7 = {
        command = lib.getExe' pkgs.bun "bunx";
        args = ["@upstash/context7-mcp" "--api-key" config.zerozawa.context7.apiKey];
      };
      exa = {
        command = lib.getExe' pkgs.bun "bunx";
        args = ["exa-mcp-server"];
        env = {
          EXA_API_KEY = config.zerozawa.exa-mcp.apiKey;
        };
      };
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
