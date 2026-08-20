# Workaround: upstream oh-my-pi@17.3.8 (rev 7e54061) updated bun.lock in
# edc0caeb0f without regenerating nix/bun.nix, so bun2nix's bunDeps lacks
# 6 tarballs (cli-truncate@6.1.1, gpt-tokenizer@4.0.0,
# is-fullwidth-code-point@5.1.0, mitata@1.0.34, slice-ansi@9.0.0,
# wrap-ansi@10.0.0) and the sandboxed build's `bun install` falls back to
# the network, which non-FOD derivations do not have -> ConnectionRefused.
# Remove this override once the omp flake input advances past an upstream
# nix/bun.nix regeneration.
{
  inputs,
  system,
  lib,
}: let
  ompSrc = inputs.omp.outPath;
  bun2nixPkgs = import inputs.nixpkgs {
    inherit system;
    overlays = [inputs.omp.inputs.bun2nix.overlays.default];
  };
  patchedDependencies =
    lib.mapAttrs (_: patch: ompSrc + "/${patch}")
    (lib.importJSON (ompSrc + "/package.json")).patchedDependencies;
in
  inputs.omp.packages.${system}.omp.overrideAttrs (_old: {
    bunDeps = bun2nixPkgs.bun2nix.fetchBunDeps {
      bunNix = import ./omp-bun-extra.nix ompSrc;
      overrides = bun2nixPkgs.bun2nix.patchedDependenciesToOverrides {inherit patchedDependencies;};
    };
  })
