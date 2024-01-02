{ ... }:
{
  services.adguardhome = {
    enable = true;
    openFirewall = true;
    mutableSettings = true; # TODO: Make this false and configure through services.adguardhome.settings
  };

  networking = {
    hostName = "adguardhome";
    defaultGateway.address = "10.111.111.1";
    interfaces."mv-virbr2".ipv4.addresses = [
      {
        address = "10.111.111.3";
        prefixLength = 24;
      }
    ];
  };

  system.stateVersion = "23.11";
}
