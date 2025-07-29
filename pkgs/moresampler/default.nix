{ wine
, stdenv
, makeWrapper
, lib
}:

stdenv.mkDerivation (final: {
  pname = "moresampler";
  version = "0.8.4";

  src = ./moresampler-${final.version}.tar.gz;

  nativeBuildInputs = [
    makeWrapper
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/opt/moresampler

    mv moresampler.exe moreconfig.txt $out/opt/moresampler/

    cat > $out/bin/moresampler << EOF
    #!/usr/bin/env bash
    LANG=ja_JP.UTF8 "${lib.getExe wine}" \
      "$out/opt/moresampler/moresampler.exe" "\''${@,-1}"
    EOF

    chmod +x $out/bin/moresampler

    runHook postInstall
  '';

  meta = {
    description = "Synthesis backend for singing voice synthesis program UTAU";
    longDescription = ''
      Moresampler is a synthesis backend for singing voice synthesis program
      UTAU. Literally the name suggests that Moresampler is not only a UTAU
      resampler. In fact, it is a resampler, a wavtool and an automatic
      voicebank configurator combined in one executable.
    '';
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };
})
