{
  lib,
  pkgs,
  ...
}: {
  boot = {
    loader = {
      # lanzaboote replaces the systemd-boot module but still installs a
      # signed systemd-boot binary as the boot menu.
      systemd-boot.enable = lib.mkForce false;
      efi.canTouchEfiVariables = true;
      timeout = 2;
    };
    lanzaboote = {
      enable = true;
      pkiBundle = "/var/lib/sbctl";
      # Kernels/initrds are copied to the ESP per generation; keep the ESP
      # from filling up.
      configurationLimit = 10;
      autoGenerateKeys.enable = true;
      autoEnrollKeys = {
        enable = true;
        # includeMicrosoftKeys defaults to true (Windows dual-boot and
        # MS-signed OptionROMs rely on keeping the Microsoft CAs enrolled).
        autoReboot = true;
      };
    };
  };
  environment.systemPackages = [pkgs.sbctl];
}
