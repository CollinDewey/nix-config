{ config, pkgs, lib, ... }: let
  nix-alien-pkgs = import (builtins.fetchTarball "https://github.com/thiagokokada/nix-alien/archive/master.tar.gz") {};
in
{

  imports = [
    ./overlays.nix
    ./users.nix
    ./home.nix
    ./virtualization.nix
    ./desktop.nix
    ./burgundy.nix
  ];

  # Set your time zone.
  time.timeZone = "America/Louisville";

  # TTY
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    #keyMap = "colemak/colemak";
  };

  # Nixpkgs Unfree
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    nano
    wget
    curl
    aria
    htop
    iotop
    p7zip
    nettools
    neofetch
    arp-scan
    killall
    sshfs
    unrar
    rclone
    pinentry-curses
    tmux
    xdotool
    lm_sensors
    pciutils
    nix-alien-pkgs.nix-alien
    nix-alien-pkgs.nix-index-update
    nix-index
  ];

  # Make Stuff Pretty With Oh-My-ZSH
  users.defaultUserShell = pkgs.zsh;
  programs.zsh = {
    enable = true;
    syntaxHighlighting.enable = true;
    autosuggestions.enable = true;
    ohMyZsh = {
      enable = true;
      plugins = [ "git" "sudo" "docker" ];
      theme = "agnoster";
    };
  };

  programs.dconf.enable = true;

  # Nix Garbage Collection
  nix.gc.automatic = true;
  nix.gc.options = "--delete-older-than 30d";
  nix.settings.auto-optimise-store = true;

  # Flakes
  nix.package = pkgs.nixFlakes;
  nix.extraOptions = ''
      experimental-features = nix-command flakes
  '';

  # Nix Auto Update
  system.autoUpgrade.enable = true;



  #virtualisation.memorySize = 16384;
  #virtualisation.cores = 8;
}
