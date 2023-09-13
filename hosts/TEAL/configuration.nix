{ pkgs, ... }:
{
  services = {
    jellyfin.enable = true;
    netdata.enable = true;

    nfs.server = {
      enable = true;
      exports = ''
        /            10.133.133.2(rw,fsid=0,no_subtree_check)
        /libvirt 10.133.133.2(rw,nohide,insecure,no_subtree_check)
      '';
    };
  };
}
