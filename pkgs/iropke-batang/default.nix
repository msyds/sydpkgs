{ stdenvNoCC
, fetchFromGitHub
, lib
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "iropke-batang";
  version = "1.2";
  src = fetchFromGitHub {
    owner = "iropke";
    repo = "font-iropke-batang";
    rev = "v${finalAttrs.version}";
    hash = "sha256-wsu7JK0hHYn9aegaMeNV9fWvQ6KoMzHwOFWymWHYvxo=";
  };

  installPhase = ''
    runHook preInstall
    find . -type f -name '*.otf' \
      -exec install -Dm644 {} -t $out/share/fonts/opentype \;
    runHook postInstall
  '';

  meta = {
    description = "Korean serif font";
    homepage = "http://font.iropke.com/batang/";
    changelog = "https://github.com/iropke/font-iropke-batang/releases";
    license = lib.licenses.ofl;
    platforms = lib.platforms.all;
  };
})
