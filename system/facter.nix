{hostName, ...}: {
  facter = {
    detected = {
      dhcp.enable =
        {
          zawanix-work = false;
          zawanix-glap = true;
        }."${hostName}";
    };
  };
}
