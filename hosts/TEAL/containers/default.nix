{ ... }:
{
  networking.nat = {
    enable = true;
    internalInterfaces = ["ve-changede2KnI"];
    externalInterface = "quad1";
  };

  systemd.tmpfiles.rules = [
    "d /services/jellyfin/config 0755 1000 1000 -"
    "d /services/syncthing 0755 1000 1000 -"
    "d /services/adguardhome 0755 0 0 -"
    "d /services/microbin 0755 0 0 -"
    "d /services/changedetection 0755 0 0 -"
    "d /services/vaultwarden 0755 0 0 -"
    "d /services/vaultwarden/vaultwarden 0755 0 0 -"
    "d /storage/vaultwarden_backup 0755 0 0 -"
    "f /services/vaultwarden/config 0755 0 0 - -"
  ];

  containers = {
    jellyfin = {
      ephemeral = true;
      autoStart = false;
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
      autoStart = false;
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
      autoStart = false;
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
      autoStart = false;
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

    changedetection = {
      ephemeral = true;
      autoStart = false;
      privateNetwork = true;
      hostAddress = "192.168.100.1";
      localAddress = "192.168.100.4";
      config = ./changedetection.nix;
      bindMounts = {
        "/var/lib/changedetection-io" = {
          hostPath = "/services/changedetection";
          isReadOnly = false;
        };
      };
    };

    vaultwarden = {
      ephemeral = true;
      autoStart = true;
      config = ./vaultwarden.nix;
      bindMounts = {
        "/var/lib/bitwarden_rs" = {
          hostPath = "/services/vaultwarden/vaultwarden";
          isReadOnly = false;
        };
        "/var/backup/vaultwarden" = {
          hostPath = "/storage/vaultwarden_backup";
          isReadOnly = false;
        };
        "/var/lib/vaultwarden.env" = {
          hostPath = "/services/vaultwarden/config";
          isReadOnly = true;
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
        extraOptions = [ "--network=container_net" "--ip=10.111.111.2" ];
        autoStart = false;
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
    };
  };
}
