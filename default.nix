# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <nixpkgs> { } }:

let
  callPackage = pkgs.lib.callPackageWith (pkgs // sydpkgs);
  sydpkgs =
    pkgs.lib.mapAttrs
      (pkg: _:
        callPackage ./pkgs/${pkg} {})
      (builtins.readDir ./pkgs);
in sydpkgs // {
  # The `lib`, `modules`, and `overlays` names are special
  lib = import ./lib { inherit pkgs; };

  modules = import ./modules;

  overlays = import ./overlays;
}
