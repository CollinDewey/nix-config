{ ... }:
{
  services.vaultwarden = {
    enable = true;
    environmentFile = "/var/lib/vaultwarden.env";
    backupDir = "/var/backup/vaultwarden";
  };

  networking.firewall.allowedTCPPorts = [ 80 ];

  system.stateVersion = "24.05";
}
