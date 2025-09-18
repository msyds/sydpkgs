{ stdenv, fetchNpmDeps, fetchFromGitHub, fetchzip, fetchurl, lib, imagemagick, nodejs_20 }:

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
  rev = "9872f3f9265f92643387239e76042c8d3ffeb410";
in stdenv.mkDerivation (final: {
  pname = "quiver";
  version = lib.substring 0 7 rev;
  inherit vendoredKatex vendoredWorkbox vendoredWorkboxMap;
  src = fetchFromGitHub {
    owner = "varkor";
    repo = "quiver";
    inherit rev;
    hash = "sha256-wSyCzUSLUL5nzUe5E4RdWv44WGd4C9WO6udkKY9cyBs=";
  };
  npmDeps = fetchNpmDeps {
    src = "${final.src}/service-worker";
    hash = "sha256-xlww7Yfle58Qdwn/IcA6E6Fy7ZvH/ltKdlk6hvcC4UM=";
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
})
