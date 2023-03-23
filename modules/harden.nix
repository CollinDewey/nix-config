{ pkgs, lib, config, ... }:

with lib;
let cfg = config.modules.harden;

in {
  options.modules.harden = { enable = mkEnableOption "harden"; };
  config = mkIf cfg.enable {
    # Fail2Ban
    services.fail2ban = {
      enable = true;
      ignoreIP = [
        "127.0.0.0/8"
        "10.0.0.0/8"
        "172.16.0.0/12"
        "192.168.0.0/16"
        "108.211.36.57"
      ];
    };

    # Anti-Virus
    services.clamav = {
      daemon.enable = true;
      updater = {
        enable = true;
        interval = "weekly";
      };
    };
  };
}
