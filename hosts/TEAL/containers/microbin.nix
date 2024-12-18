{ ... }:
{
  services.microbin = {
    enable = true;
    settings = {
      # https://microbin.eu/docs/installation-and-configuration/configuration/
      MICROBIN_HIDE_LOGO = true;
      MICROBIN_NO_LISTING = true;
      MICROBIN_PRIVATE = false; # No listing effectively does this
      MICROBIN_PUBLIC_PATH = "https://microbin.terascripting.com/";
      MICROBIN_WIDE = true;
      MICROBIN_QR = true;
      MICROBIN_SHOW_READ_STATS = false;
      MICROBIN_DISABLE_UPDATE_CHECKING = true;
      MICROBIN_DISABLE_TELEMETRY = true;
      MICROBIN_MAX_FILE_SIZE_ENCRYPTED_MB = 65536; # Just hope we have enough RAM
      MICROBIN_MAX_FILE_SIZE_UNENCRYPTED_MB = 65536;
    };
  };

  networking.firewall.allowedTCPPorts = [ 8080 ];

  system.stateVersion = "23.11";
}
