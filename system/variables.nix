{config, ...}: {
  environment = {
    localBinInPath = true;
    homeBinInPath = true;
    sessionVariables = rec {
      NIXOS_OZONE_WL = "1"; # 加了这个 kde global menu 就没法用，不加这个xwayland又不跟手 淦
      LIBVIRT_DEFAULT_URI = "qemu:///system"; # https://github.com/winapps-org/winapps/blob/main/docs/libvirt.md
      NH_OS_FLAKE = config.zerozawa.path.cfgRoot;
      NH_FLAKE = NH_OS_FLAKE;
    };
  };
}
