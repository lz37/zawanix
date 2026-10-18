{
  lib,
  pkgs,
  config,
  inputs,
  ...
}:
with pkgs; let
  # REA 的 pwndbg 增强（inspect_recorded_crash --debugger-context）三键成套；缺一个只在调用期报错。
  pwndbg = inputs.pwndbg.packages.${pkgs.stdenv.hostPlatform.system}.pwndbg;
  pwndbgVenv = pwndbg.meta.pwndbgVenv;
  # venv 的 site-packages 是符号链接农场，find 默认不跟随 → 用 bash glob + readlink -f
  # （python 版本号也一并 wildcard 掉）
  pwndbgGdbinit = pkgs.runCommandLocal "rea-pwndbg-gdbinit.py" {} ''
    src=""
    for x in ${pwndbgVenv}/lib/python3*/site-packages/pwndbginit/gdbinit.py; do
      if [ -f "$x" ]; then
        src=$(readlink -f "$x")
        break
      fi
    done
    [ -n "$src" ] || {
      echo "pwndbginit/gdbinit.py not found under ${pwndbgVenv}" >&2
      exit 1
    }
    install -Dm444 "$src" $out
  '';
  servers = {
    chrome-devtools = {
      command = lib.getExe' pnpm "pnpx";
      args = [
        "chrome-devtools-mcp@latest"
        "--browser-url=http://127.0.0.1:9222"
        "--no-usage-statistics"
      ];
    };
    # 需要的时候再在项目下开
    # vscode = {
    #   command = lib.getExe' pnpm "pnpx";
    #   args = ["@vscode-mcp/vscode-mcp-server@latest"];
    # };
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
    # 没必要 bash 就ok了
    # docker = {
    #   command = lib.getExe' uv "uvx";
    #   args = ["docker-mcp"];
    # };
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
    # zhihu-search = {
    #   command = lib.getExe' pnpm "pnpx";
    #   args = [
    #     "supergateway"
    #     "--sse"
    #     "https://developer.zhihu.com/api/mcp/zhihu_search/v1/sse"
    #     "--oauth2Bearer"
    #     config.zerozawa.zhihu-mcp.apiKey
    #   ];
    # };
    # zhihu-search-global = {
    #   command = lib.getExe' pnpm "pnpx";
    #   args = [
    #     "supergateway"
    #     "--sse"
    #     "https://developer.zhihu.com/api/mcp/global_search/v1/sse"
    #     "--oauth2Bearer"
    #     config.zerozawa.zhihu-mcp.apiKey
    #   ];
    # };
    # recomment = {
    #   command = lib.getExe nodejs-slim;
    #   args = [
    #     "${vscode-selected-extensionsCompatible.vscode-marketplace.vkhey.recomment-pro}/share/vscode/extensions/vkhey.recomment-pro/out/mcpServer.js"
    #   ];
    # };
    computer-use = {
      command = lib.getExe' pnpm "pnpx";
      args = [
        "@agent-sh/computer-use-linux"
        "mcp"
      ];
    };
    image-tiler = {
      command = lib.getExe' pnpm "pnpx";
      args = ["image-tiler-mcp-server"];
    };
    pctx = {
      command = lib.getExe nur.repos.zerozawa.pctx;
      args = [
        "--config"
        (toString (
          (pkgs.formats.json {}).generate "pctx.json" ((import ./pctx.nix) {inherit pkgs config;})
        ))
        "mcp"
        "start"
        "--stdio"
      ];
    };
    context-mode = {
      command = lib.getExe nur.repos.zerozawa.context-mode;
    };
    codegraph = {
      command = lib.getExe llm-agents.codegraph;
      args = [
        "serve"
        "--mcp"
      ];
    };
    rea = {
      command = lib.getExe nur.repos.zerozawa.rea-agents;
      args = [
        "mcp"
      ];
      # 这里只放「本机 / 本人」的策略项，会覆盖 NUR 包 wrapper 里的 --set-default。
      env = {
        # tools/list 体积：off = 不再下发 output schema（REA 仍按内部契约校验每个结果）
        REA_MCP_OUTPUT_SCHEMA_PROFILE = "off";
        # pwndbg 增强（仅 inspect_recorded_crash --debugger-context 用到）：三键必须成套
        # （GDB 必须是 pwndbg 入口；GDBINIT 必须是 Python 文件；VENV 目录必须存在）
        REA_PWNDBG_GDB = "${pwndbg}/bin/pwndbg";
        REA_PWNDBG_GDBINIT = "${pwndbgGdbinit}";
        REA_PWNDBG_VENV_PATH = "${pwndbgVenv}";
      };
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
        "context-mode" # 没啥用
        "pctx" # omp 已有 xd:// 动态发现和eval调用
        "github" # 内置
        ### 使用自带搜索
        "brave"
        "exa"
        "tavily"
        # "zhihu-search-global"
        ###
        "chrome-devtools" # omp有browser
      ];
      mcpServers = servers;
    };
  };
}
