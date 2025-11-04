{
  services = {
    traefik = {
      enable = true;
      group = "docker";
      dataDir = "/mnt/Block/traefik/";
      staticConfigFile = "/mnt/Block/traefik/traefik.toml";
    };
  };
}