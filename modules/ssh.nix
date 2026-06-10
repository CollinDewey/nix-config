{ lib, config, ... }:

with lib;
let
  cfg = config.modules.ssh;
  keys = ../authorized_keys;
in
{
  options.modules.ssh = { enable = mkEnableOption "ssh"; };
  config = mkIf cfg.enable {
    # initrd SSH
    boot.initrd.network = {
      enable = true;
      ssh = {
        enable = true;
        authorizedKeyFiles = [ keys ];
        ignoreEmptyHostKeys = true;
      };
    };

    # Userland OpenSSH
    services.openssh.enable = true;
    services.openssh.settings = {
      PermitRootLogin = lib.mkForce "no";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      LogLevel = "VERBOSE";
    };
    systemd.services.sshd.serviceConfig.StartLimitIntervalSec = 0;
    services.fail2ban = {
      enable = true;
      bantime-increment.enable = true;
      ignoreIP = [
        "172.16.0.0/12"
        "108.211.36.57/32"
      ];
    };
  };
}
