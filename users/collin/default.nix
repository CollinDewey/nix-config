{ pkgs, config, ... }:
let
  keys = builtins.fetchurl {
    url = "https://github.com/LegitMagic.keys";
    sha256 = "sha256:04rxmfazbr9vjssvrnwxqvmjd9szkjblxr6dwi6982qh0w3a9892";
  };
in
{
  sops.defaultSopsFile = ../../secrets/collin.yaml;
  sops.secrets.collin-hashed-password.neededForUsers = true;
  users.groups.collin.gid = 1000;
  users.users.collin = {
    uid = 1000;
    group = "collin";
    shell = pkgs.zsh;
    isNormalUser = true;
    passwordFile = config.sops.secrets.collin-hashed-password.path;
    openssh.authorizedKeys.keyFiles = [ keys ];
    extraGroups = [ "wheel" "docker" "dialout" "scanner" "lp" "libvirtd" "wireshark" "plugdev" "adbusers" "kvm" ];
  };
}
