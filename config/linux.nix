{ lib, inputs, ... }:
{
  # Modules
  imports = with inputs; [
    sops-nix.nixosModules.sops
    nix-index-database.nixosModules.nix-index
  ];

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

  # Stuff that should be default, but isn't
  services = {
    smartd.enable = true;
    fstrim.enable = true;
  };

  # Sysctl Tuning
  boot.kernel.sysctl = {
    # Networking
    "net.core.default_qdisc" = "cake";
    "net.ipv4.tcp_congestion_control" = "bbr";
  };

  # Comma
  programs.nix-index-database.comma.enable = true;
  programs.command-not-found.enable = false;


  # Deprioritize Nix builds
  systemd.services.nix-daemon.serviceConfig.OOMScoreAdjust = lib.mkDefault 250;
  nix.daemonCPUSchedPolicy = lib.mkDefault "idle";
  nix.daemonIOSchedClass = lib.mkDefault "idle";
  nix.daemonIOSchedPriority = lib.mkDefault 7;
  nix.settings.connect-timeout = 5;
}
