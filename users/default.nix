{ pkgs, config, ... }:
{
  users.users.root.shell = pkgs.zsh;
  users.users.root.hashedPasswordFile = config.sops.secrets.collin-hashed-password.path;
  sops.defaultSopsFile = ../secrets/collin.yaml;
  sops.secrets.collin-hashed-password.neededForUsers = true;
}
