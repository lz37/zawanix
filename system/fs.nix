{
  config,
  lib,
  ...
}: let
  home = config.zerozawa.path.home;
  cfgRoot = config.zerozawa.path.cfgRoot;
  # Repo-owned directories that must show up under $HOME as real paths instead
  # of symlinks. apm resolves symlinks and then refuses any path that lands
  # outside the project tree ($HOME at --global scope), both for its lifecycle
  # lock and for every .agents/skills/<name> it integrates.
  repoDirs = {
    ".apm" = "${cfgRoot}/home/zerozawa/ai/apm";
    ".agents" = "${cfgRoot}/home/zerozawa/ai/agents";
  };
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
  # that path, refusing to run when it traverses a symlink; it also rewrites
  # apm.yml / apm.lock.yaml through os.replace, which would silently clobber
  # per-file symlinks. Bind mounts are the only shape that keeps these repo
  # directories live under $HOME without a symlink anywhere in the path, and
  # they also keep every path under them resolving inside $HOME instead of
  # jumping over to /etc/nixos.
  fileSystems =
    lib.mapAttrs' (
      name: device:
        lib.nameValuePair "${home}/${name}" {
          inherit device;
          fsType = "none";
          options = [
            "bind"
            "nofail"
          ];
        }
    )
    repoDirs;
  # Migrate the old ln -sfn activations onto real mountpoint directories.
  system.activationScripts.repoDirs = ''
    for name in ${lib.escapeShellArgs (lib.attrNames repoDirs)}; do
      dir="${home}/$name"
      if [ -L "$dir" ]; then
        rm -f "$dir"
      fi
      mkdir -p "$dir"
      if ! mountpoint -q "$dir"; then
        chown zerozawa:users "$dir"
      fi
    done
  '';
}
