{ config, ... }:
{
  # Audio with Pipewire
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    layout = "us";
    #xkbVariant = "colemak";
    displayManager.sddm.enable = true;
    desktopManager.plasma5.enable = true;
  };
  
  # Enable the Plasma 5 Desktop Environment.
  hardware.opengl.driSupport32Bit = true;
  hardware.opengl.enable = true;
}