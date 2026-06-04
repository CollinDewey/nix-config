{ pkgs, ... }:
let
  keys = ../../authorized_keys;
in
{
  users.groups.dummy.gid = 1000;
  users.users.dummy = {
    uid = 1000;
    group = "dummy";
    shell = pkgs.zsh;
    isNormalUser = true;
    initialPassword = "dummy";
    openssh.authorizedKeys.keyFiles = [ keys ];
    extraGroups = [ "wheel" "docker" "dialout" "scanner" "lp" "libvirtd" "wireshark" "plugdev" "adbusers" "kvm" "gamemode" ];
  };

  # Extra info for VM
  users.users.root = {
    shell = pkgs.zsh;
    initialPassword = "dummy";
  };
}
