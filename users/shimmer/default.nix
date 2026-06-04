{ pkgs, config, ... }:
let
  keys = ../../authorized_keys;
in
{
  users.groups.shimmer.gid = 1001;
  users.users.shimmer = {
    uid = 1001;
    group = "shimmer";
    shell = pkgs.zsh;
    isNormalUser = true;
    hashedPasswordFile = config.sops.secrets.collin-hashed-password.path;
    openssh.authorizedKeys.keyFiles = [ keys ];
    extraGroups = [ "wheel" "docker" "dialout" "scanner" "lp" "libvirtd" "wireshark" "plugdev" "adbusers" "collin" "kvm" "gamemode" "klipper" "video" "render" ];
  };
}
