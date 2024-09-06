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

  # SDDM workaround for starting before drivers load
  systemd.services.display-manager.preStart = ''${pkgs.coreutils}/bin/sleep 1'';

  # Cross compilation
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  # NFS
  services.nfs.server.enable = true;

  # Testing if my audio issues are pipewire based
  services.pipewire.enable = pkgs.lib.mkForce false;
  hardware.pulseaudio.enable = true;
  hardware.pulseaudio.support32Bit = true;
  programs.noisetorch.enable = true;

  # State
  system.stateVersion = "24.11";
}
