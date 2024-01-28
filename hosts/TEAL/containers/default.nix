{ pkgs, ... }:
{
  # Currently connecting a bridge (virbr2) to my OPNSense VM, created through virsh

  networking.nat = {
    enable = true;
    #internalInterfaces = [""];
    #externalInterface = "enp5s0f0";
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
      macvlans = [ "virbr2" ];
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

  # This fails if Docker is not running, aka if it's updating. Lovely. Needs to be converted into a SystemD service
  #system.activationScripts.mkContainerNet = ''
  #  ${pkgs.docker}/bin/docker network inspect container_net >/dev/null 2>&1 || ${pkgs.docker}/bin/docker network create -d macvlan --subnet=10.111.111.0/24 --gateway=10.111.111.1 -o parent=virbr2 container_net
  #'';

  virtualisation.oci-containers = {
    backend = "docker";
    containers = {
      lancache = {
        image = "lancachenet/monolithic:latest";
        hostname = "lancache";
        extraOptions = [ "--network=container_net" "--ip=10.111.111.2"];
        autoStart = true;
        environment = {
          USE_GENERIC_CACHE = "TRUE";
          CACHE_DISK_SIZE = "500g";
          TZ = "America/Louisville";
        };
        volumes = [
          "/clearable/lancache/cache:/data/cache"
          "/clearable/lancache/logs:/data/logs"
        ];
      };
      homeassistant = {
        image = "ghcr.io/home-assistant/home-assistant:stable";
        hostname = "homeassistant";
        extraOptions = [ "--network=container_net" "--ip=10.111.111.4"];
        autoStart = true;
        environment.TZ = "America/Louisville";
        volumes = [
          "/services/homeassistant:/config"
        ];
      };  
    };
  };
}