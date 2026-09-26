{...}: {
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        Enable = "Source,Sink,Media,Socket";
        Experimental = true;
        Privacy = "device";
        JustWorksRepairing = "always";
      };
    };
  };
}
