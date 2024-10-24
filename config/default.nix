{ pkgs, lib, config, inputs, ... }:

{
  # Nix
  nix = {
    settings = {
      experimental-features = "nix-command flakes";
      auto-optimise-store = true;
      trusted-users = [ "@wheel" ];
      substituters = [
        "https://nix-community.cachix.org"
        "https://cuda-maintainers.cachix.org"
      ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
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
    aria2
    htop
    git
    ncdu
    fastfetch
    arp-scan
    killall
    tmux
    eza
    fzf
    zoxide
  ] ++ lib.optionals (!pkgs.stdenv.isDarwin) (with pkgs; [
    iotop
  ]);

}
