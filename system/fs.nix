{ram, ...}: {
	swapDevices = [
		{
			device = "/var/lib/swapfile";
			size = ram;
			priority = 1;
		}
	];
	boot.tmp = {
		cleanOnBoot = true;
	};
	services = {
		envfs.enable = true;
		gvfs.enable = true;
	};
}
