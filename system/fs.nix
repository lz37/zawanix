{
  config,
  pkgs,
  ...
}:

{
  environment.systemPackages = [ pkgs.cifs-utils ];
  fileSystems =
    let
      samba-options = [
        "username=${config.zerozawa.samba.username},password=${config.zerozawa.samba.password},uid=1000,gid=100,iocharset=utf8,file_mode=0600,dir_mode=0700,nobrl,mfsymlinks"
      ];
      nfs-options = [
        "x-systemd.automount"
        "async"
        "nolock"
        "nfsvers=4"
        "noatime"
      ];
      samba-fsType = "cifs";
      nfs-fsType = "nfs";
    in
    {
      "${config.zerozawa.nixos.path.ssh}" = {
        device = config.zerozawa.servers.truenas.devices.ssh;
        fsType = samba-fsType;
        options = samba-options;
      };
      "${config.zerozawa.nixos.path.code}" = {
        device = config.zerozawa.servers.truenas.devices.code;
        fsType = nfs-fsType;
        options = nfs-options;
      };
    };
}
