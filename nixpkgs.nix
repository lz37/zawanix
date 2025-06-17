{ inputs, system, ... }:
{
  nixpkgs = {
    config = {
      allowUnfree = true;
    };
    overlays = [
      inputs.nix4vscode.overlays.forVscode
      (final: prev: {
        # 启用 NUR
        nur = import inputs.nur {
          nurpkgs = prev;
          pkgs = prev;
        };
        stable = import inputs.nixpkgs-stable {
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
        teleport-lock = inputs.nixpkgs-teleport.legacyPackages.${system}.teleport;
        hyprland-git = inputs.hyprland.packages.${system}.hyprland;
        xdg-desktop-portal-hyprland-git = inputs.hyprland.packages.${system}.xdg-desktop-portal-hyprland;
        mesa-hyprland-git = inputs.hyprland.inputs.nixpkgs.legacyPackages.${system}.mesa;
        pkgsi686Linux-hyprland-git = inputs.hyprland.inputs.nixpkgs.legacyPackages.${system}.pkgsi686Linux;
        waybar-git = inputs.waybar.packages.${system}.waybar;
        nil-git = inputs.nil.outputs.packages.${system}.nil;
      })
      inputs.nix-alien.overlays.default
    ];
  };
}
