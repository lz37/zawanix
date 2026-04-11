{
  isLaptop,
  isGameMachine,
  ...
}: {
  powerManagement = {
    cpuFreqGovernor =
      if isLaptop
      then null
      else "performance";
  };
  services.power-profiles-daemon.enable = isGameMachine && !isLaptop;
}
