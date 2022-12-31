{ pkgs, ... }:
{
  home.username = "collin";
  home.homeDirectory = if pkgs.stdenv.isDarwin then "/Users/collin" else "/home/collin";

  programs.git = {
    userName = "LegitMagic";
    userEmail = "76862862+LegitMagic@users.noreply.github.com";
  };

}
