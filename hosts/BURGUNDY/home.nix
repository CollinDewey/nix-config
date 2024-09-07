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
    Exec=${pkgs.bash}/bin/bash /etc/zenbook/zenbook-keyboard.sh
    X-KDE-autostart-condition=ksmserver
  '';
  programs.plasma.kscreenlocker.appearance.wallpaperPlainColor = "0,0,0";
  programs.plasma.kscreenlocker.appearance.wallpaper = null;
}
