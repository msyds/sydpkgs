{ stdenv, libpng, fetchFromGitHub }:

stdenv.mkDerivation {
  pname = "vtf2png";
  version = "e74a1f";
  src = fetchFromGitHub {
    owner = "eXeC64";
    repo = "vtf2png";
    rev = "e74a1fd24b760a0339ec4d498d0b9fef75d847ff";
    hash = "sha256-/tfhTMQNBh6RVe55QyYjG3ns0w0/E/afF7aB2lAp/f4=";
  };
  buildInputs = [
    libpng
  ];
  installPhase = ''
    mkdir -p $out/bin
    mv vtf2png $out/bin
  '';
}
