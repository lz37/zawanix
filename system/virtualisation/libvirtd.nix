{
  pkgs,
  ...
}:

{
  environment.systemPackages = with pkgs; [
    quickemu
    quickgui
  ];

  virtualisation = {
    # kvm
    libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu;
        swtpm = {
          enable = true;
          package = pkgs.swtpm;
        };
        ovmf = {
          enable = true;
          packages = [ pkgs.OVMFFull.fd ];
        };
      };
    };
    spiceUSBRedirection.enable = true;
  };
}
