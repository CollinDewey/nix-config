{ pkgs, lib, ... }:

# See nix-community/home-manager#414
lib.mkMerge [
  {
    # Nix
    nix = {
      settings.experimental-features = "nix-command flakes";
      settings.auto-optimise-store = true;
      gc.automatic = true;
      gc.options = "--delete-older-than 30d";
    };

    # "Basic" Packages
    environment.systemPackages = with pkgs; [
      nano
      wget
      curl
      aria
      htop
      iotop
      git
      ncdu
      neofetch
      arp-scan
      killall
      sshfs
      tmux
      comma
    ] ++ lib.optionals (!pkgs.stdenv.isDarwin) (with pkgs; [ 
      iotop
    ]);
  }

  (lib.mkIf pkgs.stdenv.isLinux {
    # Secret configuration
    sops = {
      defaultSopsFile = ../secrets/secrets.yaml;
      age.generateKey = false;
      gnupg.sshKeyPaths = []; # sops-nix#167
      age.sshKeyPaths = []; # sops-nix#167
    };

    # Sudo tsk tsk... I AM THE SYSTEM ADMINISTRATOR
    security.sudo.extraConfig = ''
      Defaults lecture = never
    '';

    # TTY
    i18n.defaultLocale = "en_US.UTF-8";
    console.font = "Lat2-Terminus16";
  })

  #(lib.mkIf pkgs.stdenv.isDarwin {
  #  
  #})
]

