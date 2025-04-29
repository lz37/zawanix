let
  NO_FORMAT = ''\033[0m'';
  untilsGenerator = style: str: ''
    ${style}${str}${NO_FORMAT}
  '';
  color = {
    inherit NO_FORMAT;
    F_BOLD = untilsGenerator ''\033[1m'';
    F_DIM = untilsGenerator ''\033[2m'';
    F_UNDERLINED = untilsGenerator ''\033[4m'';
    C_GOLD3 = untilsGenerator ''\033[38;5;142m'';
    C_ORANGE1 = untilsGenerator ''\033[38;5;214m'';
    C_MAGENTA3 = untilsGenerator ''\033[38;5;127m'';
    C_DODGERBLUE1 = untilsGenerator ''\033[38;5;33m'';
  };
in
color
