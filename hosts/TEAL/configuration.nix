{ pkgs, lib, ... }:
{

  # State
  system.stateVersion = "25.05";

  # RAID
  boot.swraid.mdadmConf = lib.mkDefault "MAILADDR root";

  # GUI
  services.seatd.enable = true;
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --sessions /etc/greetd -d --cmd zsh";
      };
    };
  };
  environment.etc = {
    "greetd/Moonlight.sh" = {
      mode = "0555";
      text = "${pkgs.gamescope}/bin/gamescope -O HDMI-A-1 -- ${pkgs.moonlight-qt}/bin/moonlight";
    };
    "greetd/Virt-Manager.sh" = {
      mode = "0555";
      text = "WLR_NO_HARDWARE_CURSORS=1 ${pkgs.labwc}/bin/labwc -s '${pkgs.virt-manager}/bin/virt-manager -c qemu:///system'";
    };
    "greetd/Looking-Glass.sh" = {
      mode = "0555";
      text = "${pkgs.gamescope}/bin/gamescope -O HDMI-A-1 -- ${pkgs.looking-glass-client}/bin/looking-glass-client -F -d";
    };
    "greetd/zsh.desktop".text = ''
      [Desktop Entry]
      Name=zsh
      Exec=zsh
    '';
    "greetd/Moonlight.desktop".text = ''
      [Desktop Entry]
      Name=Moonlight
      Exec=/etc/greetd/Moonlight.sh
    '';
    "greetd/Virt-Manager.desktop".text = ''
      [Desktop Entry]
      Name=Virt-Manager
      Exec=/etc/greetd/Virt-Manager.sh
    '';
    "greetd/Looking-Glass.desktop".text = ''
      [Desktop Entry]
      Name=Looking-Glass
      Exec=/etc/greetd/Looking-Glass.sh
    '';
  };

  systemd.services.novnc = {
    enable = true;
    description = "noVNC";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.procps ];

    serviceConfig = {
      ExecStart = "${lib.getExe pkgs.novnc} --vnc 172.16.1.80:5900";
      DynamicUser = true;
      Restart = "on-failure";
    };
  };

  # I need to talk to 172.31.0.0/24 to backup to Wireguard
  virtualisation.docker.daemon.settings.default-address-pools = [ { base = "10.192.0.0/12"; size = 24; } ];

  # Backup
  #services.restic.backups = {
  #  immich = {
  #    repository = "rclone:drobo:files/restic";
  #    paths = [ "/photos/Immich/library/" ];
  #    passwordFile = "/services/backup/restic-password";
  #    rcloneConfigFile = "/services/backup/rclone.conf";
  #    extraBackupArgs = [ "--no-cache" ];
  #
  #    pruneOpts = [
  #      "--keep-daily 3"
  #      "--keep-weekly 2"
  #      "--keep-monthly 2"
  #    ];
  #
  #    timerConfig = {
  #      OnCalendar = "daily";
  #      Persistent = true;
  #    };
  #  };
  #
  #  blue = {
  #    repository = "rclone:drobo:files/restic";
  #    paths = [ "/vm_storage/BLUE.raw" ];
  #    passwordFile = "/services/backup/restic-password";
  #    rcloneConfigFile = "/services/backup/rclone.conf";
  #    extraBackupArgs = [ "--no-cache" ];
  #
  #    pruneOpts = [
  #      "--keep-daily 3"
  #      "--keep-weekly 1"
  #      "--keep-monthly 6"
  #      "--keep-yearly 1"
  #    ];
  #
  #    timerConfig = {
  #      OnCalendar = "daily";
  #      Persistent = true;
  #    };
  #  };
  #};

  users.users.immich.extraGroups = [ "video" "render" ];
  services = {
    netdata.enable = true;

    traefik = {
      enable = true;
      group = "docker";
      dataDir = "/services/traefik/data/";
      staticConfigFile = "/services/traefik/traefik.toml";
      environmentFiles = [ "/services/traefik/traefik.env" ];
    };

    tor = {
      enable = true;
      relay.onionServices."blog" = {
        secretKey = "/services/tor/blog/hs_ed25519_secret_key";
        map = [ 80 ];
      };
    };

    postgresql.dataDir = "/photos/Immich/postgres"; # Surely I won't need to use postgresql for anything else
    immich = {
      enable = true;
      host = "0.0.0.0";
      mediaLocation = "/photos/Immich/library";
      accelerationDevices = [ "/dev/dri/renderD128" ];
    };

    copyparty = {
     enable = true;

      user = "collin";
      group = "collin";

      settings = {
        i = "0.0.0.0";
        theme = 2;
        xff-hdr = "x-forwarded-for";
        xff-src = "172.16.0.100";
        rproxy = 1;
      };
      

      accounts = {
        "collin".passwordFile = "/services/copyparty/collin_pass";
      };

      volumes = {
        "/" = {
          path = "/network_share/Global";
          access = {
            rwmd = "*";
            rwmda = "collin";
          };
          flags = {
            e2dsa = true;
            daw = true;
          };
        };
        "/collin" = {
          path = "/network_share/Collin";
          access = {
            rwmda = "collin";
          };
          flags = {
            e2dsa = true;
            daw = true;
          };
        };
      };
      openFilesLimit = 8192;
    };
  };

  networking.firewall = {
    enable = true;

    trustedInterfaces = [ "virbr0" "ve-changede2KnI" "ve-jellyfin" ];

    allowedTCPPorts = [
      22     # SSH
      80     # traefik
      443    # traefik
      631    # cups
      6080   # noVNC websocket
      6566   # cups
      8080   # Omada (portal + console)
      8043   # Omada (https console)
      8384   # syncthing GUI
      8843   # Omada (https portal)
      9098   # Omada (legacy web)
      19999  # netdata
      22000  # syncthing
    ];

    # 29810-29817 Omada
    allowedTCPPortRanges = [ { from = 29810; to = 29817; } ];

    allowedUDPPorts = [
      22000  # syncthing
    ];

    # 29810-29817 Omada
    allowedUDPPortRanges = [ { from = 29810; to = 29817; } ];
  };
}
