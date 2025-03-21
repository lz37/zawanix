{
  pkgs,
  lib,
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
    tmux = {
      enable = true;
      clock24 = true;
      keyMode = "vi";
    };
    virt-manager = {
      enable = true;
    };
    firefox = {
      enable = true;
      languagePacks = [ "zh-CN" ];
      preferencesStatus = "user";
      nativeMessagingHosts = {
        # packages = [ pkgs.kdePackages.plasma-browser-integration ];
      };
    };
    chromium = {
      enable = true;
      enablePlasmaBrowserIntegration = true;
      plasmaBrowserIntegrationPackage = lib.mkForce pkgs.kdePackages.plasma-browser-integration;
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
  };
}
