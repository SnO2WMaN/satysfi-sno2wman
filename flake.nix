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

      satyxinPackages.sno2wman = import ./sno2wman.nix;
    }
    // flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            devshell.overlay
            satyxin.overlay
          ];
        };
      in rec {
        packages = rec {
          satydist = pkgs.satyxin.buildSatydist {
            packages = [
              "fss"
            ];
            adhocPackages = with self.packages."${system}"; [
              satyxin-package-sno2wman
            ];
          };

          document-example = pkgs.satyxin.buildDocument {
            inherit satydist;
            name = "main";
            src = ./example;
            entrypoint = "main.saty";
          };
        };
        packages.satyxin-package-sno2wman = pkgs.callPackage (import ./sno2wman.nix) {};
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
