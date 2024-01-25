{ pkgs, ... }:
{
  programs.git = {
    signing.signByDefault = true;
    signing.key = "F5B2AFFCB4386C88";
  };
  home.packages = [
    pkgs.looking-glass-client
    pkgs.distrobox
  ];
}
