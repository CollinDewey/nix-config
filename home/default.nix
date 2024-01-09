{ plasma-manager, ... }:
{
  programs.git.enable = true;
  programs.home-manager.enable = true;

  imports = [
    ./communication.nix
    ./cyber.nix
    ./gaming.nix
    ./klipper.nix
    ./lock.nix
    ./misc.nix
    ./multimedia.nix
    ./office.nix
    ./plasma.nix
    ./plover.nix
    ./unity.nix
    ./utilities.nix
    ./zsh.nix
  ];
}
