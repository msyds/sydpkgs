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
    };
}
