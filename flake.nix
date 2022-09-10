{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    satyxin.url = "github:SnO2WMaN/satyxin";
  };

  inputs = {
    devshell.url = "github:numtide/devshell";

    satysfi-formatter-upstream.url = "github:SnO2WMaN/satysfi-formatter/nix-integrate";
    satysfi-language-server-upstream.url = "github:SnO2WMaN/satysfi-language-server/nix-integrate";

    flake-utils.url = "github:numtide/flake-utils";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    ...
  } @ inputs:
    {
      overlays.default = import ./overlay.nix;
    }
    // flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {
          inherit system;
          overlays = with inputs; [
            devshell.overlay
            satyxin.overlays.default
            satysfi-language-server-upstream.overlays.default
            satysfi-formatter-upstream.overlays.default
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

        devShells.default = pkgs.devshell.mkShell {
          packages = with pkgs; [
            alejandra
            dprint
            satysfi
            satysfi-formatter-write-each
            satysfi-language-server
            treefmt
          ];
          commands = [
            {
              package = "treefmt";
              category = "formatter";
            }
          ];
        };
      }
    );
}
