{ pkgs, ... }: {
  # Lua 语言支持（lua-language-server 客户端）：诊断/补全/跳转。
  # 注意 VSCode 1.144 自带 source.lua 语法，nix-injection 的 /* lua */ 块不依赖本扩展；
  # 这里给的是 .lua 文件的 LSP，和 OMP 的 lua-hypr server 对齐。
  extensions = with pkgs.vscode-marketplace; [
    sumneko.lua
  ];
}
