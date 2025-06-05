{ stdenv
, cmake
, fetchFromGitHub
, gd
}:

stdenv.mkDerivation (final: {
  pname = "libansilove";
  version = "1.4.2";

  src = fetchFromGitHub {
    owner = "ansilove";
    repo = "libansilove";
    rev = final.version;
    hash = "sha256-kbQ7tbQbJ8zYhdbfiVZY26woyR4NNzqjCJ/5nrunlWs=";
  };

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = [
    gd
  ];
})
