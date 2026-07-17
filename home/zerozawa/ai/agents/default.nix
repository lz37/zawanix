{
  config,
  lib,
  ...
}: let
  cfgRoot = config.zerozawa.path.cfgRoot;
  agentsDir = "${cfgRoot}/home/zerozawa/ai/agents";
in {
  home.activation.linkAgentsDir = lib.hm.dag.entryAfter ["writeBoundary"] ''
    if [ ! -L "$HOME/.agents" ] && [ -d "$HOME/.agents" ]; then
      mv "$HOME/.agents" "$HOME/.agents.bak.$(date +%s)"
    fi
    ln -sfn ${agentsDir} "$HOME/.agents"
  '';
}
