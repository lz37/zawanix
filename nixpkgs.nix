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
      inputs.nix4vscode.overlays.forVscode
      (
        final: prev:
        let
          pkgs = prev;
        in
        {
          # 启用 NUR
          nur = import inputs.nur {
            nurpkgs = prev;
            pkgs = prev;
          };
          stable = import inputs.nixpkgs-stable {
            inherit system;
            config.allowUnfree = true;
          };
          waydroid = prev.waydroid.override {
            python3Packages = prev.python312Packages;
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
          teleport-lock = inputs.nixpkgs-teleport.legacyPackages.${system}.teleport;
          hyprland-git-pkgs = inputs.hyprland.packages.${system};
          hyprland-git-nixpkgs-pkgs = inputs.hyprland.inputs.nixpkgs.legacyPackages.${system};
          waybar-git = inputs.waybar.packages.${system}.waybar;
          nil-git = inputs.nil.outputs.packages.${system}.nil;
          anyrun-git-pkgs = inputs.anyrun.packages.${system};
        }
      )
      inputs.nix-alien.overlays.default
    ];
  };
}
