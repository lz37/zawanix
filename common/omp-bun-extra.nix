# Wraps upstream oh-my-pi nix/bun.nix (imported in place: its copyPathToStore
# entries reference ../packages/* relative to the file itself) and adds the
# 6 tarballs missing from the stale 17.3.8 manifest — upstream updated
# bun.lock in edc0caeb0f without regenerating nix/bun.nix:
# cli-truncate@6.1.1, gpt-tokenizer@4.0.0, is-fullwidth-code-point@5.1.0,
# mitata@1.0.34, slice-ansi@9.0.0, wrap-ansi@10.0.0.
# Hashes are the sha512 integrities from bun.lock.
# Remove together with common/omp-package.nix once the omp flake input
# advances past an upstream nix/bun.nix regeneration.
ompSrc: {
  copyPathToStore,
  fetchFromGitHub,
  fetchgit,
  fetchurl,
  ...
}:
(import (ompSrc + "/nix/bun.nix") {
  inherit
    copyPathToStore
    fetchFromGitHub
    fetchgit
    fetchurl
    ;
})
// {
  "cli-truncate@6.1.1" = fetchurl {
    url = "https://registry.npmjs.org/cli-truncate/-/cli-truncate-6.1.1.tgz";
    hash = "sha512-06p9vyLahLa4zkGcgsGxU6iEkSOiuI4fhCH6Emhe2lPAcoUv73n72DnODsnHA+5wwXGnV0n9M9/qOQJSjYhFhw==";
  };
  "gpt-tokenizer@4.0.0" = fetchurl {
    url = "https://registry.npmjs.org/gpt-tokenizer/-/gpt-tokenizer-4.0.0.tgz";
    hash = "sha512-YAWIyzvuVUHEfW7tFfFAxH8qQb+Q3RU9nYOTy7skMNX5qzU6Q8jxTHZLyO56ug1vYvCR7wndzpd3jwD86/mhjQ==";
  };
  "is-fullwidth-code-point@5.1.0" = fetchurl {
    url = "https://registry.npmjs.org/is-fullwidth-code-point/-/is-fullwidth-code-point-5.1.0.tgz";
    hash = "sha512-5XHYaSyiqADb4RnZ1Bdad6cPp8Toise4TzEjcOYDHZkTCbKgiUl7WTUCpNWHuxmDt91wnsZBc9xinNzopv3JMQ==";
  };
  "mitata@1.0.34" = fetchurl {
    url = "https://registry.npmjs.org/mitata/-/mitata-1.0.34.tgz";
    hash = "sha512-Mc3zrtNBKIMeHSCQ0XqRLo1vbdIx1wvFV9c8NJAiyho6AjNfMY8bVhbS12bwciUdd1t4rj8099CH3N3NFahaUA==";
  };
  "slice-ansi@9.0.0" = fetchurl {
    url = "https://registry.npmjs.org/slice-ansi/-/slice-ansi-9.0.0.tgz";
    hash = "sha512-SO/3iYL5S3W57LLEniscOGPZgOqZUPCx6d3dB+52B80yJ0XstzsC/eV8gnA4tM3MHDrKz+OCFSLNjswdSC+/bA==";
  };
  "wrap-ansi@10.0.0" = fetchurl {
    url = "https://registry.npmjs.org/wrap-ansi/-/wrap-ansi-10.0.0.tgz";
    hash = "sha512-SGcvg80f0wUy2/fXES19feHMz8E0JoXv2uNgHOu4Dgi2OrCy1lqwFYEJz1BLbDI0exjPMe/ZdzZ/YpGECBG/aQ==";
  };
}
