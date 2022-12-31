{ pkgs, ... }:
{
  # TEMPORARY
  homebrew.enable = true;
  homebrew.brews = [ "tiger-vnc" ];
  homebrew.casks = [ 
    "firefox"
    "google-chrome"
    "obsidian"
    "alacritty"
    "barrier"
    "discord"
    "bluebubbles"
    "macfuse"
    "macforge"
    "alt-tab"
    "appgrid"
  ];

  services.nix-daemon.enable = true;
  nix.package = pkgs.nix;

  # Read changelog before changing (darwin-rebuild changelog)
  system.stateVersion = 4;   
}