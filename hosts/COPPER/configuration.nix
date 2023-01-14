{ pkgs, ... }:
{
  environment.shells = with pkgs; [
    bashInteractive
    zsh
  ];

  programs.zsh.enable = true;

  # TEMPORARY
  homebrew.enable = true;
  homebrew.onActivation.autoUpdate = true;
  homebrew.onActivation.cleanup = "zap";
  homebrew.brews = [ "tiger-vnc" ];
  homebrew.casks = [
    "firefox"
    "google-chrome"
    "obsidian"
    "iterm2"
    "barrier"
    "discord"
    "bluebubbles"
    "macfuse"
    "macforge"
    "alt-tab"
    "appgrid"
  ];
  homebrew.masApps = {
    Xcode = 497799835;
    Testflight = 899247664;
    Wireguard = 1451685025;
  };

  services.nix-daemon.enable = true;
  nix.package = pkgs.nix;

  # Read changelog before changing (darwin-rebuild changelog)
  system.stateVersion = 4;
}
