{ pkgs, lib, config, ... }:

with lib;
let cfg = config.modules.sanity;

in {
  options.modules.sanity = { enable = mkEnableOption "sanity"; };
  config = mkIf cfg.enable {
    programs.nix-ld = {
      enable = true;
      libraries = (pkgs.steam-run.args.multiPkgs pkgs) ++ (with pkgs; [
        ncurses5
        kdePackages.qtbase
        libsForQt5.qt5.qtbase
      ]);
    };
    programs.appimage = {
      enable = true;
      binfmt = true;
    };
    services.envfs.enable = true;
  };
}
