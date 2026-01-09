{ stdenv
, fetchNpmDeps
, fetchFromGitHub
, fetchzip
, fetchurl
, lib
, imagemagick
, nodejs_20
}:

let
  vendoredKatex = fetchzip {
    url = "https://github.com/KaTeX/KaTeX/releases/download/v0.16.9/katex.zip";
    hash = "sha256-Nca52SW4Q0P5/fllDFQEaOQyak7ojCs0ShlqJ1mWZOM=";
  };
  vendoredWorkbox = fetchurl {
    url = "https://storage.googleapis.com/workbox-cdn/releases/7.0.0/workbox-window.prod.mjs";
    hash = "sha256-YR3m/DqqF+yahPQAk/2k0yRmdoYtQNBEHsL6fQTDmlc=";
  };
  vendoredWorkboxMap = fetchurl {
    url = "https://storage.googleapis.com/workbox-cdn/releases/7.0.0/workbox-window.prod.mjs.map";
    hash = "sha256-tUBiVoiKi3OCT+wctUYl0FVnT7StsGBDx7EzculcF5I=";
  };
  rev = "1816fb788e4d315bf1dc30053a5e1646eb0af9b8";
in stdenv.mkDerivation (final: {
  pname = "quiver";
  version = lib.substring 0 7 rev;
  inherit vendoredKatex vendoredWorkbox vendoredWorkboxMap;
  src = fetchFromGitHub {
    owner = "varkor";
    repo = "quiver";
    inherit rev;
    hash = "sha256-29x2x0fLemkxhv+85wPnDrrlRW2h5qJtF/QTbGa6ghE=";
  };
  npmDeps = fetchNpmDeps {
    src = "${final.src}/service-worker";
    hash = "sha256-1CdgZFvpyJFyh5x9ljTau6vrR7FeHRYZ1MG/ZOEoou8=";
  };
  preBuild = ''
    cp -r $vendoredKatex src/KaTeX
    mkdir src/Workbox
    cp $vendoredWorkbox src/Workbox/workbox-window.prod.mjs
    cp $vendoredWorkboxMap src/Workbox/workbox-window.prod.mjs.map
  '';
  buildPhase = ''
    runHook preBuild
    pushd service-worker
    npm install --cache $npmDeps
    node build.js
    popd
    runHook postBuild
  '';
  installPhase = ''
    runHook preInstall
    mkdir -p $out/opt
    cp -r src $out/opt/quiver
    runHook postInstall
  '';
  nativeBuildInputs = [
    imagemagick
  ];
  buildInputs = [
    nodejs_20
  ];
  meta = {
    description = ''
      A modern commutative diagram editor for the web. 
    '';
    homepage = "https://q.uiver.app/";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
  };
})
