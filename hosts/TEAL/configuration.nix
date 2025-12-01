{ pkgs, lib, ... }:
let
  nfs_opts_rw = "rw,nohide,insecure,no_subtree_check,no_root_squash,async";
  nfs_opts_ro = "ro,nohide,insecure,no_subtree_check,no_root_squash,async";
in
{

  imports = [ ./libvirt.nix ];

  # State
  system.stateVersion = "25.05";

  # VGPU
  hardware.nvidia.vgpu.fastapi-dls = {
    enable = true;
    dataDir = "/services/fastapi-dls";
    port = 53492;
  };

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

    nfs.server = {
      enable = true;
      exports = ''
        / 172.16.1.0/24(${nfs_opts_rw},crossmnt)
        /snapshots 172.16.1.0/24(${nfs_opts_ro})
        /services 172.16.1.0/24(${nfs_opts_rw})
        /cyber 172.16.1.0/24(${nfs_opts_rw})
        /storage 172.16.1.0/24(${nfs_opts_rw})
        /vm_storage 172.16.1.0/24(${nfs_opts_rw})
        /network_share/Global 172.16.0.0/12(${nfs_opts_rw}) 172.16.1.0/24(${nfs_opts_rw})
        /network_share/CMD 172.16.1.0/24(${nfs_opts_rw})
        /network_share/BLD 172.16.2.0/24(${nfs_opts_rw}) 172.16.1.0/24(${nfs_opts_rw})
        /network_share/CEV 172.16.3.0/24(${nfs_opts_rw}) 172.16.1.0/24(${nfs_opts_rw})
        /network_share/AMD 172.16.4.0/24(${nfs_opts_rw}) 172.16.1.0/24(${nfs_opts_rw})
      '';
    };
  };
}
