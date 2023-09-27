{ config, lib, pkgs, ... }:
{
  services.openssh.settings.PasswordAuthentication = lib.mkForce true;
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