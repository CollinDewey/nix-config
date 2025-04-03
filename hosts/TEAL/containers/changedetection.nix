{ lib, ... }:
{
  services.changedetection-io = {
    enable = true;
    behindProxy = true;
    listenAddress = "0.0.0.0";
    baseURL = "https://changedetection.terascripting.com";
  };

  networking = {
    firewall.allowedTCPPorts = [ 5000 ];
    useHostResolvConf = lib.mkForce false;
  };
  services.resolved.enable = true;

  system.stateVersion = "24.11";
}
