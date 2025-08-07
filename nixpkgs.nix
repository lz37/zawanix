{
  inputs,
  system,
  ...
}:
{
  nixpkgs = {
    config = {
      allowUnfree = true;
    };
    overlays = [
      inputs.nix-vscode-extensions.overlays.default
      inputs.nix4vscode.overlays.default
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
          inherit (inputs.illogical-impulse.legacyPackages.${system})
            illogical-impulse-ags
            illogical-impulse-ags-launcher
            illogical-impulse-hyprland-shaders
            illogical-impulse-kvantum
            illogical-impulse-oneui4-icons
            ;
          illogical-impulse-agsPackage =
            inputs.illogical-impulse.inputs.ags.packages.${system}.default.override
              {
                extraPackages = with pkgs; [
                  gtksourceview
                  gtksourceview4
                  webkitgtk_4_0
                  webp-pixbuf-loader
                  ydotool
                ];
              };
          vscode-selected = master.vscode;
          vscode-selected-extensionsCompatible = (
            (
              (import inputs.nixpkgs-master {
                inherit system;
                config.allowUnfree = true;
                overlays = [ inputs.nix-vscode-extensions.overlays.default ];
              }).usingFixesFrom
              pkgs
            ).forVSCodeVersion
              vscode-selected.version
          );
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
