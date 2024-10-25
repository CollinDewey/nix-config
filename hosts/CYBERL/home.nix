
{ pkgs, ... }:
let
  agnoster-nix = pkgs.fetchgit {
    url = "https://gist.github.com/CollinDewey/2e6b6c5b257d2f6895603ddb160e6f1d";
    rev = "804f5d1bd9cb37c18cba252ff4eebf62dadc5c7f";
    sha256 = "sha256-iwFVyG3Np+vLJMhbW8b00mnCXSMY+f69lUGzl8rqfhU=";
  };
in
{
  nixpkgs.config.allowUnfree = true;

  # Copied straight from modules/zsh.nix, 
  # the reason for duplication is because I don't want to duplicate the configuration for all of Home-Manager, 
  # only on this PC, since this is the only PC using Home-Manager without nix-darwin or NixOS.
  programs.zsh.initExtra = ''
    source "${pkgs.zsh-defer}/share/zsh-defer/zsh-defer.plugin.zsh"
    zsh-defer source "${pkgs.zsh-nix-shell}/share/zsh-nix-shell/nix-shell.plugin.zsh";
    zsh-defer source "${pkgs.zsh-fast-syntax-highlighting}/share/zsh/site-functions/fast-syntax-highlighting.plugin.zsh";
    zsh-defer source "${pkgs.oh-my-zsh}/share/oh-my-zsh/plugins/sudo/sudo.plugin.zsh";
    zsh-defer source "${pkgs.zsh-history-substring-search}/share/zsh-history-substring-search/zsh-history-substring-search.zsh"
    eval "$(${pkgs.zoxide}/bin/zoxide init zsh)"
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
    alias cd="z"; # Using an alias instead of "zoxide init zsh --cmd cd", so I can easily unalias
    alias cdi="zi";
    alias ls="eza --icons"
    alias ll="eza -l"
    alias update,=\"mkdir -p ~/.cache/nix-index; download https://github.com/Mic92/nix-index-database/releases/latest/download/index-x86_64-linux ~/.cache/nix-index/files; chown -R \"$UID\" ~/.cache/nix-index\"
    alias ,="${pkgs.comma}/bin/comma"
    source "${agnoster-nix}"/agnoster-nix.zsh-theme;
  '';
  programs.home-manager.enable = true;
}
