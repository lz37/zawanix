{
  inputs,
  system,
  ...
}:
{
  nixpkgs = {
    config = {
      allowUnfree = true;
      packageOverrides = pkgs: {
        intel-vaapi-driver = pkgs.intel-vaapi-driver.override { enableHybridCodec = true; };
      };
    };
    overlays = [
      inputs.nix-vscode-extensions.overlays.default
      inputs.nix4vscode.overlays.default
      inputs.nixpkgs-wayland.overlay
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
            inherit system;
            config.allowUnfree = true;
          };
          master = import inputs.nixpkgs-master {
            inherit system;
            config.allowUnfree = true;
          };
          vscode-selected = (master.vscode.override { useVSCodeRipgrep = true; });
          vscode-selected-extensionsCompatible = (
            (pkgs.usingFixesFrom pkgs).forVSCodeVersion vscode-selected.version
          );
          vscode-selected-extensionsCompatible-nix4vscode =
            let
              inherit (vscode-selected) version;
            in
            (with pkgs.nix4vscode; {
              forVscode = forVscodeVersion version;
              forVscodePrerelease = forVscodeVersionPrerelease version;
              forOpenVsx = forOpenVsxVersion version;
              forOpenVsxPrerelease = forOpenVsxVersionPrerelease version;
            });
          teleport-lock = inputs.nixpkgs-teleport.legacyPackages.${system}.teleport;
          hyprland-git-pkgs = inputs.hyprland.packages.${system};
          hyprland-git-nixpkgs-pkgs = inputs.hyprland.inputs.nixpkgs.legacyPackages.${system};
          waybar-git = inputs.waybar.packages.${system}.waybar;
          nil-git = inputs.nil.outputs.packages.${system}.nil;
          anyrun-git-pkgs = inputs.anyrun.packages.${system};
          picacg-qt = (pkgs.callPackage ./nixpkgs-build/picacg.nix { });
          jmcomic-qt = (pkgs.callPackage ./nixpkgs-build/jmcomic.nix { });
          zsh-url-highlighter = (pkgs.callPackage ./nixpkgs-build/zsh-url-highlighter.nix { });
          sddm-eucalyptus-drop = (pkgs.callPackage ./nixpkgs-build/sddm-eucalyptus-drop.nix { });
          wechat-web-devtools-linux = (pkgs.callPackage ./nixpkgs-build/wechat-web-devtools-linux.nix { });
        }
      )
      inputs.nix-alien.overlays.default
    ];
  };
}
