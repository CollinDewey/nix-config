{ config, lib, pkgs, inputs, ... }:
{
  services.openssh.settings.PasswordAuthentication = lib.mkForce true;
  imports = with inputs; [
    nix-index-database.nixosModules.nix-index  
  ];
  programs.nix-index-database.comma.enable = true;
  programs.command-not-found.enable = false;
  boot.swraid.mdadmConf = "MAILADDR root";
  hardware.bluetooth.enable = true;
  networking.networkmanager.enable = true;
  networking.wireless.enable = false;
  services.xserver.videoDrivers = [
    "amdgpu"
    "radeon"
    "nvidia"
    "nouveau"
    "modesetting"
    "fbdev"
  ];
  hardware.nvidia.open = false;
}