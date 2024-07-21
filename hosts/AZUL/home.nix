{ pkgs, lib, ...}:
{
  home.packages = with pkgs; [
    obs-studio
    firefox
  ];

  # Due to *reasons*, we want Firefox to use xwayland, but since this machine is weak, native Wayland is better
  home.sessionVariables.MOZ_ENABLE_WAYLAND = lib.mkForce "1";
}
