{ lib, ... }:

{
  # should be --impure
  imports = [
    /etc/nixos/options/variable.nix
  ];
  options = {
    zerozawa = lib.mkOption {
      type = lib.types.raw;
    };
  };
}
