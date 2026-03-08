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
        verbatimConfig =
          if isNvidiaGPU
          then ''
            cgroup_device_acl = [
              "/dev/null", "/dev/full", "/dev/zero",
              "/dev/random", "/dev/urandom",
              "/dev/ptmx", "/dev/kvm",
              "/dev/nvidiactl", "/dev/nvidia0", "/dev/nvidia-modeset", "/dev/dri/renderD128"
            ]
            seccomp_sandbox = 0
          ''
          else "";
      };
    };
    spiceUSBRedirection.enable = true;
  };
}
