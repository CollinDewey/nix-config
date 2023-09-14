{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.zsh;
  agnoster-nix = pkgs.fetchgit {
    url = "https://gist.github.com/LegitMagic/2e6b6c5b257d2f6895603ddb160e6f1d";
    rev = "ac34ed17fcf5f18d93c6a9a6c9801b9a8699f271";
    sha256 = "sha256-0gdv/TOvsIpZz2rFzB2V90fJxXLGDQFx+FGwL1WpPTM=";
  };
  zsh-defer = pkgs.fetchFromGitHub {
    owner = "romkatv";
    repo = "zsh-defer";
    rev = "57a6650ff262f577278275ddf11139673e01e471";
    sha256 = "sha256-/rcIS2AbTyGw2HjsLPkHtt50c2CrtAFDnLuV5wsHcLc=";
  };
in
{
  options.modules.zsh = { enable = mkEnableOption "zsh"; };
  config = mkIf cfg.enable {
    programs.zsh = {
      enable = true;
      interactiveShellInit = ''
        source "${zsh-defer}/zsh-defer.plugin.zsh"
        zsh-defer source "${pkgs.zsh-nix-shell}/share/zsh-nix-shell/nix-shell.plugin.zsh";
        zsh-defer source "${pkgs.zsh-fast-syntax-highlighting}/share/zsh/site-functions/fast-syntax-highlighting.plugin.zsh";
        zsh-defer source "${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh";
        zsh-defer source "${pkgs.oh-my-zsh}/share/oh-my-zsh/plugins/sudo/sudo.plugin.zsh";
        zsh-defer source "${pkgs.zsh-history-substring-search}/share/zsh-history-substring-search/zsh-history-substring-search.zsh"
        bindkey "$terminfo[kcuu1]" history-substring-search-up
        bindkey "^[[A" history-substring-search-up
        bindkey "$terminfo[kcud1]" history-substring-search-down
        bindkey "^[[B" history-substring-search-down
        alias gcl="git clone --recursive"; # programs.zsh.shellAliases missing from nix-darwin
        alias aria="aria2c -x 16 -s 16 --file-allocation=none";
      '';
      promptInit = ''
        alias ls='[ -f .hidden ] && ls --color=tty $(sed 's/^/--hide=/' .hidden) $@'
        source "${agnoster-nix}"/agnoster-nix.zsh-theme;
      '';
    };
  };
}
