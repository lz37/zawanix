{hostName, ...}: {
	config =
		{
			zawanix-work = {
				facter.detected.dhcp.enable = false;
			};
			zawanix-glap = {};
		}
    ."${hostName}";
}
