{
  lib,
  pkgs,
  config,
  ...
}:
with pkgs; let
  servers = {
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
      ];
      mcpServers = servers;
    };
  };
}
