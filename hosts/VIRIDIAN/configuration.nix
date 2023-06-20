{ ... }:
{
  services = {
    netdata.enable = true;
    ntopng = {
      enable = true;
      extraConfig = "--disable-login 1";
      interfaces = [ "eth0" ];
    };
  };
}