{
  lib,
  inputs,
  system,
  ...
}:
let
  config = {
    allowInsecurePredicate = pkgs: builtins.stringLength (lib.getName pkgs) <= 20;
    allowUnfree = true;
  };
in
{
  nixpkgs = {
    inherit config;
    overlays = [
      inputs.nix-vscode-extensions.overlays.default
      inputs.nix4vscode.overlays.default
      inputs.nix-alien.overlays.default
      (
        final: prev:
        let
          pkgs = prev;
        in
        rec {
          # 启用 NUR
          nur = import inputs.nur {
            nurpkgs = prev;
            pkgs = prev;
          };
          stable = import inputs.nixpkgs-stable {
            inherit system config;
          };
          master = import inputs.nixpkgs-master {
            inherit system config;
          };
          vscode-selected = (master.vscode.override { useVSCodeRipgrep = true; });
          vscode-selected-extensionsCompatible = (
            (pkgs.usingFixesFrom pkgs).forVSCodeVersion (lib.getVersion vscode-selected)
          );
          vscode-selected-extensionsCompatible-nix4vscode =
            let
              version = lib.getVersion vscode-selected;
            in
            (with pkgs.nix4vscode; {
              forVscode = forVscodeVersion version;
              forVscodePrerelease = forVscodeVersionPrerelease version;
              forOpenVsx = forOpenVsxVersion version;
              forOpenVsxPrerelease = forOpenVsxVersionPrerelease version;
            });
          teleport = inputs.nixpkgs-teleport.legacyPackages.${system}.teleport;
          picacg-qt = (pkgs.callPackage ./nixpkgs-build/picacg.nix { });
          jmcomic-qt = (pkgs.callPackage ./nixpkgs-build/jmcomic.nix { });
          zsh-url-highlighter = (pkgs.callPackage ./nixpkgs-build/zsh-url-highlighter.nix { });
          sddm-eucalyptus-drop = (pkgs.callPackage ./nixpkgs-build/sddm-eucalyptus-drop.nix { });
          wechat-web-devtools-linux = (pkgs.callPackage ./nixpkgs-build/wechat-web-devtools-linux.nix { });
          waybar-vd = (pkgs.callPackage ./nixpkgs-build/waybar-vd.nix { });
          hyprlandPlugins = pkgs.hyprlandPlugins // {
            virtual-desktops = inputs.hyprland-virtual-desktops.packages.${system}.virtual-desktops;
          };
          intel-vaapi-driver = pkgs.intel-vaapi-driver.override { enableHybridCodec = true; };
          waylrc = inputs.waylrc.packages.${system}.waylrc;
        }
      )
    ];
  };
}
