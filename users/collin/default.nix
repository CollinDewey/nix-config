{ pkgs, config, ... }:
let
  keys = ../../authorized_keys;
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
    extraGroups = [ "wheel" "docker" "dialout" "scanner" "lp" "libvirtd" "wireshark" "plugdev" "adbusers" "kvm" "gamemode" "klipper" "video" "seat" "render" ];
  };
}
