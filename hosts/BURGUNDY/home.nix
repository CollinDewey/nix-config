{ pkgs, config,  ... }:
{
  programs.git = {
    signing.signByDefault = true;
    signing.key = "F5B2AFFCB4386C88";
  };
  home.packages = [
    pkgs.looking-glass-client
    pkgs.distrobox
  ];
  home.file.".config/autostart/zenbook-keyboard.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Name=Zenbook Second Display Disable
    Exec=/home/${ config.home.username }/.config/autostart/zenbook-keyboard.sh
    X-KDE-autostart-condition=ksmserver
  '';
  home.file.".config/autostart/zenbook-keyboard.sh" = {
    executable = true;
    text = ''
      #${pkgs.bash}/bin/bash
      if ${pkgs.usbutils}/bin/lsusb | grep -q "0b05:1b2c"; then
        ${pkgs.kdePackages.libkscreen}/bin/kscreen-doctor output.eDP-2.disable
      else
        ${pkgs.kdePackages.libkscreen}/bin/kscreen-doctor output.eDP-2.enable output.eDP-2.position.0,900
      fi
    '';
  };
  programs.plasma.kscreenlocker.appearance.wallpaperPlainColor = "0,0,0";
  programs.plasma.kscreenlocker.appearance.wallpaper = null;
}
