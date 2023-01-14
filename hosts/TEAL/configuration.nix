{ pkgs, ... }:
{
  services.duplicati = {
    enable = true;
    user = "root"; # yuck
  };
  systemd.services.duplicati = {
    path = [ pkgs.rclone ];
  };

  services.netdata.enable = true;
}
