{ pkgs, lib, config, ...}:

with lib;
let
  cfg = config.modules.zsh;
  agnoster-nix = pkgs.fetchgit {
    url = "https://gist.github.com/LegitMagic/2e6b6c5b257d2f6895603ddb160e6f1d";
    rev = "18a3df5e62a3caa2854bc82ee466590bf41e3341";
    sha256 = "sha256-lCNPjLmrE1WF1S34y5cPUTOp4G7bd7oZ80vZKZRV92U=";
  };
in {
  options.modules.zsh = { enable = mkEnableOption "zsh"; };
  config = mkIf cfg.enable {
    programs.zsh = {
      enable = true;
      interactiveShellInit = ''
        source "${pkgs.zsh-nix-shell}/share/zsh-nix-shell/nix-shell.plugin.zsh";
        source "${pkgs.zsh-fast-syntax-highlighting}/share/zsh/site-functions/fast-syntax-highlighting.plugin.zsh";
        source "${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh";
        source "${pkgs.oh-my-zsh}/share/oh-my-zsh/plugins/sudo/sudo.plugin.zsh";
        source "${pkgs.zsh-history-substring-search}/share/zsh-history-substring-search/zsh-history-substring-search.zsh"
        bindkey '^[[A' history-substring-search-up
        bindkey '^[[B' history-substring-search-down
        alias gcl="git clone --recursive"; # programs.zsh.shellAliases missing from nix-darwin
      '';
      promptInit = ''
        source "${agnoster-nix}"/agnoster-nix.zsh-theme;
      '';
    };
  };
}