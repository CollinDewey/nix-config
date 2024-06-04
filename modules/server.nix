{ pkgs, lib, config, ... }: # Mostly stolen from nix-community/srvos

with lib;
let cfg = config.modules.server;

in {
  options.modules.server = { enable = mkEnableOption "server"; };
  config = mkIf cfg.enable {
    
    # Drop /lib/ld-linux.so.2 and /lib/ld-linux-x86-64.so.2 stub
    environment.stub-ld.enable = lib.mkDefault false;

    # Disable Documentation
    documentation.enable = lib.mkDefault false;
    documentation.info.enable = lib.mkDefault false;
    documentation.man.enable = lib.mkDefault false;
    documentation.nixos.enable = lib.mkDefault false;

    # No Fonts. No Sound
    fonts.fontconfig.enable = lib.mkDefault false;
    sound.enable = false;

    # No XDG
    xdg.autostart.enable = mkDefault false;
    xdg.icons.enable = mkDefault false;
    xdg.mime.enable = mkDefault false;
    xdg.sounds.enable = mkDefault false;

    # Print the URL instead on servers
    environment.variables.BROWSER = "echo";

    # Watchdog
    systemd.watchdog = {
      runtimeTime = "60s";
      rebootTime = "240s";
    };

    # TCP BBR (Why not use this on all machines?)
    boot.kernel.sysctl = {
      "net.core.default_qdisc" = "fq";
      "net.ipv4.tcp_congestion_control" = "bbr";
    };

    # Deprioritize Nix builds
    systemd.services.nix-daemon.serviceConfig.OOMScoreAdjust = lib.mkDefault 250;
    nix.daemonCPUSchedPolicy = lib.mkDefault "idle";
    nix.daemonIOSchedClass = lib.mkDefault "idle";
    nix.daemonIOSchedPriority = lib.mkDefault 7;
    nix.settings.connect-timeout = 5;
  };
}


