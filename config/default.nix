{ pkgs, lib, config, inputs, ... }:

{
  # Nix
  nix = {
    settings.experimental-features = "nix-command flakes";
    settings.auto-optimise-store = true;
    registry = lib.mapAttrs (_: value: { flake = value; }) inputs;
    nixPath = (lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry) ++ [ "nixpkgs=${inputs.nixpkgs-unstable}" ];
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
    eza
  ] ++ lib.optionals (!pkgs.stdenv.isDarwin) (with pkgs; [
    iotop
  ]);

}
