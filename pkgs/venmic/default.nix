{ cmake
, cacert
, cpm-cmake
, git
, pkg-config
, pulseaudio
, pipewire
, fetchFromGitHub
, stdenv
}:

# See
# https://github.com/NixOS/nixpkgs/blob/nixos-25.05/pkgs/development/compilers/codon/default.nix#L136
# for an example of an CPM/CMake project built with Nix.

let
  version = "6.1.0";
  depsDir = "deps";

  src = fetchFromGitHub {
    owner = "Vencord";
    repo = "venmic";
    rev = "v${version}";
    hash = "sha256-0UP8a2bfhWGsB2Lg/GeIBu4zw1zHnXbitT8vU+DLeEY=";
  };

  venmic-deps = stdenv.mkDerivation {
    name = "venmic-deps-${version}.tar.gz";

    inherit src;

    nativeBuildInputs = [
      cmake
      cacert
      cpm-cmake
      git
      # Pkg-config is implicitly used by CMake and will fail to find libs
      # without it.
      pkg-config
    ];

    buildInputs = [
      pulseaudio
      pipewire
    ];

    dontBuild = true;

    cmakeFlags = [
      "-DCPM_DOWNLOAD_ALL=ON"
      "-DCPM_SOURCE_CACHE=${depsDir}"
    ];

    installPhase = ''
      # Build a reproducible tarball, per
      # https://reproducible-builds.org/docs/archives.
      tar --owner=0 --group=0 --numeric-owner --format=gnu \
          --sort=name --mtime="@$SOURCE_DATE_EPOCH" \
          -czf $out \
          "${depsDir}"
    '';

    outputHashAlgo = "sha256";
    outputHash = "sha256-J/uctyoqC2j58TYemjRBtOMMXz70e8uv/VeA+vq8WVY=";
  };

  venmic = stdenv.mkDerivation {
    pname = "venmic";
    inherit version src;

    postUnpack = ''
      # Bring in the cached CPM deps.
      mkdir -p $sourceRoot/build
      tar xzf ${venmic-deps} -C $sourceRoot/build

      # Bring in CPM itself — Venmic tries to download it itself.
      rm $sourceRoot/cmake/cpm.cmake
      ln -s ${cpm-cmake}/share/cpm/CPM.cmake $sourceRoot/cmake/cpm.cmake
    '';

    cmakeFlags = [
      "-DCPM_SOURCE_CACHE=${depsDir}"
      "-Dvenmic_prefer_remote=OFF"
    ];

    nativeBuildInputs = [
      cmake
      cpm-cmake
      git
      # Pkg-config is implicitly used by CMake and will fail to find libs
      # without it.
      pkg-config
    ];

    buildInputs = [
      pulseaudio
      pipewire
    ];

    installPhase = ''
      mkdir -p $out/bin
      mv server/venmic-server $out/bin
    '';
  };
in venmic
