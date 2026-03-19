{pkgs, ...}: {
  # may needed for skills
  environment.systemPackages = with pkgs.master; [
    # cli
    bun
    uv
    nodejs
    (python3.withPackages (ps:
      with ps; [
        pypdf
      ]))
    deno
    pnpm
    yarn
    go
    graalvmPackages.graalvm-ce
    ast-grep
  ];
}
