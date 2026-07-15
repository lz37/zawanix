{
  pkgs,
  config,
}:
with pkgs; {
  name = "global";
  version = "0.1.0";
  description = "Search the catalog to find the right tool for NixOS and flake docs, multi-engine web search (Brave, Tavily, Exa, Zhihu), GitHub, Docker, VS Code, Chrome DevTools automation, Hyprland desktop control, or image tiling for LLM vision.";
  disclosure = "catalog";
  servers = [
    {
      name = "chrome-devtools";
      command = lib.getExe' pnpm "pnpx";
      args = [
        "chrome-devtools-mcp@latest"
        "--browser-url=http://127.0.0.1:9222"
        "--no-usage-statistics"
      ];
    }
    {
      name = "vscode";
      command = lib.getExe' pnpm "pnpx";
      args = ["@vscode-mcp/vscode-mcp-server@latest"];
    }
    {
      name = "nixos";
      command = lib.getExe mcp-nixos;
      args = [];
    }
    {
      name = "github";
      command = lib.getExe github-mcp-server;
      args = ["stdio"];
      env = {
        GITHUB_PERSONAL_ACCESS_TOKEN = config.zerozawa.github.access-token.classic;
      };
    }
    {
      name = "docker";
      command = lib.getExe' uv "uvx";
      args = ["docker-mcp"];
    }
    {
      name = "grep";
      url = "https://mcp.grep.app";
    }
    {
      name = "context7";
      command = lib.getExe' pnpm "pnpx";
      args = [
        "@upstash/context7-mcp"
        "--api-key"
        config.zerozawa.context7.apiKey
      ];
    }
    {
      name = "exa";
      command = lib.getExe' pnpm "pnpx";
      args = ["exa-mcp-server"];
      env = {
        EXA_API_KEY = config.zerozawa.exa-mcp.apiKey;
      };
    }
    {
      name = "tavily";
      command = lib.getExe' pnpm "pnpx";
      args = ["tavily-mcp@latest"];
      env = {
        TAVILY_API_KEY = config.zerozawa.tavily-mcp.apiKey;
      };
    }
    {
      name = "brave";
      command = lib.getExe' pnpm "pnpx";
      args = [
        "@brave/brave-search-mcp-server"
        "--transport"
        "stdio"
      ];
      env = {
        BRAVE_API_KEY = config.zerozawa.brave-mcp.apiKey;
      };
    }
    {
      name = "zhihu-search";
      command = lib.getExe' pnpm "pnpx";
      args = [
        "supergateway"
        "--sse"
        "https://developer.zhihu.com/api/mcp/zhihu_search/v1/sse"
        "--oauth2Bearer"
        config.zerozawa.zhihu-mcp.apiKey
      ];
    }
    {
      name = "zhihu-search-global";
      command = lib.getExe' pnpm "pnpx";
      args = [
        "supergateway"
        "--sse"
        "https://developer.zhihu.com/api/mcp/global_search/v1/sse"
        "--oauth2Bearer"
        config.zerozawa.zhihu-mcp.apiKey
      ];
    }
    {
      name = "recomment";
      command = lib.getExe nodejs-slim;
      args = [
        "${vscode-selected-extensionsCompatible.vscode-marketplace.vkhey.recomment-pro}/share/vscode/extensions/vkhey.recomment-pro/out/mcpServer.js"
      ];
    }
    {
      name = "hyprland";
      command = lib.getExe nur.repos.zerozawa.hyprland-mcp-server;
    }
    {
      name = "image-tiler";
      command = lib.getExe' pnpm "pnpx";
      args = ["image-tiler-mcp-server"];
    }
  ];
  logger = {
    enabled = true;
    level = "info";
    format = "compact";
    colors = true;
  };
  telemetry = {
    traces = {
      enabled = false;
      sampling = {
        strategy = "always";
        rate = 1.0;
      };
      exporters = [];
    };
    metrics = {
      enabled = false;
      exporters = [];
    };
  };
}
