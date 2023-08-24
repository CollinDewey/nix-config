{ ... }:
{
  services = {
    netdata.enable = true;
    ntopng = {
      enable = true;
      interfaces = [ "eth0" ];
      extraConfig = ''
        --disable-login 1
        --local-networks 172.16.0.0/24=Main,172.16.1.0/24=IoT
      '';
    };
    navidrome = {
      enable = true;
      settings = {
        Address = "0.0.0.0";
        MusicFolder = "/mnt/Seagate3TB/Music";
      };
    };
    jmusicbot.enable = true;
    nfs.server = {
      enable = true;
      exports = ''
      /               172.16.0.150(rw,fsid=0,no_subtree_check)
      /mnt/Seagate3TB 172.16.0.150(rw,nohide,insecure,no_subtree_check)
      '';
    };
  };
}