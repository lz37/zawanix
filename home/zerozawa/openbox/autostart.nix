{pkgs, ...}: {
  xdg.configFile."openbox/autostart" = {
    executable = true;
    text = ''
      #!/bin/bash
      systemctl --user start plasma-polkit-agent.service &
      ${pkgs.kdePackages.kwallet-pam}/libexec/pam_kwallet_init &
    '';
  };
}
