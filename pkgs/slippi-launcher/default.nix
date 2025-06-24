{ lib
, appimageTools
, fetchurl
, breakpointHook
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
  ];

  extraInstallCommands = ''
  '';

  meta = {
    description = "The way to play Slippi Online and watch replays.";
    homepage = "https://github.com/project-slippi/slippi-launcher";
    downloadPage = "https://github.com/project-slippi/slippi-launcher/releases";
    license = lib.licenses.gpl3;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
  };
}
