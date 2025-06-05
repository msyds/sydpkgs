{ stdenv, pkg-config, udev, libusb1, fetchFromGitHub }:

stdenv.mkDerivation {
  pname = "wii-u-gc-adapter";
  version = "fa098ef";

  src = fetchFromGitHub {
    owner = "ToadKing";
    repo = "wii-u-gc-adapter";
    rev = "fa098efa7f6b34f8cd82e2c249c81c629901976c";
    hash = "sha256-wm0vDU7QckFvpgI50PG4/elgPEkfr8xTmroz8kE6QMo=";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    udev
    libusb1
  ];

  patches = [
    ./remove-Wformat.patch
  ];

  installPhase = ''
    mkdir -p $out/bin
    mv wii-u-gc-adapter $out/bin
  '';
}
