{ pkgs, lib, config, ... }:

with lib;
let cfg = config.modules.multimedia;

in {
  options.modules.multimedia = { enable = mkEnableOption "multimedia"; };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      krita
      mpv
      (pkgs.obs-studio.override { cudaSupport = true; })
      #kdePackages.kdenlive
      audacity
      ffmpeg-full
      yt-dlp
    ];
  };
}
