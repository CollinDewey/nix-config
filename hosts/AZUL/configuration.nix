{ config, pkgs, ... }:
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
            "FE80::/10"
            "::1/128"
          ];
        };
      };
    };

    mainsail.enable = true;
    nginx.clientMaxBodySize = "1000m";
  };

  # State
  system.stateVersion = "24.05";
}
