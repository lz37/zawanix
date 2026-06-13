{
  config,
  lib,
  inputs,
  ...
}: let
  cfgRoot = config.zerozawa.path.cfgRoot;
  ompConfigDir = "${cfgRoot}/home/zerozawa/ai/omp";
in {
  home.file.".agents/skills/superpowers" = {
    source = "${inputs.superpowers}/skills";
  };

  home.activation.linkOmpConfig = lib.hm.dag.entryAfter ["writeBoundary"] ''
    if [ ! -L "$HOME/.omp" ] && [ -d "$HOME/.omp" ]; then
      mv "$HOME/.omp" "$HOME/.omp.bak.$(date +%s)"
    fi
    ln -sfn ${ompConfigDir} "$HOME/.omp"
  '';
}
