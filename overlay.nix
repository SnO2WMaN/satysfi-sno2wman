final: prev: {
  satyxinPackages =
    prev.satyxinPackages
    // {
      sno2wman = final.callPackage (import ./sno2wman.nix) {};
    };
}
