{ lib
, appimageTools
, fetchurl
, fuse3
, makeWrapper
}:

# WARNING: This package is a fucking hack!  Two things:
#
# - You must manually patch the Dolphin emulator installed by Slippi.  After
#   Dolphin is installed (i.e. once the 'play' button is clickable), you must
#   navigate to ~/.cache/appimage-run/*/apprun-hooks/linux-env.sh and
#   delete/comment the lines modifying LD_LIBRARY_PATH.  I hope to fix this at
#   some point, but it took me like 15 hours just to attain this bare minimum
#   functionality, rofl.  Good luck.  Open an issue or contact me (msyds) if you
#   need assistance.
#
# - Requires
#     programs.appimage = {
#       enable = true;
#       binfmt = true;
#     };
#   in your NixOS config.  This is because Slippi tries to run the Dolphin
#   AppImage like a normal executable.

appimageTools.wrapType2 rec {
  pname = "slippi-launcher";
  version = "2.11.10";

  src = fetchurl {
    url = "https://github.com/project-slippi/slippi-launcher/releases/download/v${version}/Slippi-Launcher-${version}-x86_64.AppImage";
    hash = "sha256-OrWd0jVqe6CzNbVRNlm2alt2NZ8uBYeHiASaB74ouW4=";
  };

  nativeBuildInputs = [
    makeWrapper
  ];

  extraPkgs = pkgs: [
    pkgs.fuse3
  ];

  extraInstallCommands = ''
    wrapProgram $out/bin/slippi-launcher \
      --set FUSERMOUNT_PROG "${fuse3}/bin/fusermount3" \
      --add-flags "''${NIXOS_OZONE_WL:+''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true}}"
  '';

  # note to madddy./.. DELETE "ubuntu is stupid" LINE FROM ~/.cache/appimage-run/XXXXX/shell-hooks/a
  meta = {
    description = "The way to play Slippi Online and watch replays.";
    homepage = "https://github.com/project-slippi/slippi-launcher";
    downloadPage = "https://github.com/project-slippi/slippi-launcher/releases";
    license = lib.licenses.gpl3;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
  };
}
