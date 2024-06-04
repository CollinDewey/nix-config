{ pkgs, lib, config, ... }:

with lib;
let cfg = config.modules.sanity;

in {
  options.modules.sanity = { enable = mkEnableOption "sanity"; };
  config = mkIf cfg.enable {
    programs.nix-ld = {
      enable = true;
      libraries = (pkgs.steam-run.fhsenv.args.multiPkgs pkgs) ++ (with pkgs; [
        ncurses5
      ]);
    };
    programs.appimage = {
      enable = true;
      binfmt = true;
    };
  };
}
