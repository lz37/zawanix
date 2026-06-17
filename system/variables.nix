{
  config,
  pkgs,
  ...
}: {
  environment = {
    localBinInPath = true;
    homeBinInPath = true;
    sessionVariables = rec {
      NIXOS_OZONE_WL = "1";
      npm_config_nodedir = "${pkgs.master.nodejs}/include/node";
      LIBVIRT_DEFAULT_URI = "qemu:///system"; # https://github.com/winapps-org/winapps/blob/main/docs/libvirt.md
      NH_OS_FLAKE = config.zerozawa.path.cfgRoot;
      NH_FLAKE = NH_OS_FLAKE;
      npm_config_registry = config.nixpkgs.config.npmRegistryOverrides."registry.npmjs.org";
      pnpm_config_registry = npm_config_registry;
      BUN_CONFIG_REGISTRY = npm_config_registry;
      YARN_NPM_REGISTRY_SERVER = npm_config_registry;
      PIP_INDEX_URL = "https://pypi.tuna.tsinghua.edu.cn/simple";
      PIP_TRUSTED_HOST = "pypi.tuna.tsinghua.edu.cn";
      GOPROXY = "https://goproxy.cn,direct";
      GITSTATUS_LOG_LEVEL = "DEBUG";
      EXA_APL_KEY = config.zerozawa.exa-mcp.apiKey;
      TAVILY_API_KEY = config.zerozawa.tavily-mcp.apiKey;
      BRAVE_API_KEY = config.zerozawa.brave-mcp.apiKey;
    };
  };
}
