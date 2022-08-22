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
          satysfi-dist = pkgs.satyxin.buildSatysfiDist {
            packages = with pkgs.satyxinPackages; [
              fss
              sno2wman
            ];
          };
          doc-example = pkgs.satyxin.buildDocument {
            satysfiDist = satysfi-dist;
            name = "main";
            src = ./example;
            entrypoint = "main.saty";
          };
        };

        packages.satyxin-package-sno2wman = pkgs.satyxinPackages.sno2wman;
        packages.default = self.packages."${system}".satyxin-package-sno2wman;

        defaultPackage = self.packages."${system}".default;

        devShell = pkgs.devshell.mkShell {
          imports = [
            (pkgs.devshell.importTOML ./devshell.toml)
          ];
        };
      }
    );
}
