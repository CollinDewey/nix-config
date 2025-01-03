{ ... }:
{
  nixpkgs.overlays = [
    (self: super: {
      jmusicbot = super.jmusicbot.overrideAttrs (old: {
        version = "0.4.3.4";
        src = super.fetchurl {
          url = "https://github.com/SeVile/MusicBot/releases/download/0.4.3.4/JMusicBot-0.4.3.4.jar";
          sha256 = "sha256-+SCFAAChpDOpGbMe2oRR3Xw9BqlR3kIso2mia88M7nQ=";
        };
      });
    })
  ];
}
