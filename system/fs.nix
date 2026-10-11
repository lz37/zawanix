{config, ...}: let
  home = config.zerozawa.path.home;
  apmDir = "${config.zerozawa.path.cfgRoot}/home/zerozawa/ai/apm";
in {
  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = config.zerozawa.hardware.ram;
      priority = -2;
    }
  ];
  boot.tmp = {
    cleanOnBoot = true;
  };
  services = {
    envfs.enable = true;
    gvfs.enable = true;
  };
  # apm hardcodes ~/.apm/.apm-lifecycle.lock and lstat()s every component of
  # that path, refusing to run when it traverses a symlink. It also rewrites
  # apm.yml / apm.lock.yaml through os.replace, which would silently clobber
  # per-file symlinks. A bind mount is the only shape that keeps the repo
  # directory live under $HOME without a symlink anywhere in the path.
  fileSystems."${home}/.apm" = {
    device = apmDir;
    fsType = "none";
    options = [
      "bind"
      "nofail"
    ];
  };
  # Migrate the old ln -sfn ~/.apm onto a real mountpoint directory.
  system.activationScripts.apmDir = ''
    if [ -L "${home}/.apm" ]; then
      rm -f "${home}/.apm"
    fi
    mkdir -p "${home}/.apm"
    if ! mountpoint -q "${home}/.apm"; then
      chown zerozawa:users "${home}/.apm"
    fi
  '';
}
