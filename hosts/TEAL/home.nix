{ ... }:
{
  programs.git = {
    signing.signByDefault = true;
    signing.key = "21A02BCB3C3ABEDA";
  };
  programs.zsh.history.path = "/persist/home/collin/.zsh_history";
}
