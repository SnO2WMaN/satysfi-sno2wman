self: super: {
  satyxinPackages =
    super.satyxinPackages
    // {
      sno2wman = self.callPackage (import ./sno2wman.nix) {};
    };
}
