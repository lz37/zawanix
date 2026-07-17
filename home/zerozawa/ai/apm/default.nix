{
  config,
  lib,
  ...
}: let
  cfgRoot = config.zerozawa.path.cfgRoot;
  apmDir = "${cfgRoot}/home/zerozawa/ai/apm";
in {
  home.activation.linkApmDir = lib.hm.dag.entryAfter ["linkAgentsDir"] ''
    if [ ! -L "$HOME/.apm" ] && [ -d "$HOME/.apm" ]; then
      mv "$HOME/.apm" "$HOME/.apm.bak.$(date +%s)"
    fi
    ln -sfn ${apmDir} "$HOME/.apm"
  '';
}
