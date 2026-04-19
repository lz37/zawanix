{config, ...}: {
  environment = {
    localBinInPath = true;
    homeBinInPath = true;
    sessionVariables = rec {
      NIXOS_OZONE_WL = "1"; # 加了这个 kde global menu 就没法用，不加这个xwayland又不跟手 淦
      LIBVIRT_DEFAULT_URI = "qemu:///system"; # https://github.com/winapps-org/winapps/blob/main/docs/libvirt.md
      NH_OS_FLAKE = config.zerozawa.path.cfgRoot;
      NH_FLAKE = NH_OS_FLAKE;
      npm_config_registry = config.nixpkgs.config.npmRegistryOverrides."registry.npmjs.org";
      BUN_CONFIG_REGISTRY = npm_config_registry;
      YARN_NPM_REGISTRY_SERVER = npm_config_registry;
      PIP_INDEX_URL = "https://pypi.tuna.tsinghua.edu.cn/simple";
      PIP_TRUSTED_HOST = "pypi.tuna.tsinghua.edu.cn";
      GOPROXY = "https://goproxy.cn,direct";
    };
  };
}
