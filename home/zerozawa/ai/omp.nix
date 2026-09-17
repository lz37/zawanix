{
  config,
  lib,
  ...
}: let
  cfgRoot = config.zerozawa.path.cfgRoot;
  ompConfigDir = "${cfgRoot}/home/zerozawa/ai/omp";
in {
  programs.omp = {
    enable = true;
  };
  home.activation.linkOmpConfig = lib.hm.dag.entryAfter ["writeBoundary"] ''
    if [ ! -L "$HOME/.omp" ] && [ -d "$HOME/.omp" ]; then
      mv "$HOME/.omp" "$HOME/.omp.bak.$(date +%s)"
    fi
    ln -sfn ${ompConfigDir} "$HOME/.omp"
  '';
}
