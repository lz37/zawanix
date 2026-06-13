{
  lib,
  pkgs,
  config,
  ...
}: {
  home.packages = [
    pkgs.nur.repos.zerozawa.mcp-cli
  ];
  xdg.configFile."mcp/mcp_servers.json".text = lib.generators.toJSON {} (with pkgs; {
    mcpServers = {
      github = {
        command = lib.getExe github-mcp-server;
        args = ["stdio"];
        env = {
          GITHUB_PERSONAL_ACCESS_TOKEN = config.zerozawa.github.access-token.classic;
        };
      };
    };
  });
  programs.mcp = with pkgs; {
    enable = true;
    servers = {
      docker = {
        command = lib.getExe' pkgs.uv "uvx";
        args = ["docker-mcp"];
      };
      grep-app = {
        url = "https://mcp.grep.app";
      };
      nixos = {
        command = lib.getExe mcp-nixos;
      };
      context7-mcp = {
        command = lib.getExe' pnpm "pnpx";
        args = ["@upstash/context7-mcp" "--api-key" config.zerozawa.context7.apiKey];
      };
      exa-websearch = {
        command = lib.getExe' pnpm "pnpx";
        args = ["exa-mcp-server"];
        env = {
          EXA_API_KEY = config.zerozawa.exa-mcp.apiKey;
        };
      };
      sequential-thinking = {
        command = lib.getExe docker;
        args = ["run" "--rm" "-i" "mcp/sequentialthinking"];
      };
      chrome-devtools = {
        command = lib.getExe' pnpm "pnpx";
        args = [
          "chrome-devtools-mcp@latest"
          "--browser-url=http://127.0.0.1:9222"
          "--no-usage-statistics"
        ];
      };
      agentic-contract = {
        command = lib.getExe nur.repos.zerozawa.agentic-contract.mcp;
        args = ["serve"];
      };
      hyprland-mcp-server = {
        command = lib.getExe nur.repos.zerozawa.hyprland-mcp-server;
      };
      image-tiler-mcp-server = {
        command = lib.getExe' pnpm "pnpx";
        args = ["image-tiler-mcp-server"];
      };
      recomment = {
        command = lib.getExe nodejs-slim;
        args = ["${vscode-selected-extensionsCompatible.vscode-marketplace.vkhey.recomment-pro}/share/vscode/extensions/vkhey.recomment-pro/out/mcpServer.js"];
      };
      vscode-mcp = {
        command = lib.getExe' pnpm "pnpx";
        args = ["@vscode-mcp/vscode-mcp-server@latest"];
      };
      context-mode = {
        command = lib.getExe nur.repos.zerozawa.context-mode;
      };
    };
  };
}
