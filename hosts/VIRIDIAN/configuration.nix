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
    jirafeau = {
      enable = true;
      dataDir = "/mnt/Seagate3TB/jirafeau";
      extraConfig = ''
        $cfg['web_root'] = 'https://jirafeau.terascripting.com/';
        $cfg['organisation'] = 'Terascripting';
      '';
      nginxConfig.listen = [
        {
          addr = "0.0.0.0";
          port = 22393;
        }
      ];
    };
  };
}