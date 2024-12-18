{ config, ... }:

{
  environment = {
    localBinInPath = true;
    homeBinInPath = true;
    sessionVariables = rec {
      ALL_PKG_STORE = "${config.zerozawa.nixos.path.code}/store";
      YARN_CACHE_FOLDER = "${ALL_PKG_STORE}/yarn/cache";
      YARN_GLOBAL_FOLDER = "${ALL_PKG_STORE}/yarn/global";
      npm_config_store_dir = "${ALL_PKG_STORE}/pnpm";
    };
  };
}