{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    quickemu
    quickgui
  ];

  virtualisation = {
    # kvm
    libvirtd = {
      enable = true;
      qemu = {
        vhostUserPackages = with pkgs; [virtiofsd];
        package = pkgs.qemu;
        swtpm = {
          enable = true;
          package = pkgs.swtpm;
        };
      };
    };
    spiceUSBRedirection.enable = true;
  };
}
