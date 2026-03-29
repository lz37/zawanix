{hostName, ...}: {
  facter = {
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
