{ pkgs, ... }:
{
  services = {
    duplicati = {
      enable = true;
      user = "collin";
    };

    jellyfin.enable = true;

    netdata.enable = true;

    nfs.server = {
      enable = true;
      exports = ''
        /            10.133.133.2(rw,fsid=0,no_subtree_check)
        /mnt/Shared  10.133.133.2(rw,nohide,insecure,no_subtree_check)
        /mnt/Storage 10.133.133.2(rw,nohide,insecure,no_subtree_check)
        /mnt/Other   10.133.133.2(rw,nohide,insecure,no_subtree_check)
      '';
    };
  };
  systemd.services.duplicati = {
    path = [ pkgs.rclone ];
  };
}
