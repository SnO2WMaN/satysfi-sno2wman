{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    devshell.url = "github:numtide/devshell";
    satyxin.url = "github:SnO2WMaN/satyxin";

    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };
  outputs = {
    self,
    nixpkgs,
    flake-utils,
    devshell,
    satyxin,
    ...
  } @ inputs:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            devshell.overlay
            satyxin.overlay
            (final: prev: {
              satyxinPackages = (
                prev.satyxinPackages
                // {
                  sno2wman = self.packages.${system}.default;
                }
              );
            })
          ];
        };
      in rec {
        packages = rec {
          satydist = pkgs.satyxin.buildSatydist {
            packages = [
              "fss"
              "sno2wman"
            ];
          };
          example = pkgs.satyxin.buildDocument {
            inherit satydist;
            name = "main";
            src = ./example;
            entrypoint = "main.saty";
          };
        };
        packages.default = pkgs.satyxin.buildPackage {
          name = "sno2wman";
          src = ./.;
          sources = {
            dirs = [
              "./src"
            ];
          };
          deps = [];
        };
        defaultPackage = self.packages."${system}".default;

        devShell = pkgs.devshell.mkShell {
          imports = [
            (pkgs.devshell.importTOML ./devshell.toml)
          ];
        };
      }
    );
}
