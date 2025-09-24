{pkgs, ...}: {
	# Set your time zone.
	time.timeZone = "Asia/Shanghai";

	i18n = rec {
		# Select internationalisation properties.
		defaultLocale = "zh_CN.UTF-8";
		extraLocaleSettings = {
			LC_ADDRESS = defaultLocale;
			LC_IDENTIFICATION = defaultLocale;
			LC_MEASUREMENT = defaultLocale;
			LC_MONETARY = defaultLocale;
			LC_NAME = defaultLocale;
			LC_NUMERIC = defaultLocale;
			LC_PAPER = defaultLocale;
			LC_TELEPHONE = defaultLocale;
			LC_TIME = defaultLocale;
			LC_ALL = defaultLocale;
			LANGUAGE = defaultLocale;
		};
		inputMethod = {
			type = "fcitx5";
			enable = true;
			fcitx5 = {
				waylandFrontend = true;
				addons = with pkgs; [
					(fcitx5-rime.override
						{
							librime =
								(librime.override {
										plugins = [librime-lua librime-octagram];
									}).overrideAttrs (old: {
										buildInputs = (old.buildInputs or []) ++ [luajit];
									});
							rimeDataPkgs =
								[rime-data]
								++ (with pkgs.nur.repos; (with xddxdd; [
											rime-ice
											rime-moegirl
											rime-zhwiki
											rime-dict
										]));
						})
					fcitx5-rime
					fcitx5-chinese-addons
					fcitx5-mozc
					fcitx5-gtk
					fcitx5-lua
				];
			};
		};
	};
}
