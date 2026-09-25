{ pkgs, lib, ... }:
{
  home.username = "dummy";
  home.homeDirectory = if pkgs.stdenv.hostPlatform.isDarwin then lib.mkForce "/Users/dummy" else "/home/dummy";

}
