{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.ssh;
  keys = builtins.fetchurl {
    url = "https://github.com/CollinDewey.keys";
    sha256 = "sha256:0f6j55wszsxg7kpwlf7p6av2mpkw3djpx35inqy8a97dh8hjyx7q";
  };
in {
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
    };

  };
}
