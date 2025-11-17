{
  lib,
  pkgs,
  config,
  ...
}: let
  switcherPath = "${config.xdg.configHome}/hypr/monitors.conf";
  monitors = {
    "desc:Lectron Company Ltd LECOO M2732PL GG1FF276" = rec {
      HDR =
        SDR
        // {
          cm = "hdr";
          bitdepth = 10;
          sdr_min_luminance = 0.005;
          max_luminance = 400;
          sdrbrightness = 1.4;
        };
      SDR = {
        mode = "3840x2160@60.00";
        position = "0x0";
        scale = 2;
        cm = "srgb";
        bitdepth = 8;
        vrr = false;
      };
    };
    "desc:Dell Inc. DELL P2314H HMJ1V66S787S" = {
      SDR = {
        mode = "1920x1080@60.00";
        position = "1920x0";
        scale = 1;
        bitdepth = 8;
      };
    };
    "desc:California Institute of Technology 0x1509" = {
      SDR = {
        mode = "2560x1440@165.00";
        position = "0x0";
        scale = 1;
        bitdepth = 8;
        cm = "srgb";
      };
    };
    "desc:SAC G52 0000000000000" = rec {
      HDR =
        SDR
        // {
          cm = "hdr";
          bitdepth = 10;
          sdr_min_luminance = 0.005;
          max_luminance = 300;
          sdrbrightness = 1.4;
        };
      SDR = {
        mode = "2560x1440@180.00";
        position = "2560x0";
        scale = 1;
        cm = "srgb";
        bitdepth = 8;
        vrr = false;
      };
    };
    "desc:ASUSTek COMPUTER INC VG34VQL3A S6LMDW008622" = rec {
      HDR =
        SDR
        // {
          cm = "hdr";
          bitdepth = 10;
          sdr_min_luminance = 0.005;
          max_luminance = 400;
          sdrbrightness = 1.2;
        };
      SDR = {
        mode = "3440x1440@165.00";
        position = "2560x0";
        scale = 1;
        cm = "srgb";
        bitdepth = 8;
        vrr = false;
      };
    };
  };
  hdrConf = pkgs.writeTextFile {
    name = "hdr-monitor.conf";
    text = lib.hm.generators.toHyprconf {
      attrs = {
        monitorv2 = lib.attrValues (lib.mapAttrs (
            name: value:
              (
                if value ? HDR
                then value.HDR
                else value.SDR
              )
              // {
                output = name;
              }
          )
          monitors);
      };
      importantPrefixes = ["$" "output"];
    };
  };
  sdrConf = pkgs.writeTextFile {
    name = "sdr-monitor.conf";
    text = lib.hm.generators.toHyprconf {
      attrs = {
        monitorv2 = lib.attrValues (lib.mapAttrs (
            name: value:
              value.SDR
              // {
                output = name;
              }
          )
          monitors);
      };
      importantPrefixes = ["$" "output"];
    };
  };
  monitor-switcher = pkgs.writeScriptBin "monitor-switcher" ''
    #!${lib.getExe pkgs.bash}
    MODE="$1"
    if [ "''${MODE}" = "hdr" ]; then
      ln -sf "${hdrConf}" "${switcherPath}"
      echo "Switched to HDR monitor configuration."
    elif [ "''${MODE}" = "sdr" ]; then
      ln -sf "${sdrConf}" "${switcherPath}"
      echo "Switched to SDR monitor configuration."
    elif [ "''${MODE}" = "" ]; then
      CURRENT_TARGET="$(readlink "${switcherPath}")"
      if [ "''${CURRENT_TARGET}" = "${hdrConf}" ]; then
        ln -sf "${sdrConf}" "${switcherPath}"
        echo "Switched to SDR monitor configuration."
      else
        ln -sf "${hdrConf}" "${switcherPath}"
        echo "Switched to HDR monitor configuration."
      fi
    else
      echo "Usage: monitor-switcher [hdr|sdr]"
      exit 1
    fi
  '';
in {
  home = {
    activation.link-monitor-config = lib.hm.dag.entryAfter ["writeBoundary"] ''
      #!${lib.getExe pkgs.bash}
      if [ ! -f "${switcherPath}" ]; then
        ln -s "${hdrConf}" "${switcherPath}"
      fi
      TARGET="$(readlink "${switcherPath}")"
      if [ "''${TARGET}" != "${hdrConf}" ] && [ "''${TARGET}" != "${sdrConf}" ]; then
        ln -sf "${hdrConf}" "${switcherPath}"
      fi
    '';
    packages = [
      monitor-switcher
    ];
  };
  wayland.windowManager.hyprland = {
    settings = {
      source = [switcherPath];
      monitor = [
        ", preferred, auto, 1"
      ];
    };
  };
}
