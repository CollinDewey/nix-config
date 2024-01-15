{ pkgs, lib, config, inputs, ... }:

{
  # Nix
  nix = {
    settings = {
      experimental-features = "nix-command flakes";
      auto-optimise-store = true;
      substituters = [
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };
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
