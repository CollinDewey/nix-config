{ pkgs, lib, ... }:
{
  home.username = "collin";
  home.homeDirectory = if pkgs.stdenv.isDarwin then lib.mkForce "/Users/collin" else "/home/collin";

  programs.git = {
    settings.user.name = "CollinDewey";
    settings.user.email = "collin@dewey.net";
    lfs.enable = true;
  };
}
