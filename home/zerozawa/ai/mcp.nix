{
  lib,
  pkgs,
  config,
  ...
}:
with pkgs; let
  servers = {
    chrome-devtools = {
      command = lib.getExe' pnpm "pnpx";
      args = [
        "chrome-devtools-mcp@latest"
        "--browser-url=http://127.0.0.1:9222"
        "--no-usage-statistics"
      ];
    };
    vscode = {
      command = lib.getExe' pnpm "pnpx";
      args = ["@vscode-mcp/vscode-mcp-server@latest"];
    };
    nixos = {
      command = lib.getExe mcp-nixos;
      args = [];
    };
    github = {
      command = lib.getExe github-mcp-server;
      args = ["stdio"];
      env = {
        GITHUB_PERSONAL_ACCESS_TOKEN = config.zerozawa.github.access-token.classic;
      };
    };
    docker = {
      command = lib.getExe' uv "uvx";
      args = ["docker-mcp"];
    };
    grep = {
      url = "https://mcp.grep.app";
    };
    context7 = {
      command = lib.getExe' pnpm "pnpx";
      args = [
        "@upstash/context7-mcp"
        "--api-key"
        config.zerozawa.context7.apiKey
      ];
    };
    exa = {
      command = lib.getExe' pnpm "pnpx";
      args = ["exa-mcp-server"];
      env = {
        EXA_API_KEY = config.zerozawa.exa-mcp.apiKey;
      };
    };
    tavily = {
      command = lib.getExe' pnpm "pnpx";
      args = ["tavily-mcp@latest"];
      env = {
        TAVILY_API_KEY = config.zerozawa.tavily-mcp.apiKey;
      };
    };
    brave = {
      command = lib.getExe' pnpm "pnpx";
      args = [
        "@brave/brave-search-mcp-server"
        "--transport"
        "stdio"
      ];
      env = {
        BRAVE_API_KEY = config.zerozawa.brave-mcp.apiKey;
      };
    };
    zhihu-search = {
      command = lib.getExe' pnpm "pnpx";
      args = [
        "supergateway"
        "--sse"
        "https://developer.zhihu.com/api/mcp/zhihu_search/v1/sse"
        "--oauth2Bearer"
        config.zerozawa.zhihu-mcp.apiKey
      ];
    };
    zhihu-search-global = {
      command = lib.getExe' pnpm "pnpx";
      args = [
        "supergateway"
        "--sse"
        "https://developer.zhihu.com/api/mcp/global_search/v1/sse"
        "--oauth2Bearer"
        config.zerozawa.zhihu-mcp.apiKey
      ];
    };
    recomment = {
      command = lib.getExe nodejs-slim;
      args = [
        "${vscode-selected-extensionsCompatible.vscode-marketplace.vkhey.recomment-pro}/share/vscode/extensions/vkhey.recomment-pro/out/mcpServer.js"
      ];
    };
    hyprland = {
      command = lib.getExe nur.repos.zerozawa.hyprland-mcp-server;
    };
    image-tiler = {
      command = lib.getExe' pnpm "pnpx";
      args = ["image-tiler-mcp-server"];
    };
    pctx = {
      command = lib.getExe nur.repos.zerozawa.pctx;
      args = ["--config" (toString ((pkgs.formats.json {}).generate "pctx.json" ((import ./pctx.nix) {inherit pkgs config;}))) "mcp" "start" "--stdio"];
    };
    sequential-thinking = {
      command = lib.getExe docker;
      args = ["run" "--rm" "-i" "mcp/sequentialthinking"];
    };
    agentic-contract = {
      command = lib.getExe nur.repos.zerozawa.agentic-contract.mcp;
      args = ["serve"];
    };
    context-mode = {
      command = lib.getExe nur.repos.zerozawa.context-mode;
    };
    codegraph = {
      command = lib.getExe nur.repos.zerozawa.codegraph;
      args = ["serve" "--mcp"];
    };
  };
in {
  programs.mcp = {
    enable = true;
    inherit servers;
  };
  xdg.configFile = {
    "mcp/omp.config".text = lib.generators.toJSON {} {
      disabledServers = [
        "agentic-contract" # 没啥用
        "context-mode" # 没啥用
        "pctx" # omp 已有 xd:// 动态发现和eval调用
      ];
      mcpServers = servers;
    };
  };
}
