{ pkgs, ... }:
{
  services.duplicati = {
    enable = true;
    user = "collin";
  };
  systemd.services.duplicati = {
    path = [ pkgs.rclone ];
  };

  services.jellyfin.enable = true;

  services.netdata.enable = true;
}
