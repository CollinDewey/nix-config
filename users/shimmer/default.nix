{ pkgs, config, ... }:
let
  keys = builtins.fetchurl {
    url = "https://github.com/LegitMagic.keys";
    sha256 = "0vlzvfif2ccqwjjz5sn70wbgj7i7vmc3ga62s2idlws0hha9j6rl";
  };
in
{
  sops.defaultSopsFile = ../../secrets/collin.yaml;
  sops.secrets.collin-hashed-password.neededForUsers = true;
  users.groups.shimmer.gid = 1001;
  users.users.shimmer = {
    uid = 1001;
    group = "shimmer";
    shell = pkgs.zsh;
    isNormalUser = true;
    passwordFile = config.sops.secrets.collin-hashed-password.path;
    openssh.authorizedKeys.keyFiles = [ keys ];
    extraGroups = [ "wheel" "docker" "dialout" "scanner" "lp" "libvirtd" "wireshark" "plugdev" "adbusers" "collin" ];
  };
}
