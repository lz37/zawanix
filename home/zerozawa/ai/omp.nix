{
  config,
  lib,
  pkgs,
  inputs,
  rootPath,
  ...
}: let
  cfgRoot = config.zerozawa.path.cfgRoot;
  ompConfigDir = "${cfgRoot}/home/zerozawa/ai/omp";
in {
  programs.omp = {
    enable = true;
    # bun.nix fix for upstream 17.3.8, see common/omp-package.nix header
    package = import (rootPath + "/common/omp-package.nix") {
      inherit inputs lib;
      system = pkgs.stdenv.hostPlatform.system;
    };
  };
  home.activation.linkOmpConfig = lib.hm.dag.entryAfter ["writeBoundary"] ''
    if [ ! -L "$HOME/.omp" ] && [ -d "$HOME/.omp" ]; then
      mv "$HOME/.omp" "$HOME/.omp.bak.$(date +%s)"
    fi
    ln -sfn ${ompConfigDir} "$HOME/.omp"
  '';
}
