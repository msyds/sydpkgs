{ stdenv
, cmake
, fetchFromGitHub
, libansilove
}:

stdenv.mkDerivation (final: {
  pname = "ansilove";
  version = "4.2.1";

  src = fetchFromGitHub {
    owner = "ansilove";
    repo = "ansilove";
    rev = final.version;
    hash = "sha256-13v2NLVJt11muwocBiQYz/rxQkte/W6LXwB/H/E9Nvk=";
  };

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = [
    libansilove
  ];
})
