{ ... }:

{
  environment = {
    localBinInPath = true;
    homeBinInPath = true;
    sessionVariables = {
      NIXOS_OZONE_WL = "1";
    };
  };
}
