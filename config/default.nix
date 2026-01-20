{ pkgs, lib, config, inputs, ... }:

{
  # Nix
  nix = {
    optimise.automatic = true;
    settings = {
      experimental-features = "nix-command flakes";
      trusted-users = [ "@wheel" ];
      substituters = [ "https://cache.nixos-cuda.org" ];
      trusted-public-keys = [ "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M=" ];
      extra-substituters = [ "https://pwndbg.cachix.org" ];
      extra-trusted-public-keys = [ "pwndbg.cachix.org-1:HhtIpP7j73SnuzLgobqqa8LVTng5Qi36sQtNt79cD3k=" ];
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
    dua
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
