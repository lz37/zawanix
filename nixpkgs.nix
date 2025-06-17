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
        inherit (inputs.nixpkgs-teleport.legacyPackages.${system}) teleport;
        inherit (inputs.waybar.packages.${system}) waybar;
        inherit (inputs.hyprland.packages.${system}) hyprland xdg-desktop-portal-hyprland;
        inherit (inputs.illogical-impulse.legacyPackages.${system})
          illogical-impulse-ags
          illogical-impulse-ags-launcher
          illogical-impulse-hyprland-shaders
          illogical-impulse-kvantum
          illogical-impulse-oneui4-icons
          ;
      })
      inputs.nix-alien.overlays.default
    ];
  };
}
