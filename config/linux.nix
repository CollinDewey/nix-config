{ lib, inputs, ... }:
{
  # Modules
  imports = [ inputs.sops-nix.nixosModules.sops ];

  # Secret configuration
  sops = {
    defaultSopsFile = lib.mkDefault ../secrets/secrets.yaml;
    age.generateKey = false;
    gnupg.sshKeyPaths = [ ]; # sops-nix#167
    age.sshKeyPaths = [ ]; # sops-nix#167
  };

  # Sudo tsk tsk... I AM THE SYSTEM ADMINISTRATOR
  security.sudo.extraConfig = ''
    Defaults lecture = never
  '';

  # TTY
  i18n.defaultLocale = "en_US.UTF-8";
  console.font = "Lat2-Terminus16";

  # Faster booting
  systemd = {
    targets.network-online.wantedBy = lib.mkForce [ ];
    services.NetworkManager-wait-online.wantedBy = lib.mkForce [ ];
  };
}
