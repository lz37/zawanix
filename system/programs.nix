{
  pkgs,
  lib,
  config,
  amd64Microarchs,
  ...
}: {
  programs = {
    gnupg.agent.pinentryPackage = lib.mkForce pkgs.pinentry-qt;
    adb.enable = true;
    # steam
    steam = {
      enable = true;
      gamescopeSession = {
        enable = true;
      };
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      extest.enable = true;
      extraCompatPackages = [pkgs.nur.repos.forkprince."proton-cachyos-v${lib.strings.substring 8 1 amd64Microarchs}-bin"];
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
        extraPkgs = pkgs: (with pkgs; [
          libatomic_ops
          bzip2
        ]);
      };
    };
  };
}
