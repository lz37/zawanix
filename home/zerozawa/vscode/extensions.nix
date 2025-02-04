{ config, pkgs, ... }:
let
  system-exts = with pkgs.vscode-extensions; [
    ## remote
    ms-vscode-remote.remote-ssh
    ms-vscode-remote.remote-containers
    ms-vsliveshare.vsliveshare
    ms-azuretools.vscode-docker
    eamodio.gitlens
    vadimcn.vscode-lldb
    ms-vscode.cpptools
    xaver.clang-format
    llvm-vs-code-extensions.vscode-clangd
    ms-vscode.cmake-tools
    twxs.cmake
  ];
  vscode-marketplace-exts = with pkgs.vscode-marketplace; [
    # language
    ms-ceintl.vscode-language-pack-zh-hans
    # tools
    formulahendry.code-runner
    github.vscode-github-actions
    github.copilot
    formulahendry.auto-rename-tag
    formulahendry.auto-close-tag
    christian-kohler.path-intellisense
    adpyke.codesnap
    wakatime.vscode-wakatime
    jetpack-io.devbox
    yy0931.save-as-root
    tboox.xmake-vscode
    # vscodevim.vim
    # asvetliakov.vscode-neovim
    usernamehw.errorlens
    tintinweb.vscode-inline-bookmarks
    ## web
    vue.volar
    flowtype.flow-for-vscode
    styled-components.vscode-styled-components
    bradlc.vscode-tailwindcss
    wix.vscode-import-cost
    kisstkondoros.vscode-gutter-preview
    inlang.vs-code-extension
    # program language
    ## nix
    jnoortheen.nix-ide
    ## markdown
    yzhang.markdown-all-in-one
    shd101wyy.markdown-preview-enhanced
    ## rust
    rust-lang.rust-analyzer
    tauri-apps.tauri-vscode
    ## go
    golang.go
    ## java
    # redhat.java
    # vscjava.vscode-java-debug
    # vscjava.vscode-java-test
    # vscjava.vscode-maven
    # vscjava.vscode-gradle
    # vscjava.vscode-java-dependency
    # vscjava.vscode-spring-initializr
    # vscjava.vscode-spring-boot-dashboard
    # vmware.vscode-spring-boot
    # redhat.fabric8-analytics
    # vscjava.vscode-lombok
    ## python
    ms-python.python
    ##
    redhat.vscode-yaml
    redhat.vscode-xml
    mikestead.dotenv
    tamasfe.even-better-toml
    # debug
    # firefox-devtools.vscode-firefox-debug
    ms-edgedevtools.vscode-edge-devtools
    # formatter
    ms-python.black-formatter
    foxundermoon.shell-format
    esbenp.prettier-vscode
    dbaeumer.vscode-eslint
    stylelint.vscode-stylelint
    davidanson.vscode-markdownlint
    streetsidesoftware.code-spell-checker
    # theme & beautify
    fisheva.eva-theme
    pkief.material-icon-theme
    oderwat.indent-rainbow
    naumovs.color-highlight
  ];
in
{
  programs.vscode.extensions = vscode-marketplace-exts ++ system-exts;
}
