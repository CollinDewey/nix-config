{ pkgs, ... }:
{
  environment.shells = with pkgs; [
    bashInteractive
    zsh
  ];

  programs.zsh.enable = true;

  homebrew = {
    enable = true;
    onActivation.autoUpdate = true;
    onActivation.cleanup = "zap";
    taps = [
      "LizardByte/homebrew"
      "homebrew/services"
    ];
    brews = [
      "mpv"
      "aria2"
      "yt-dlp"
      "lizardbyte/homebrew/sunshine-beta"
      "ollama"
    ];
    casks = [
      "firefox"
      "google-chrome"
      "obsidian"
      "iterm2"
      "discord"
      "bluebubbles"
      "moonlight"
      "steam"
      "visual-studio-code"
      "imhex"
      "krita"
      "obs"
      "bitwarden"
      "blackhole-2ch"
      "parsec"
      "utm"
    ];
    masApps = {
      Xcode = 497799835;
      Testflight = 899247664;
      Wireguard = 1451685025;
    };
  };

  services.nix-daemon.enable = true;
  nix.package = pkgs.nix;

  # Read changelog before changing (darwin-rebuild changelog)
  system.stateVersion = 4;
}
