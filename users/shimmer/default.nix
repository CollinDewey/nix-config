{ pkgs, config, ... }:
let
  keys = builtins.fetchurl {
    url = "https://github.com/CollinDewey.keys";
    sha256 = "sha256:0f6j55wszsxg7kpwlf7p6av2mpkw3djpx35inqy8a97dh8hjyx7q";
  };
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
    extraGroups = [ "wheel" "docker" "dialout" "scanner" "lp" "libvirtd" "wireshark" "plugdev" "adbusers" "collin" "kvm" "gamemode" ];
  };
}
