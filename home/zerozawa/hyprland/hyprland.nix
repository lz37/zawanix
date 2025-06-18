{
  pkgs,
  isNvidiaGPU,
  lib,
  config,
  ...
}:

let
  chromium-args = builtins.concatStringsSep " " (import ../browser/common.nix).commandLineArgs;
  mainMod = "SUPER";
  terminal = "${pkgs.kitty}/bin/kitty";
  fileManager = "${pkgs.kdePackages.dolphin}/bin/dolphin";
  browser = "${pkgs.vivaldi}/bin/vivaldi ${chromium-args}";
  vscode = "${pkgs.vscode}/bin/code ${chromium-args}";
in
{
  home.packages = with pkgs; [
    hyprls
  ];
  programs.waybar = {
    enable = true;
    package = pkgs.waybar-git;
  };
  wayland.windowManager.hyprland = {
    enable = true;
    package = null;
    portalPackage = null;
    # https://github.com/hyprwm/Hyprland/blob/main/example/hyprland.conf
    settings = {
      exec-once = [
        "${pkgs.kdePackages.kwallet-pam}/libexec/pam_kwallet_init &"
        "${pkgs.kdePackages.kwallet}/bin/kwalletd6 &"
        "${pkgs.waybar-git}/bin/waybar"
      ];
      bind = [
        "${mainMod}, Q, exec, ${terminal}"
        "${mainMod}, E, exec, ${fileManager}"
        "${mainMod}, B, exec, ${browser}"
        "${mainMod}, C, exec, ${vscode}"
      ];
      source = [
        "${config.zerozawa.path.cfgRoot}/profile/hyprland.conf"
      ];
      env =
        (lib.optionals isNvidiaGPU [
          "LIBVA_DRIVER_NAME,nvidia"
          "__GLX_VENDOR_LIBRARY_NAME,nvidia"
        ])
        ++ [
          "NIXOS_OZONE_WL,1"
          "XCURSOR_SIZE,24"
          "HYPRCURSOR_SIZE,24"
        ];
    };
  };
}
