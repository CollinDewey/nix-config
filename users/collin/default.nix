{ pkgs, config, ... }:
let
  keys = builtins.fetchurl {
    url = "https://github.com/CollinDewey.keys";
    sha256 = "sha256:0f6j55wszsxg7kpwlf7p6av2mpkw3djpx35inqy8a97dh8hjyx7q";
  };
in
{
  users.groups.collin.gid = 1000;
  users.users.collin = {
    uid = 1000;
    group = "collin";
    shell = pkgs.zsh;
    isNormalUser = true;
    hashedPasswordFile = config.sops.secrets.collin-hashed-password.path;
    openssh.authorizedKeys.keyFiles = [ keys ];
    extraGroups = [ "wheel" "docker" "dialout" "scanner" "lp" "libvirtd" "wireshark" "plugdev" "adbusers" "kvm" "gamemode" "klipper" "video" ];
  };
}
