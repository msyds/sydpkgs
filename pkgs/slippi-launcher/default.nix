{ lib
, appimageTools
, fetchurl
, fuse
, bash
, breakpointHook
, makeWrapper
}:

appimageTools.wrapType2 rec {
  pname = "slippi-launcher";
  version = "2.11.10";

  src = fetchurl {
    url = "https://github.com/project-slippi/slippi-launcher/releases/download/v${version}/Slippi-Launcher-${version}-x86_64.AppImage";
    hash = "sha256-OrWd0jVqe6CzNbVRNlm2alt2NZ8uBYeHiASaB74ouW4=";
  };

  nativeBuildInputs = [
    breakpointHook
    makeWrapper
  ];

  extraPkgs = pkgs: [
    pkgs.fuse
    pkgs.bintools
    pkgs.patchelf
    ((pkgs.curl.override {
      opensslSupport = true;
      gnutlsSupport = false;
    }).overrideAttrs (final: prev: {
      meta.prio = lib.highPrio;
    }))
    pkgs.openssl
  ];

  extraInstallCommands = ''
    wrapProgram $out/bin/slippi-launcher \
      --set FUSERMOUNT_PROG "${fuse}/bin/fusermount"
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
