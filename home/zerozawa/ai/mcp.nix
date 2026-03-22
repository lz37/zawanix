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
      nixos = {
        command = lib.getExe stable.mcp-nixos;
      };
      github = {
        command = lib.getExe github-mcp-server;
        args = ["stdio"];
        env = {
          GITHUB_PERSONAL_ACCESS_TOKEN = config.zerozawa.github.access-token.classic;
        };
      };
      docker = {
        command = lib.getExe' pkgs.uv "uvx";
        args = ["docker-mcp"];
      };
    };
  });
  programs.mcp = {
    enable = true;
    servers = {
      grep-app = {
        url = "https://mcp.grep.app";
      };
      context7-mcp = {
        command = lib.getExe' pkgs.pnpm "pnpx";
        args = ["@upstash/context7-mcp" "--api-key" config.zerozawa.context7.apiKey];
      };
      exa-websearch = {
        command = lib.getExe' pkgs.pnpm "pnpx";
        args = ["exa-mcp-server"];
        env = {
          EXA_API_KEY = config.zerozawa.exa-mcp.apiKey;
        };
      };
      sequential-thinking = {
        command = lib.getExe' pkgs.pnpm "pnpx";
        args = ["@modelcontextprotocol/server-sequential-thinking"];
      };
      chrome-devtools = {
        command = lib.getExe' pkgs.pnpm "pnpx";
        args = [
          "chrome-devtools-mcp@latest"
          "--browser-url=http://127.0.0.1:9222"
          "--no-usage-statistics"
        ];
      };
      agentic-contract = {
        command = lib.getExe pkgs.nur.repos.zerozawa.agentic-contract.mcp;
        args = ["serve"];
      };
    };
  };
}
