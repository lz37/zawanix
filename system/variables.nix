{ ... }:

{
  environment = {
    localBinInPath = true;
    homeBinInPath = true;
    sessionVariables = {
      NIXOS_OZONE_WL = "1";
      LIBVIRT_DEFAULT_URI = "qemu:///system"; # https://github.com/winapps-org/winapps/blob/main/docs/libvirt.md
    };
  };
}
