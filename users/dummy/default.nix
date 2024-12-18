{ pkgs, ... }:
let
  keys = builtins.fetchurl {
    url = "https://github.com/CollinDewey.keys";
    sha256 = "sha256:0f6j55wszsxg7kpwlf7p6av2mpkw3djpx35inqy8a97dh8hjyx7q";
  };
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
