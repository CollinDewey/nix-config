{ ... }:
{
  services.adguardhome = {
    enable = true;
    openFirewall = true;
    mutableSettings = true; # TODO: Make this false and configure through services.adguardhome.settings
  };

  system.stateVersion = "23.11";
}
