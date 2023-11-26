{ config, lib, pkgs, ... }:
{
  services.openssh.settings.PasswordAuthentication = lib.mkForce true;
  boot.swraid.mdadmConf = "MAILADDR root";
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