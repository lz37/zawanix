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
  };
}
