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
  programs.steam.extraCompatPackages = with pkgs; [ proton-ge-custom proton-ge-rtsp-bin ];
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
  systemd.user.services.noisetorch = {
    enable = true;
    requires = [ "sys-devices-pci0000:00-0000:00:1f.3-skl_hda_dsp_generic-sound-card0-controlC0.device" ];
    after = [ "pipewire.service" "sys-devices-pci0000:00-0000:00:1f.3-skl_hda_dsp_generic-sound-card0-controlC0.device" ];
    wantedBy = [ "pipewire.service" ];
    description = "Noisetorch";
    serviceConfig = {
      Type = "simple";
      RemainAfterExit = "yes";
      ExecStart = "${pkgs.noisetorch}/bin/noisetorch -i -s alsa_input.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__Mic1__source -t 95";
      ExecStop = "${pkgs.noisetorch}/bin/noisetorch -u";
      Restart = "on-failure";
      RestartSec = "3";
    };
  };

  # State
  system.stateVersion = "24.11";
}
