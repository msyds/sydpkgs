{ lib
, fetchFromGitHub
, electron
, nodejs
, makeWrapper
, git
, stdenv
, yarnConfigHook
, fetchYarnDeps
}:

# Similar derivations:
#   - Logseq: https://github.com/NixOS/nixpkgs/blob/nixos-25.05/pkgs/by-name/lo/logseq/package.nix#L283
#   - Podman: https://github.com/NixOS/nixpkgs/blob/224042e9a3039291f22f4f2ded12af95a616cca0/pkgs/applications/virtualization/podman-desktop/default.nix

stdenv.mkDerivation (final: {
  pname = "slippi-launcher";
  version = "2.11.10";

  src = fetchFromGitHub {
    owner = "project-slippi";
    repo = "slippi-launcher";
    rev = "v${final.version}";
    hash = "sha256-EWKxzGLjyJ15wGioUtfh3biU7Pfa5bYtV1Om2w5IZW8=";
    leaveDotGit = true;
  };

  patches = [
    # Dependency with git+https protocol breaks yarnConfigHook.
    ./fix-git-deps.patch
  ];

  # Avoid network error during build.
  # https://stackoverflow.com/questions/78004799/78004800
  env.ELECTRON_SKIP_BINARY_DOWNLOAD = 1;

  buildInputs = [
    electron
  ];

  nativeBuildInputs = [
    yarnConfigHook
    nodejs
    electron
    git
    makeWrapper
  ];

  # Disable the default usage of yarnConfigHook.  We instead opt to run the hook
  # manually (several times) for reasons made clear in the commentary on this
  # package's `postConfigure` script.
  dontYarnInstallDeps = true;

  configurePhase =
    let
      # Constants to be set in the .env file.  Slippi contains an example .env
      # file here:
      # https://github.com/project-slippi/slippi-launcher/blob/main/.env.example
      dotenv = {
        # N.B. although these values are *not* secrets (yes, even the API key), they
        # were extracted from the AppImage release.
        FIREBASE_API_KEY = "AIzaSyAuQqc_wgqcUu3FqrICEPZ9Av_hPxMR_i4";
        FIREBASE_AUTH_DOMAIN = "slippi.firebaseapp.com";
        FIREBASE_DATABASE_URL = "https://slippi.firebaseio.com";
        FIREBASE_PROJECT_ID = "slippi";
        FIREBASE_STORAGE_BUCKET = "slippi.appspot.com";
        FIREBASE_MESSAGING_SENDER_ID = "101358986051";
        FIREBASE_APP_ID = "1:101358986051:web:1e361ce2a76dfd1b0f85f6";
        FIREBASE_MEASUREMENT_ID = "G-VNB1EB87Y2";

        # Ditto.
        SLIPPI_WS_SERVER = "ws://broadcast-dot-slippi.uc.r.appspot.com/";
        SLIPPI_GRAPHQL_ENDPOINT = "/graphql";
      };
    in ''
      runHook preConfigure

      # For reasons I don't quite understand[1], this package is split across two
      # `package.json` files.  We call yarnConfigHook once for each package.json
      # to install their respective dependencies.  Each yarnConfigHook call uses a
      # separate offline cache.
      #
      # [1]: https://www.electron.build/tutorials/two-package-structure.html
      yarnOfflineCache="$yarnOfflineCacheRoot" yarnConfigHook

      pushd release/app
      yarnOfflineCache="$yarnOfflineCacheRelease" yarnConfigHook
      popd

      # Merge the dependencies listed in release/app/package.json into the
      # node_modules/ directory corresponding to the top-level package.json.
      # This feels very wrong!  Surely there's a better way…
      for i in release/app/node_modules/*; do
        dest="node_modules/$(basename "$i")"
        if [[ ! -f "$dest" ]]; then
          mv "$i" "$dest"
        fi
      done

      # Populate the .env file.
      tee .env << EOF
      ${lib.concatLines
        (lib.mapAttrsToList (k: v: "${k}=${v}") dotenv)}
      EOF

      runHook postConfigure
    '';

  buildPhase = ''
    runHook preBuild

    cp -r ${electron.dist} electron-dist
    chmod -R u+w electron-dist

    # Run builds concurrently.  Taken from Slippi's `yarn run package` script,
    # but we've added the `--ofline` flag.
    yarn --offline run build:main &
    yarn --offline run build:renderer &
    yarn --offline run build:migrations &
    wait

    # Build to release/build/linux-unwrapped.  The flag `--dir` stops
    # electron-builder before creating an AppImage.
    ./node_modules/.bin/electron-builder \
      build --dir --publish never \
      -c.electronDist=electron-dist \
      -c.electronVersion=${electron.version}

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/{bin,opt/slippi-launcher}
    cp -r release/build/linux-unpacked/* $out/opt/slippi-launcher

    # Electron programs need to differentiate between production and
    # non-production builds, and they do so by testing if argv[0] is 'electron'
    # or not.  Thus, --inherit-argv0 should be all we need; however, this is not
    # the case.  God knows why.  Just suck it up and set
    # ELECTRON_FORCE_IS_PACKAGED=true.
    makeWrapper '${lib.getExe electron}' $out/bin/slippi-launcher \
      --add-flags "$out/opt/slippi-launcher/resources/app.asar" \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform=wayland --enable-features=WaylandWindowDecorations --enable-wayland-ime=true}}" \
      --prefix LD_LIBRARY_PATH : $out/opt/slippi-launcher \
      --inherit-argv0 \
      --set ELECTRON_FORCE_IS_PACKAGED true

    runHook postInstall
  '';

  yarnOfflineCacheRoot = fetchYarnDeps {
    name = "slippi-launcher-yarn-deps-root";
    # One of our patches modifies the (top-level) Yarn lockfile and thus must be
    # visible to fetchYarnDeps.
    inherit (final) src patches;
    hash = "sha256-Crq9XywLtEc8IImkldodZJ823YG6dB8D9qGksH/lb3I=";
  };

  yarnOfflineCacheRelease = fetchYarnDeps {
    name = "slippi-launcher-yarn-deps-resources";
    # Our patches don't touch the lockfile at release/app/yarn.lock, so there's
    # no need to inherit patches }:).
    inherit (final) src;
    sourceRoot = "${final.src.name}/release/app";
    hash = "sha256-iCFqgy+jRaMCoGC77iXkEh964cZAtXFRfdOOJaRTfLc=";
  };

  meta = {
    description = "The way to play Slippi Online and watch replays.";
    longDescription = ''
      The Slippi Launcher acts as a one stop shop for everything Slippi
      related. It handles updating Slippi Dolphin, playing Slippi Online,
      launching and analyzing replays, and more.
    '';
    license = lib.licenses.gpl3;
    homepage = "https://github.com/project-slippi/slippi-launcher";
    changelog =
      "https://github.com/project-slippi/slippi-launcher/releases/tag/v${final.version}";
    platforms = lib.platforms.all;
    broken = true;
  };
})
