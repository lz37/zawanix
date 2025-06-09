{ pkgs, ... }:

let
  symlinks = {
    # need by playwright/mcp
    chrome = {
      source = "${pkgs.google-chrome}/bin/google-chrome-stable";
      target = "/opt/google/chrome/chrome";
    };
  };
in
{
  system.activationScripts =
    symlinks
    |> builtins.mapAttrs (name: value: value // { target_dir = builtins.dirOf value.target; })
    |> builtins.mapAttrs (
      name:
      {
        source,
        target,
        target_dir,
      }:
      {
        deps = [ "binsh" ];
        text = ''
          if [ ! -d "${target_dir}" ]; then
            mkdir -p "${target_dir}";
          fi
          if [ ! -L "${target}" ]; then
            ln -s "${source}" "${target}";
          fi
        '';
      }
    );
}
