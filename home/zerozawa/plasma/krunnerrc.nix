{...}: {
  programs.plasma.configFile.krunnerrc = {
    General = {
      FreeFloating = true;
      historyBehavior = "ImmediateCompletion";
    };
  };
}
