{ plasma-manager, ... }:
{
  programs.git.enable = true;
  programs.home-manager.enable = true;

  imports = [
    ./communication.nix
    ./cyber.nix
    ./gaming.nix
    ./lock.nix
    ./misc.nix
    ./multimedia.nix
    ./plasma.nix
    ./utilities.nix
  ];
}
