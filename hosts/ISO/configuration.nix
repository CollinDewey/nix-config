{ config, lib, pkgs, ... }:
{
  hardware.bluetooth.enable = true;
  services.xserver.videoDrivers = [
    "amdgpu"
    "radeon"
    "nvidia"
    "nouveau"
    "modesetting"
    "fbdev"
  ];
}