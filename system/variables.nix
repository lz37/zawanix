{
  config,
  lib,
  pkgs,
  ...
}: let
  gsettings-schema-dir = "${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}/glib-2.0/schemas";

  # REA：import-reference-source 导入参考源码树时的忽略清单（gitignore 语义，命中即不进参考图谱）。
  # 属"用户隐私策略"，故放系统层而不是塞进 NUR 包。
  reaSecretPatterns = [
    "**/.env"
    "**/.env.*"
    "**/*.pem"
    "**/*.key"
    "**/*.p12"
    "**/*.pfx"
    "**/id_rsa*"
    "**/id_ed25519*"
    "**/.ssh/**"
    "**/.aws/**"
    "**/.gnupg/**"
    "**/.npmrc"
    "**/.netrc"
    "**/.docker/config.json"
    "**/credentials*"
    "**/secrets.y*ml"
    "**/secrets.json"
    "**/*.tfstate*"
    "**/keystore*"
  ];

  # NixOS 把 sessionVariables 逐条渲染成 `export NAME="<值>"`，且**不转义值里的引号**
  # （nixos/modules/config/shells-environment.nix：exportVariables = ''export ${n}="${…}"''）。
  # REA 要的是 JSON，JSON 里必然有 "；直接放进去，shell 一 source 就把这些引号当语法吃掉，
  # 值退化成 `[a,b]`（非法 JSON），于是 rea 在任何调用（CLI/MCP）的启动自检里退出：
  #   REA configuration is invalid: REA_REFERENCE_SECRET_PATTERNS_JSON must be valid JSON.
  # 所以在 Nix 侧自己把 " 转义成 \"：落盘是 \", source 之后正好还原成合法 JSON。
  reaSecretPatternsJson = let
    forbidden = [
      "\""
      "$"
      "`"
      "!"
      "\\"
    ];
  in
    assert lib.assertMsg (lib.all (p: lib.all (c: !(lib.hasInfix c p)) forbidden) reaSecretPatterns)
    "REA_REFERENCE_SECRET_PATTERNS_JSON 的模式不能含 \" $ ` ! \\ —— 它们在 sessionVariables 的双引号上下文里会被 shell 解释";
      builtins.replaceStrings ["\""] ["\\\""] (builtins.toJSON reaSecretPatterns);
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
      npm_config_registry = "https://registry.npmmirror.com";
      pnpm_config_registry = npm_config_registry;
      BUN_CONFIG_REGISTRY = npm_config_registry;
      YARN_NPM_REGISTRY_SERVER = npm_config_registry;
      PIP_INDEX_URL = "https://pypi.tuna.tsinghua.edu.cn/simple";
      PIP_TRUSTED_HOST = "pypi.tuna.tsinghua.edu.cn";
      GOPROXY = "https://goproxy.cn,direct";
      GITSTATUS_LOG_LEVEL = "DEBUG";
      EXA_API_KEY = config.zerozawa.exa-mcp.apiKey;
      CONTEXT7_API_KEY = config.zerozawa.context7.apiKey;
      TAVILY_API_KEY = config.zerozawa.tavily-mcp.apiKey;
      BRAVE_API_KEY = config.zerozawa.brave-mcp.apiKey;
      GITHUB_PERSONAL_ACCESS_TOKEN = config.zerozawa.github.access-token.classic;
      HINDSIGHT_API_URL = config.zerozawa.hindsight.url;
      HINDSIGHT_API_TOKEN = config.zerozawa.hindsight.token;
      LITELLM_BASE_URL = config.zerozawa.litellm.url;
      LITELLM_API_KEY = config.zerozawa.litellm.apiKey;
      # envfs 能让 ls 单个二进制文件也能成功 否则只会在 open/exe c时成功
      ENVFS_RESOLVE_ALWAYS = 1;
      # 转义细节见文件顶部 reaSecretPatternsJson。
      REA_REFERENCE_SECRET_PATTERNS_JSON = reaSecretPatternsJson;
    };
  };
}
