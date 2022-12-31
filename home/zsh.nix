{ pkgs, lib, config, ...}:

with lib;
let cfg = config.modules.zsh;

in {
  options.modules.zsh = { enable = mkEnableOption "zsh"; };
  config = mkIf cfg.enable {
    programs.zsh = {
      enable = true;
      enableCompletion = pkgs.stdenv.isDarwin; # enableCompletion and enableSyntaxHighlighting are managed by the NixOS module
      enableSyntaxHighlighting = pkgs.stdenv.isDarwin;
      plugins = [
        {
          name = "zsh-nix-shell";
          file = "nix-shell.plugin.zsh";
          src = pkgs.fetchFromGitHub {
            owner = "chisui";
            repo = "zsh-nix-shell";
            rev = "v0.5.0";
            sha256 = "0za4aiwwrlawnia4f29msk822rj9bgcygw6a8a6iikiwzjjz0g91";
          };
        }
      ];
    };
  };
}
