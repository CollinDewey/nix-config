{ pkgs, lib, config, ... }:

with lib;
let cfg = config.modules.ssh;

in {
  options.modules.ssh = { enable = mkEnableOption "ssh"; };
  config = mkIf cfg.enable {
    services.openssh.enable = true;
    services.openssh.settings = {
      PermitRootLogin = lib.mkForce "no";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };
}
