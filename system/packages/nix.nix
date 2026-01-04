{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    nixbang
    devbox
    nix-du
    nix-script
    nix-tree
    nix-melt
    nix-alien
    nix-health
    nil
    nixd
    nixfmt-rfc-style
    npins
    nurl
    stable.mcp-nixos
    nvd
    nixpkgs-lint
    alejandra
    treefmt
    nix_version_search_cli
  ];
}
