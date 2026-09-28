# Fzf is a general-purpose command-line fuzzy finder.
{...}: {
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    # Atuin owns Ctrl-R as the dedicated history manager.
    historyWidget.command = "";
    defaultOptions = [
      "--margin=1"
      "--layout=reverse"
      "--border=none"
      "--info='hidden'"
      "--header=''"
      "--prompt='/ '"
      "-i"
      "--no-bold"
      "--bind='enter:execute(nvim {})'"
      "--preview='bat --style=numbers --color=always --line-range :500 {}'"
      "--preview-window=right:60%:wrap"
    ];
  };
}
