{
  config,
  pkgs,
  ...
}: let
  gsettings-schema-dir = "${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}/glib-2.0/schemas";
in {
  environment = {
    localBinInPath = true;
    homeBinInPath = true;
    sessionVariables = rec {
      GSETTINGS_SCHEMA_DIR = gsettings-schema-dir;
      NIXOS_OZONE_WL = "1";
      # npm_config_nodedir = "${pkgs.master.nodejs}/include/node";
      LIBVIRT_DEFAULT_URI = "qemu:///system"; # https://github.com/winapps-org/winapps/blob/main/docs/libvirt.md
      NH_OS_FLAKE = config.zerozawa.path.cfgRoot;
      NH_FLAKE = NH_OS_FLAKE;
      # 仅供交互式包管理器使用；nixpkgs 的 npmRegistryOverrides 会改变 fetchNpmDeps FOD 哈希。
      npm_config_registry = "https://mirrors.cloud.tencent.com/npm/";
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
      HINDSIGHT_API_URL = config.zerozawa.hindsight.url;
      HINDSIGHT_API_TOKEN = config.zerozawa.hindsight.token;
      LITELLM_BASE_URL = config.zerozawa.litellm.url;
      LITELLM_API_KEY = config.zerozawa.litellm.apiKey;
    };
  };
}
