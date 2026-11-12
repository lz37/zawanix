{ ... }: {
  services = {
    hypridle = {
      enable = true;
      settings = {
        general = {
          after_sleep_cmd = "hyprctl eval 'hl.dispatch(hl.dsp.dpms({action=\"on\"}))'";
          ignore_dbus_inhibit = false;
          lock_cmd = "dms ipc call lock lock";
        };
        listener = [
          {
            timeout = 900;
            on-timeout = "dms ipc call lock lock";
          }
          {
            timeout = 1200;
            on-timeout = "hyprctl eval 'hl.dispatch(hl.dsp.dpms({action=\"off\"}))'";
            on-resume = "hyprctl eval 'hl.dispatch(hl.dsp.dpms({action=\"on\"}))'";
          }
        ];
      };
    };
  };
}
