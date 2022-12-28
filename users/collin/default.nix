{ config, ... }: let
  keys = builtins.fetchurl {
    url = "https://github.com/LegitMagic.keys";
    sha256 = "0p16j5xvjfy0c1gajvlw9k1w42illxldz4kalr674h9slmly0bb2";
  };
in
{
  sops.secrets.collin-hashed-password.neededForUsers = true;
  users.groups.collin.gid = 1000;
  users.users.collin = {
    uid = 1000;
    group = "collin";
    isNormalUser = true;
    passwordFile = config.sops.secrets.collin-hashed-password.path;
    openssh.authorizedKeys.keyFiles = [ keys ];
    extraGroups = [ "wheel" "docker" "dialout" "scanner" "lp" "libvirtd" "wireshark" "plugdev" "adbusers" ];
  };
}