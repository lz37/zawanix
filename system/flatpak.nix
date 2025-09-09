{...}: {
	services.flatpak = {
		enable = false;
		packages = [
			# "cn.feishu.Feishu"
			# "com.github.tchx84.Flatseal"
			# "io.github.giantpinkrobots.flatsweep"
		];
		update = {
			onActivation = true;
			auto = {
				enable = true;
				onCalendar = "daily";
			};
		};
		uninstallUnused = true;
	};
}
