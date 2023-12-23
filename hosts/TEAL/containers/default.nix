{ ... }:
{
  networking.nat = {
    enable = true;
    internalInterfaces = ["ve-adguardhome"];
    externalInterface = "enp5s0f0";
  };

  containers = {
    jellyfin = {
      ephemeral = true;
      autoStart = true;
      privateNetwork = true;
      hostAddress = "192.168.100.1";
      localAddress = "192.168.100.2";
      config = ./jellyfin.nix;
      bindMounts = {
        "/var/lib/jellyfin" = {
          hostPath = "/services/jellyfin/config";
          isReadOnly = false;
        };
        "/media" = {
          hostPath = "/services/jellyfin/media";
          isReadOnly = true;
        };
      };
    };
    
    syncthing = {
      ephemeral = true;
      autoStart = true;
      config = ./syncthing.nix;
      bindMounts = {
        "/var/lib/syncthing" = {
          hostPath = "/services/syncthing";
          isReadOnly = false;
        };
      };
    };

    adguardhome = {
      ephemeral = true;
      autoStart = true;
      config = ./adguardhome.nix;
      bindMounts = {
        "/var/lib/private/AdGuardHome" = {
          hostPath = "/services/adguardhome";
          isReadOnly = false;
        };
      };
    };

    microbin = {
      ephemeral = true;
      autoStart = true;
      privateNetwork = true;
      hostAddress = "192.168.100.1";
      localAddress = "192.168.100.3";
      config = ./microbin.nix;
      bindMounts = {
        "/var/lib/private/microbin" = {
          hostPath = "/services/microbin";
          isReadOnly = false;
        };
      };
    };
  };
}