{pkgs, ...}: {
  # USB Automounting
  services.gvfs.enable = true;
  # services.udisks2.enable = true;
  # services.devmon.enable = true;

  # Enable USB-specific packages
  environment.systemPackages = with pkgs; [
    usbutils
  ];
}
