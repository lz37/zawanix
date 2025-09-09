{pkgs, ...}: {
	extensions = with pkgs.vscode-selected-extensionsCompatible.vscode-marketplace; [
		ms-vscode-remote.remote-containers
	];
	settings = {
		"dev.containers.copyGitConfig" = true;
		"dev.containers.cacheVolume" = true;
		"dev.containers.mountWaylandSocket" = true;
		# "dev.containers.defaultExtensions" = [
		#   "streetsidesoftware.code-spell-checker"
		#   "naumovs.color-highlight"
		#   "GitHub.vscode-github-actions"
		#   "GitHub.copilot"
		#   "eamodio.gitlens"
		#   "oderwat.indent-rainbow"
		#   "yzhang.markdown-all-in-one"
		#   "shd101wyy.markdown-preview-enhanced"
		#   "DavidAnson.vscode-markdownlint"
		#   "christian-kohler.path-intellisense"
		#   "esbenp.prettier-vscode"
		#   "WakaTime.vscode-wakatime"
		#   "redhat.vscode-xml"
		#   "redhat.vscode-yaml"
		#   "kisstkondoros.vscode-gutter-preview"
		#   "bradlc.vscode-tailwindcss"
		# ];
	};
}
