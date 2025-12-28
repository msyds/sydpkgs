{ stdenvNoCC
, texlive
}:

stdenvNoCC.mkDerivation (final: {
  pname = "syd-plex-latex";
  version = "1.0.0";
  src = ./.;
  nativeBuildInputs = [ texlive.combined.scheme-small ];
  passthru = {
    pkgs = [ final.finalPackage ];
    tlDeps = with texlive; [
      plex
      plex-otf
      fontaxes
      unicode-math
      xetex
      fontspec
      xlxtra
      realscripts
    ];
    tlType = "run";
  };
  installPhase = ''
    runHook preInstall
    dir="$out/tex/latex/syd-plex"
    mkdir -p "$dir"
    mv syd-plex.sty "$dir"
    runHook postInstall
  '';
})
