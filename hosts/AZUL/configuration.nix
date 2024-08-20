{ config, pkgs, ... }:
let
  camera-dev = "/dev/v4l/by-id/usb-046d_0994_9CDF88E2-video-index0";
  camera-mover = pkgs.writeTextFile {
    name = "camera-mover.py";
    text = ''
    import json
    import requests
    import os
    from time import sleep

    camera_base = -768
    step_size = 128
    multiplier = 5

    cam_z = 0
    ready = False
    homed = False
    while True:
      if not homed and not ready:
        # Set camera to base position
        os.system('${pkgs.v4l-utils}/bin/v4l2-ctl -d ${camera-dev} --set-ctrl=tilt_reset=true')
        sleep(1.6)
        os.system(f"${pkgs.v4l-utils}/bin/v4l2-ctl -d ${camera-dev} --set-ctrl=tilt_relative={-camera_base}")
        sleep(0.8)
        cam_z = 0
        homed = True
      if ready:
        actual_z = int(requests.get(url="http://localhost:7125/printer/objects/query?toolhead").json()['result']['status']['toolhead']['position'][2])
        aligned_z = int((actual_z * multiplier) / step_size)
        #print(f"Actual {actual_z}, Aligned {aligned_z}, Cam {cam_z}")
        if (cam_z != aligned_z):
          homed = False
          if (cam_z - aligned_z) > 0:
            move = 1
          else:
            move = -1
          os.system(f"${pkgs.v4l-utils}/bin/v4l2-ctl -d ${camera-dev} --set-ctrl=tilt_relative={move*step_size}")
          cam_z = cam_z - move
      ready = requests.get(url="http://localhost:7125/printer/objects/query?toolhead").json()['result']['status']['toolhead']['homed_axes'] == "xyz" and int(requests.get(url="http://localhost:7125/printer/objects/query?toolhead").json()['result']['status']['toolhead']['position'][2]) <= 250
      sleep(0.6)
    '';
  };
  python = (pkgs.python3.withPackages (python-pkgs: [ python-pkgs.requests ]));
in
{
  users.users.klipper.uid = 433;
  users.groups.klipper.gid = 433;
  users.users.klipper.group = "klipper";

  services = {
    klipper = {
      enable = true;
      user = "klipper";
      group = "klipper";

      configFile = pkgs.writeText "klipper.cfg" ''
        [include ${config.services.moonraker.stateDir}/config/mainsail.cfg]
        [include ${config.services.moonraker.stateDir}/config/timelapse.cfg]
        [include ${config.services.moonraker.stateDir}/config/macros.cfg]
        [include ${config.services.moonraker.stateDir}/config/lis.cfg]
        [include ${config.services.moonraker.stateDir}/config/printer.cfg]
        [virtual_sdcard]
          path:${config.services.moonraker.stateDir}/gcodes
      '';

      firmwares = {
        skr = {
          enable = true;
          enableKlipperFlash = true;
          configFile = ./skr.cfg;
          serial = "/dev/serial/by-id/usb-Klipper_stm32g0b1xx_1F0026001150415833323520-if00";
        };

        pico = {
          enable = true;
          enableKlipperFlash = true;
          configFile = ./pico.cfg;
          serial = "/dev/serial/by-id/usb-Klipper_rp2040_4547415053881A8A-if00";
        };
      };
    };

    moonraker = {
      enable = true;
      address = "0.0.0.0";
      user = "klipper";
      group = "klipper";
      allowSystemControl = true;
      settings = {
        file_manager.enable_object_processing = true;
        history = { };
        octoprint_compat = { };
        authorization = {
          cors_domains = [
            "https://klipper.terascripting.com"
          ];
          trusted_clients = [
            "127.0.0.0/8"
            "172.16.0.0/12"
            "2600:1700:7790:4bc0::/60"
            "fd48:fc57:49eb:3bc0::/60"
            "FE80::/10"
            "::1/128"
          ];
        };
        timelapse = {
          output_path = "${config.services.moonraker.stateDir}/timelapse/";
          ffmpeg_binary_path = "${pkgs.ffmpeg}/bin/ffmpeg";
          camera = "webcam";
        };
      };
    };

    mainsail.enable = true;
    nginx.clientMaxBodySize = "1000m";
  };

  systemd.services = {
      ustreamer = {
        wantedBy = [ "multi-user.target" ];
        after = [ "camera-mover.service" ];
        description = "Starts ustreamer";
        serviceConfig = {
          Type = "exec";
          User = "collin";
          Group = "video";
          ExecStart = ''${pkgs.ustreamer}/bin/ustreamer -d ${camera-dev} -r 960x720 --host=0.0.0.0 -n -m MJPEG -l -f 30'';
          Restart = "always";
          RestartSec = "5s";
        };
      };
      
      camera-mover = {
        wantedBy = [ "multi-user.target" ];
        description = "Moves camera along with 3D Printer";
        serviceConfig = {
          Type = "exec";
          User = "collin";
          Group = "video";
          ExecStart = ''${python}/bin/python3 ${camera-mover}'';
          Restart = "always";
          RestartSec = "5s";
        };
      };
   };

  # Syncthing
  services.syncthing = {
    enable = true;
    user = "collin";
  };

  # Autologin
  services.displayManager.autoLogin = {
    enable = true;
    user = "collin";
  };

  # State
  system.stateVersion = "24.05";
}
