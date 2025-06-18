{ lib, config, ... }:

{
  programs.zsh.initContent = lib.mkOrder 1000 ''
    # Use the generated color scheme

    if test -f ${config.home.homeDirectory}/.cache/ags/user/generated/terminal/sequences.txt; then
        cat ${config.home.homeDirectory}/.cache/ags/user/generated/terminal/sequences.txt
    fi
  '';
}
