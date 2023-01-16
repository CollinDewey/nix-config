{ pkgs, config, ... }:
let
  keys = builtins.fetchurl {
    url = "https://github.com/LegitMagic.keys";
    sha256 = "0vlzvfif2ccqwjjz5sn70wbgj7i7vmc3ga62s2idlws0hha9j6rl";
  };
in
{
  sops.defaultSopsFile = ../../secrets/esports.yaml;
  sops.secrets.esports-hashed-password.neededForUsers = true;
  users.groups.esports.gid = 1000;
  users.users.esports = {
    uid = 1000;
    group = "esports";
    shell = pkgs.zsh;
    isNormalUser = true;
    passwordFile = config.sops.secrets.esports-hashed-password.path;
    openssh.authorizedKeys.keyFiles = [ keys ];
    extraGroups = [ "wheel" "docker" "dialout" "scanner" "lp" "libvirtd" "wireshark" "plugdev" "adbusers" ];
  };
}
