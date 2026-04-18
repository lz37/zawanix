{pkgs, ...}: {
  # may needed for skills
  environment.systemPackages =
    (with pkgs.master; [
      # cli
      bun
      uv
      nodejs
      jq
      yq-go
      deno
      pnpm
      yarn
      go
      graalvmPackages.graalvm-ce
      ast-grep
      bash-language-server
      biome
      snip
    ])
    ++ [
      (pkgs.nocuda.python3.withPackages (ps:
        with ps; [
          pypdf
          pdf2image
          pdfplumber
          pillow
        ]))
    ];
}
