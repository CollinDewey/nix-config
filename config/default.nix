{ pkgs, lib, config, inputs, ... }:

{
  # Nix
  nix = {
    settings.experimental-features = "nix-command flakes";
    settings.auto-optimise-store = true;
    registry = lib.mapAttrs (_: value: { flake = value; }) inputs;
    nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;
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

  # Wait for nixpkgs#213593 to be backported. I could've just used an overlay...
  nixpkgs.config.permittedInsecurePackages = [
    "electron-18.1.0"
  ];
}
