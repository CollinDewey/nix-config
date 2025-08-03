{ lib, ... }:
{
  users.users.jellyfin.uid = 1000;
  users.groups.jellyfin.gid = 1000;


  networking = {
    nameservers = [ "172.16.0.1" "1.1.1.1" "1.0.0.1" "8.8.8.8" ];
    useHostResolvConf = lib.mkForce false;
  };

  services.jellyfin = {
    enable = true;
    openFirewall = true;
  };

  system.stateVersion = "23.11";
}
