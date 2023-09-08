{ ... }:
{
  services = {
    netdata.enable = true;
    navidrome = {
      enable = true;
      settings = {
        Address = "0.0.0.0";
        #MusicFolder = "/mnt/Seagate3TB/Music";
      };
    };
    jmusicbot.enable = true;
    nfs.server = {
      enable = true;
      exports = ''
      /               172.16.0.150(rw,fsid=0,no_subtree_check)
      '';
    };
  };
}