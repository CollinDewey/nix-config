{ pkgs, ...}:
{
  programs.git = {
    signing.signByDefault = true;
    signing.key = "21A02BCB3C3ABEDA";
  };
  home.packages = with pkgs; [
    looking-glass-client
    uxplay
    distrobox
  ];
}
