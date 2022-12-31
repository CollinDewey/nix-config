{ pkgs, ... }:

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
  ]
}