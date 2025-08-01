{ pkgs, ... }:
{
  environment.shells = with pkgs; [
    bashInteractive
    zsh
  ];

  programs.zsh.enable = true;

  system.primaryUser = "collin";
  homebrew = {
    enable = true;
    onActivation.autoUpdate = true;
    onActivation.cleanup = "zap";
    brews = [
      "mpv"
      "aria2"
      "yt-dlp"
    ];
    casks = [
      "firefox"
      "google-chrome"
      "obsidian"
      "iterm2"
      "discord"
      "moonlight"
      "visual-studio-code"
      "imhex"
      "krita"
      "obs"
      "bitwarden"
      "utm"
    ];
    masApps = {
      Xcode = 497799835;
      #Testflight = 899247664;
      Wireguard = 1451685025;
    };
  };

  nix.package = pkgs.nix;

  # Read changelog before changing (darwin-rebuild changelog)
  system.stateVersion = 5;
}
