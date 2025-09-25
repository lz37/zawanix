{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    blender
    unityhub
    godot-mono
  ];
}
