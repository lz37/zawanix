{config, ...}: let
  hw = config.zerozawa.hardware;
  host = config.zerozawa.host;
in {
  powerManagement = {
    cpuFreqGovernor =
      if hw.isLaptop
      then null
      else "performance";
  };
  services.power-profiles-daemon.enable = host.isGameMachine && !hw.isLaptop;
}
