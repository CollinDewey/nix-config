{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.zsh;
  agnoster-nix = pkgs.fetchgit {
    url = "https://gist.github.com/CollinDewey/2e6b6c5b257d2f6895603ddb160e6f1d";
    rev = "804f5d1bd9cb37c18cba252ff4eebf62dadc5c7f";
    sha256 = "sha256-iwFVyG3Np+vLJMhbW8b00mnCXSMY+f69lUGzl8rqfhU=";
  };
in
{
  options.modules.zsh = { enable = mkEnableOption "zsh"; };
  config = mkIf cfg.enable {
    programs.zsh = {
      enable = true;
      interactiveShellInit = ''
        source "${pkgs.zsh-defer}/share/zsh-defer/zsh-defer.plugin.zsh"
        zsh-defer source "${pkgs.zsh-nix-shell}/share/zsh-nix-shell/nix-shell.plugin.zsh";
        zsh-defer source "${pkgs.zsh-fast-syntax-highlighting}/share/zsh/site-functions/fast-syntax-highlighting.plugin.zsh";
        zsh-defer source "${pkgs.oh-my-zsh}/share/oh-my-zsh/plugins/sudo/sudo.plugin.zsh";
        zsh-defer source "${pkgs.zsh-history-substring-search}/share/zsh-history-substring-search/zsh-history-substring-search.zsh"
        bindkey "$terminfo[kcuu1]" history-substring-search-up
        bindkey "^[[A" history-substring-search-up
        bindkey "$terminfo[kcud1]" history-substring-search-down
        bindkey "^[[B" history-substring-search-down
        alias gcl="git clone --recursive"; # programs.zsh.shellAliases missing from nix-darwin
        alias aria8="aria2c -x 8 -s 8 --file-allocation=none";
        alias aria="aria2c -x 16 -s 16 --file-allocation=none";
        alias aria32="aria2c -x 32 -s 32 --file-allocation=none";
        alias aria48="aria2c -x 48 -s 48 --file-allocation=none";
        alias aria64="aria2c -x 64 -s 64 --file-allocation=none";
      '';
      promptInit = ''
        alias ls="eza --icons"
        alias ll="eza -l"
        source "${agnoster-nix}"/agnoster-nix.zsh-theme;
      '';
    };
  };
}
