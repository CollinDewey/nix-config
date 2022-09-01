{ config, ... }: let
    fetchKeys = username: (builtins.fetchurl "https://github.com/${username}.keys");
in
{
  users.groups.collin.gid = 1000;
  users.users.collin = {
    uid = 1000;
    group = "collin";
    isNormalUser = true;
    initialPassword = "nixos";
    # Use initialHashedPassword once I get secrets setup
    openssh.authorizedKeys.keys = [ (fetchKeys "LegitMagic") ];
    extraGroups = [ "wheel" "docker" "dialout" "scanner" "lp" "libvirtd" "wireshark" ];
  };
}