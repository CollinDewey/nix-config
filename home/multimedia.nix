{ pkgs, lib, config, ... }:

with lib;
let cfg = config.modules.multimedia;

in {
  options.modules.multimedia = { enable = mkEnableOption "multimedia"; };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      krita
      mpv
      obs-studio
      kdenlive
      clementine
      audacity
      ffmpeg-full
      yt-dlp
    ];
  };
}
