{...}: {
	fileSystems = {
		"/" = {
			device = "/dev/disk/by-uuid/82807551-0eb9-4aaa-a193-2ffc46704a95";
			fsType = "ext4";
		};
		"/boot" = {
			device = "/dev/disk/by-uuid/CC37-0D53";
			fsType = "vfat";
			options = [
				"fmask=0077"
				"dmask=0077"
			];
		};
	};
}
