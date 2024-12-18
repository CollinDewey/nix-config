{ ... }:
{
  programs.git.enable = true;
  programs.home-manager.enable = true;
  home.sessionVariables.NIXPKGS_ALLOW_UNFREE = "1";

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
    ./utilities.nix
    ./zsh.nix
  ];
}
