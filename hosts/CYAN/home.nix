{ pkgs, ...}:
{
  programs.git = {
    signing.signByDefault = true;
    signing.key = "F5B2AFFCB4386C88";
  };
  home.packages = with pkgs; [
    looking-glass-client
    uxplay
    distrobox
    moonlight-qt
  ];
}
