{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.gaming;
  lock = pkgs.writeShellApplication {
    name = "lock";
    runtimeInputs = [ pkgs.i3lock-color ];
    text = ''
      B='#00000000' # blank
      C='#ffffff00' # clearish
      D='#4f97d7ee' # default
      W='#f22272dd' # wrong
      
      i3lock-color \
      \
      --line-uses-inside \
      --inside-color=$B \
      --ring-color=$D \
      --separator-color=$W \
      \
      --keyhl-color=$W \
      --bshl-color=$W \
      \
      --blur 5 \
      --ignore-empty-password \
      --clock \
      --indicator \
      --noinput-text="" \
      \
      --time-color=$D \
      --time-str="%H %M" \
      --time-font="Iosevka SS01:bold" \
      --time-size=40 \
      --time-pos="ix:iy - 10" \
      \
      --date-color=$D \
      --date-str="%m %d" \
      --date-font="Iosevka SS01:bold" \
      --date-size=18 \
      --date-size=40 \
      --date-pos="ix:iy + 45" \
      \
      --verif-color=$D \
      --ringver-color=$D \
      --insidever-color=$C \
      --verif-text="Verifying" \
      --verif-font="Iosevka SS01:bold" \
      --verif-size=32 \
      --verif-pos="ix:iy + 15" \
      \
      --wrong-color=$W \
      --ringwrong-color=$W \
      --insidewrong-color=$C \
      --wrong-text="Incorrect" \
      --wrong-font="Iosevka SS01:bold" \
      --wrong-size=32 \
      --wrong-pos="ix:iy + 15"
    '';
  };
in
{
  options.modules.lock = { enable = mkEnableOption "lock"; };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      lock
    ];
  };
}
