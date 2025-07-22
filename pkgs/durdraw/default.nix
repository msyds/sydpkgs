{ lib
, python3Packages
, fetchFromGitHub
, makeWrapper
, withGifExport ? true
, ansilove
}:

# We use `fix` explicitly since `buildPythonApplication` rejects the typical
#   stdenv.mkDerivation (finalAttrs: {
#     ...
#   })
# syntax.
python3Packages.buildPythonApplication (lib.fix (finalAttrs: {
  pname = "durdraw";
  version = "0.29.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "cmang";
    repo = "durdraw";
    rev = finalAttrs.version;
    hash = "sha256-a+4DGWBD5XLaNAfTN/fmI/gALe76SCoWrnjyglNhVPY=";
  };

  build-system = [
    python3Packages.setuptools
  ];

  dependencies =
    lib.optionals withGifExport finalAttrs.optional-dependencies.gif-export;

  optional-dependencies.gif-export = [
    python3Packages.pillow
  ];

  nativeBuildInputs = [
    makeWrapper
  ];

  postInstall = lib.optionalString withGifExport ''
    wrapProgram $out/bin/durdraw \
      --prefix PATH : "${lib.makeBinPath [ansilove]}"
  '';

  meta = {
    changelog =
      "https://github.com/cmang/durdraw/releases/tag/${finalAttrs.version}";
    description = ''
      Versatile ASCII and ANSI Art text editor for drawing in the
      Linux/Unix/macOS terminal, with animation, 256 and 16 colors, Unicode and
      CP437, and customizable themes.
    '';
    homepage = "https://durdraw.org";
    license = lib.licenses.bsd3;
    mainProgram = "durdraw";
  };
}))
