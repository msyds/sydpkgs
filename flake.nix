{
  description = "My niche packages.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = inputs@{ self, ... }:
    let
      lib = inputs.nixpkgs.lib;
      forAllSystems = lib.genAttrs lib.systems.flakeExposed;
    in {
      legacyPackages = forAllSystems (system: import ./default.nix {
        pkgs = import inputs.nixpkgs { inherit system; };
      });

      packages =
        forAllSystems (system:
          lib.filterAttrs
            (_: v: lib.isDerivation v)
            self.legacyPackages.${system});

      devShells.x86_64-linux.slippi =
        let
          pkgs = import inputs.nixpkgs { system = "x86_64-linux"; };
        in self.packages.x86_64-linux.slippi-launcher.env.overrideAttrs
          (final: prev: {
            shellHook =
              builtins.replaceStrings
                ["exec \"\${cmd[@]}\""]
                [''
                  echo "''${cmd[-1]}"
                  unset cmd[-1]
                  cmd+=("$SHELL")
                  exec "''${cmd[@]}"
                '']
                prev.shellHook;
          });
    };
}
