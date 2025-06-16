{ ... }:
{
  xdg.configFile."electron-flags.conf".text = builtins.concatStringsSep "\n" (
    (import ./common.nix).commandLineArgs
  );
}
