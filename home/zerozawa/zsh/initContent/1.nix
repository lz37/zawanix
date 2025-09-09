{lib, ...}: {
	programs.zsh = {
		initContent =
			lib.mkBefore ''
				autoload zcalc
			'';
	};
}
