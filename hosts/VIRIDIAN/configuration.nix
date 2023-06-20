{ ... }:
{
  services = {
    netdata.enable = true;
    ntopng = {
      enable = true;
      extraConfig = "--disable-login 1";
      interfaces = [ "eth0" ];
    };
    navidrome = {
      enable = true;
      settings = {
        Address = "0.0.0.0";
        MusicFolder = "/mnt/Seagate3TB/Music";
      };
    };
    jmusicbot.enable = true;
  };
}