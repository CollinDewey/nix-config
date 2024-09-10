{ pkgs, ... }:
{
  # udev rules
  services.udev.packages = [
    pkgs.logitech-udev-rules
    pkgs.teensy-udev-rules
    pkgs.android-udev-rules
  ];

  # Programs
  programs.steam.enable = true;
  programs.gamemode.enable = true;
  chaotic.steam.extraCompatPackages = with pkgs; [ proton-ge-custom ];
  programs.dconf.enable = true; # Virt-manager keep config
  programs.kdeconnect.enable = true;

  # Syncthing
  services.syncthing = {
    enable = true;
    user = "collin";
  };

  # Virtual Keyboard
  environment.systemPackages = with pkgs; [
    maliit-keyboard
    maliit-framework
  ];

  # Cross compilation
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  # NFS
  services.nfs.server.enable = true;

  # Noisetorch
  programs.noisetorch.enable = true;

  # State
  system.stateVersion = "24.11";
}
