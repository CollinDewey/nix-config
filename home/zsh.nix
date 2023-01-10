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
        {
          name = "agnoster-nix";
          file = "agnoster-nix.zsh-theme";
          src = pkgs.fetchgit {
            url = "https://gist.github.com/chisui/0d12bd51a5fd8e6bb52e6e6a43d31d5e";
            rev = "a97b74ce17c5f1befabe266ccf02a972cab2911b";
            sha256 = "sha256-0IFeRc56HvQVNe37+qGvzK+nUrRkf4i/tYLef3NS/7M=";
          };
        }
      ];
      history = {
        extended = true; # Timestamps
        size = 1000000; # History loaded in RAM
        save = 1000000; # History saved to file
      };
    };
  };
}
