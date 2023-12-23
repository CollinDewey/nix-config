{ config, lib, pkgs, inputs, ... }:
{
  services.openssh.settings.PasswordAuthentication = lib.mkForce true;
  imports = with inputs; [
    nix-index-database.nixosModules.nix-index  
    kde2nix.nixosModules.plasma6
  ];
  programs.nix-index-database.comma.enable = true;
  programs.command-not-found.enable = false;
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