{
  pkgs,
  lib,
  config,
  ...
}:

{
  programs = {
    adb.enable = true;
    # steam
    steam = {
      enable = true;
      gamescopeSession = {
        enable = true;
      };
      extest = {
        enable = true;
      };
      protontricks = {
        enable = true;
      };
    };
    # solve GTK themes are not applied in Wayland applications
    dconf.enable = true;
    # needed for `nix-alien-ld`
    nix-ld.enable = true;
    kdeconnect = {
      enable = true;
      package = lib.mkForce pkgs.kdePackages.kdeconnect-kde;
    };
    virt-manager = {
      enable = true;
    };
    command-not-found.enable = false;
    bash.interactiveShellInit = ''
      source ${pkgs.nix-index}/etc/profile.d/command-not-found.sh
    '';
    zsh = {
      enable = true;
      interactiveShellInit = ''
        source ${pkgs.nix-index}/etc/profile.d/command-not-found.sh
      '';
    };
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
    nh = {
      enable = true;
      clean = {
        enable = true;
        extraArgs = "--keep-since 4d --keep 3";
      };
      flake = config.zerozawa.path.cfgRoot;
    };
    mtr.enable = true;
    appimage = {
      enable = true;
      binfmt = true;
      package = pkgs.appimage-run.override {
        extraPkgs =
          pkgs:
          (with pkgs; [
            libatomic_ops
            bzip2
          ]);
      };
    };
    obs-studio = {
      enable = true;
      enableVirtualCamera = true;
      plugins = with pkgs.obs-studio-plugins; [
        wlrobs # need for wayland
        obs-backgroundremoval
        obs-pipewire-audio-capture
        obs-vaapi
        droidcam-obs
      ];
    };
  };
}
