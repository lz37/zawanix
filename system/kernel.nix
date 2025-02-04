{
  pkgs,
  config,
  ...
}:

{
  boot = {
    kernelPackages = pkgs.linuxPackages_zen;
    extraModulePackages = with config.boot.kernelPackages; [
      # Virtual Camera
      v4l2loopback
    ];
    supportedFilesystems = [ "ntfs" ];
    kernelParams = [
      "systemd.mask=systemd-vconsole-setup.service"
      "systemd.mask=dev-tpmrm0.device" # this is to mask that stupid 1.5 mins systemd bug
      "nowatchdog"
      "modprobe.blacklist=sp5100_tco" # watchdog for AMD
      "modprobe.blacklist=iTCO_wdt" # watchdog for Intel
    ];
    # Needed For Some Steam Games
    kernel.sysctl = {
      "vm.max_map_count" = 2147483642;
    };
    plymouth.enable = true;
  };
}
