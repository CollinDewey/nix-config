{ lib, config, ... }: # Mostly stolen from nix-community/srvos

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

    # No Fonts.
    fonts.fontconfig.enable = lib.mkDefault false;

    # No XDG
    xdg.autostart.enable = mkDefault false;
    xdg.icons.enable = mkDefault false;
    xdg.mime.enable = mkDefault false;
    xdg.sounds.enable = mkDefault false;

    # Print the URL instead on servers
    environment.variables.BROWSER = "echo";

    # irqbalance can have performance consequences. Use for servers and not desktops.
    services.irqbalance.enable = true;

    # Watchdog
    systemd.settings.Manager = {
      RuntimeWatchdogSec = "60s";
      RebootWatchdogSec = "240s";
    };
  };
}


