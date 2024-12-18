{ ... }:
{
  nixpkgs.overlays = [
    (self: super: {
      ryujinx = super.ryujinx.overrideAttrs (old: {
        version = "1.1.1330";
        src = super.fetchFromGitHub {
          owner = "Ryujinx";
          repo = "Ryujinx";
          rev = "c0f2491eaee7eb1088605f5bda8055b941a14f99";
          sha256 = "sha256-WyxfvvE9y+9vWLcw7CMAGV+mbfYGO803o9n1Hh+bz0A=";
        };
      });
    })
  ];
}
