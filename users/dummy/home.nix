{ pkgs, lib, ... }:
{
  home.username = "dummy";
  home.homeDirectory = if pkgs.stdenv.isDarwin then lib.mkForce "/Users/dummy" else "/home/dummy";

}
