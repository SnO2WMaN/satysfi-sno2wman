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
    {
      overlays.default = import ./overlay.nix;
      overlay = self.overlays.default;
    }
    // flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            devshell.overlay
            satyxin.overlay
            self.overlays.default
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
        packages.default = pkgs.satyxinPackages.sno2wman;
        defaultPackage = self.packages."${system}".default;

        devShell = pkgs.devshell.mkShell {
          imports = [
            (pkgs.devshell.importTOML ./devshell.toml)
          ];
        };
      }
    );
}
