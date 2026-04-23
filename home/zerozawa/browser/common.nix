{
  commandLineArgs = [
    # wayland
    "--enable-features=UseOzonePlatform,WaylandWindowDecorations,AcceleratedVideoDecodeLinuxGL"
    "--disable-features=UseChromeOSDirectVideoDecoder"
    "--ozone-platform-hint=auto"
    "--enable-wayland-ime"
    "--wayland-text-input-version=3"
    "--force-device-scale-factor"
    # "--disable-features=WaylandWpColorManagerV1"
  ];
}
