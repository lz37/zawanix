{
  pkgs,
  ...
}:

{
  environment.systemPackages = with pkgs; [
    nixbang
    devbox
    devenv
    nix-du
    nix-script
    nix-tree
    nix-melt
    nix-alien
    nix-health
    nil-git
    nixd
    nixfmt-rfc-style
    npins
    nurl
  ];
}
