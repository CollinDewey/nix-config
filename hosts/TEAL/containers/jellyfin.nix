{ ... }:
{
  users.users.jellyfin.uid = 1000;
  users.groups.jellyfin.gid = 1000;

  services.jellyfin = {
      enable = true;
      openFirewall = true;
  };

  system.stateVersion = "23.11";
}