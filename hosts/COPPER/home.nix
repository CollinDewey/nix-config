{ pkgs, ... }:
{
  # A lot of these belong in modules, I'm currently just testing out stuff
  home.packages = with pkgs; [
    mpv
    keeweb
    vscode
  ];
}
