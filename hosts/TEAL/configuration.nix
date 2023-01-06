{ pkgs, ... }:
{
  services.duplicati = {
    enable = true;
    user = "root"; # yuck
  };

  environment.systemPackages = with pkgs; [
    rclone # Needed for Duplicati
  ];

  services.netdata.enable = true;
}