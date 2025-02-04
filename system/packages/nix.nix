{
  pkgs,
  ...
}:

{
  environment.systemPackages = with pkgs; [
    nil
    nixd
    nixbang
    nixfmt-rfc-style
    devbox
    devenv
    nix-du
    nix-script
    nix-tree
    nix-melt
    nix-alien
  ];
}
