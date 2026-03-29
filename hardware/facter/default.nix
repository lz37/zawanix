{hostName, ...}: {
  hardware.facter = {
    enable = true;
    reportPath = ./. + "/${hostName}.json";
    detected = {
      dhcp.enable =
        {
          zawanix-work = false;
          zawanix-glap = true;
          zawanix-fubuki = true;
        }."${hostName}";
    };
  };
}
