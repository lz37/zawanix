{
  pkgs,
  isNvidiaGPU,
  ...
}: {
  environment.systemPackages = with pkgs; [
    quickemu
    quickgui
    virglrenderer
  ];

  virtualisation = with pkgs; {
    # kvm
    libvirtd = {
      enable = true;
      qemu = {
        vhostUserPackages = [virtiofsd];
        package = qemu;
        swtpm = {
          enable = true;
          package = swtpm;
        };
        verbatimConfig = ''
          cgroup_device_acl = [
            "/dev/null", "/dev/full", "/dev/zero",
            "/dev/random", "/dev/urandom",
            "/dev/ptmx", "/dev/kvm", "/dev/dri/renderD128"
          ${
            if isNvidiaGPU
            then '', "/dev/nvidiactl", "/dev/nvidia0", "/dev/nvidia-modeset"''
            else ""
          }
          ]
          seccomp_sandbox = 0
        '';
      };
    };
    spiceUSBRedirection.enable = true;
  };
}
