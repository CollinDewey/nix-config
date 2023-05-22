{ pkgs, ... }:
{
  services.duplicati = {
    enable = true;
    user = "collin";
  };
  systemd.services.duplicati = {
    path = [ pkgs.rclone ];
  };

  services.netdata.enable = true;
}
