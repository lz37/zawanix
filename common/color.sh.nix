let
	untilsGenerator = style: str: "${style}${str}";
	color = {
		NO_FORMAT = str: "${str}\\033[0m";
		F_BOLD = untilsGenerator "\\033[1m";
		F_DIM = untilsGenerator "\\033[2m";
		F_UNDERLINED = untilsGenerator "\\033[4m";
		C_GOLD3 = untilsGenerator "\\033[38;5;142m";
		C_ORANGE1 = untilsGenerator "\\033[38;5;214m";
		C_MAGENTA3 = untilsGenerator "\\033[38;5;127m";
		C_DODGERBLUE1 = untilsGenerator "\\033[38;5;33m";
		utils = {
			chunibyo.gothic.kaomoji.unicode = {
				gothic,
				kaomoji,
				unicode ? "",
				scope,
				action,
				splitter ? "・",
			}: "${color.NO_FORMAT (color.F_BOLD (color.C_GOLD3 gothic))}${color.NO_FORMAT (color.F_UNDERLINED (color.C_MAGENTA3 scope))}${splitter}${color.NO_FORMAT (color.F_BOLD (color.C_DODGERBLUE1 "${action}！"))}${color.NO_FORMAT (color.F_DIM (color.C_ORANGE1 kaomoji))}${unicode}";
		};
	};
in
	color
