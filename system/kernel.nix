{
	pkgs,
	config,
	isIntelCPU,
	isIntelGPU,
	lib,
	...
}: {
	stylix.targets.console.enable = true;
	boot = {
		kernelPackages = pkgs.linuxPackages_cachyos;
		extraModulePackages = [config.boot.kernelPackages.v4l2loopback];
		supportedFilesystems = [
			"btrfs"
			"ext4"
			"fat32"
			"ntfs"
		];
		initrd = {
			enable = true;
			verbose = false;
			systemd.enable = true;
			availableKernelModules =
				[
					"xhci_pci"
					"ahci"
					"nvme"
					"usbhid"
					"uas"
					"sd_mod"
					"ata_piix"
					"uhci_hcd"
					"sr_mod"
				]
				++ (lib.optionals isIntelGPU ["i915"]);
			kernelModules = [];
		};
		kernelParams =
			[
				"systemd.mask=systemd-vconsole-setup.service"
				"systemd.mask=dev-tpmrm0.device" # this is to mask that stupid 1.5 mins systemd bug
				"nowatchdog"
				"modprobe.blacklist=sp5100_tco" # watchdog for AMD
				"modprobe.blacklist=iTCO_wdt" # watchdog for Intel
			]
			++ (lib.optionals isIntelCPU [
					"intel_iommu=on"
					"iommu=pt"
				]);
		consoleLogLevel = 3;
		# Needed For Some Steam Games
		kernel.sysctl = {
			"vm.max_map_count" = 2147483642;
		};
		plymouth = {
			enable = true;
			themePackages = [pkgs.catppuccin-plymouth];
			theme = "catppuccin-macchiato";
			font = "${pkgs.nerd-fonts.fira-code}/share/fonts/truetype/NerdFonts/FiraCode/FiraCodeNerdFontMono-Regular.ttf";
		};
	};
}
