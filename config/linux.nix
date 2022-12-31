{
  # Secret configuration
  sops = {
    defaultSopsFile = ../secrets/secrets.yaml;
    age.generateKey = false;
    gnupg.sshKeyPaths = []; # sops-nix#167
    age.sshKeyPaths = []; # sops-nix#167
  };
  
  # Sudo tsk tsk... I AM THE SYSTEM ADMINISTRATOR
  security.sudo.extraConfig = ''
    Defaults lecture = never
  '';
  
  # TTY
  i18n.defaultLocale = "en_US.UTF-8";
  console.font = "Lat2-Terminus16";
}