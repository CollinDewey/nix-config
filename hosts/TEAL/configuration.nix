{ ... }:
{
  services.duplicati = {
    enable = true;
    user = "root"; # yuck
  };

  services.netdata.enable = true;
}