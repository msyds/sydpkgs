{ lib
, python3Packages
, fetchFromGitHub
, makeWrapper
, withGifExport ? true
, ansilove
}:

python3Packages.buildPythonApplication rec {
  pname = "durdraw";
  version = "0.29.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "cmang";
    repo = "durdraw";
    rev = version;
    hash = "sha256-a+4DGWBD5XLaNAfTN/fmI/gALe76SCoWrnjyglNhVPY=";
  };

  build-system = with python3Packages; [
    setuptools
  ];

  dependencies = [];

  nativeBuildInputs = [
    makeWrapper
  ];

  postInstall = lib.optionalString withGifExport ''
    wrapProgram $out/bin/durdraw \
      --prefix PATH : "${lib.makeBinPath [ansilove]}"
  '';

  meta = {
    changelog = "https://github.com/cmang/durdraw/releases/tag/${version}";
    description = ''
      Versatile ASCII and ANSI Art text editor for drawing in the
      Linux/Unix/macOS terminal, with animation, 256 and 16 colors, Unicode and
      CP437, and customizable themes.
    '';
    homepage = "https://github.com/cmang/durdraw/";
    license = lib.licenses.bsd3;
  };
}
