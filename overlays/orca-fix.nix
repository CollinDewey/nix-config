{ config, pkgs, lib, fetchFromGitHub, ... }:
{
  nixpkgs.overlays = [
    (
      self: super:
        {
          bambu-studio = super.bambu-studio.overrideAttrs (old: {
            version = "2.0.0-beta";
            pname = "orca-slicer";
          
            patches = [
              ./0001-not-for-upstream-CMakeLists-Link-against-webkit2gtk-.patch
            ];
          
            src = fetchFromGitHub {
              owner = "SoftFever";
              repo = "OrcaSlicer";
              rev = "v2.0.0-beta";
              hash = "sha256-P9sN9gqUyGKA5DHGyPRyqkV+ZmQbRPto21zvLYHOz+M=";
            };
          
            meta = with lib; {
              description = "G-code generator for 3D printers (Bambu, Prusa, Voron, VzBot, RatRig, Creality, etc";
              homepage = "https://github.com/SoftFever/OrcaSlicer";
              license = licenses.agpl3Only;
              maintainers = with maintainers; [ zhaofengli ovlach pinpox ];
              mainProgram = "orca-slicer";
              platforms = platforms.linux;
            };
          });
        }
    )
  ];
}


# Original stolen from Github

#{ lib, fetchFromGitHub, makeDesktopItem, bambu-studio }:
#
#bambu-studio.overrideAttrs (finalAttrs: previousAttrs: {
#  version = "2.0.0-beta";
#  pname = "orca-slicer";
#
#  # Don't inherit patches from bambu-studio
#  patches = [
#    ./0001-not-for-upstream-CMakeLists-Link-against-webkit2gtk-.patch
#  ];
#
#  src = fetchFromGitHub {
#    owner = "SoftFever";
#    repo = "OrcaSlicer";
#    rev = "v${finalAttrs.version}";
#    hash = "sha256-P9sN9gqUyGKA5DHGyPRyqkV+ZmQbRPto21zvLYHOz+M=";
#  };
#
#  meta = with lib; {
#    description = "G-code generator for 3D printers (Bambu, Prusa, Voron, VzBot, RatRig, Creality, etc";
#    homepage = "https://github.com/SoftFever/OrcaSlicer";
#    license = licenses.agpl3Only;
#    maintainers = with maintainers; [ zhaofengli ovlach pinpox ];
#    mainProgram = "orca-slicer";
#    platforms = platforms.linux;
#  };
#})