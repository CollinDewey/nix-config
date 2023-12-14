{ lib, ... }:
{
  users.users.syncthing.uid = lib.mkForce 1000;
  users.users.syncthing.isSystemUser = true;
  users.groups.syncthing.gid = lib.mkForce 1000;

  services.syncthing = {
    enable = true;
    openDefaultPorts = true;
    guiAddress = "0.0.0.0:8384";
  };
  
  system.stateVersion = "23.11";
}  
