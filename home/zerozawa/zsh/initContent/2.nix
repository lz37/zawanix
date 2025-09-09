{
	config,
	lib,
	...
}: {
	programs.zsh = {
		initContent =
			lib.mkOrder 1000 ''
				# p10k
				# To customize prompt, run `p10k configure` or edit ${config.zerozawa.path.p10k}.
				[[ ! -f ${config.zerozawa.path.p10k} ]] || source ${config.zerozawa.path.p10k}
			'';
	};
}
