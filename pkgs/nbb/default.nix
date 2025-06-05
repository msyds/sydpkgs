{ bun
, nodejs
, stdenv
}:

stdenv.mkDerivation (final: {
  pname = "nbb";
  version = "1.3.200";

  src = ./nbb-${final.version}.tar.gz;

  buildInputs = [
    bun
    nodejs
  ];

  installPhase = ''
    mkdir -p $out
    cp -r lib bin $out
  '';
})
