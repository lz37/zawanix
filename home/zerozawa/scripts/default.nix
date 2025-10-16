{pkgs, ...} @ inputs: let
  common-args =
    {
      inherit pkgs;
    }
    // inputs;
in {
  home.packages = [
    (import ./keybinds.nix common-args)
    (import ./task-waybar.nix common-args)
    (import ./web-search.nix common-args)
    (import ./rofi-launcher.nix common-args)
    (import ./screenshootin.nix common-args)
  ];
}
