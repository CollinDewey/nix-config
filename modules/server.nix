{ pkgs, lib, config, ... }: # Mostly stolen from nix-community/srvos

with lib;
let cfg = config.modules.server;

in {
  options.modules.server = { enable = mkEnableOption "server"; };
  config = mkIf cfg.enable {
    
    # Disable Documentation
    documentation.enable = lib.mkDefault false;
    documentation.info.enable = lib.mkDefault false;
    documentation.man.enable = lib.mkDefault false;
    documentation.nixos.enable = lib.mkDefault false;

    # No Fonts. No Sound
    fonts.fontconfig.enable = lib.mkDefault false;
    sound.enable = false;

    # Print the URL instead on servers
    environment.variables.BROWSER = "echo";

    # TCP BBR (Why not use this on all machines?)
    boot.kernel.sysctl = {
      "net.core.default_qdisc" = "fq";
      "net.ipv4.tcp_congestion_control" = "bbr";
    };

    # Degrade Nix builds
    systemd.services.nix-daemon.serviceConfig.OOMScoreAdjust = lib.mkDefault 250;
    nix.daemonCPUSchedPolicy = lib.mkDefault "batch";
    nix.daemonIOSchedClass = lib.mkDefault "idle";
    nix.daemonIOSchedPriority = lib.mkDefault 7;
    nix.settings.connect-timeout = 5;
  };
}


