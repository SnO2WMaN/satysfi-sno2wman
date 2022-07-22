{pkgs, ...}:
pkgs.satyxin.buildPackage {
  name = "sno2wman";
  src = ./.;
  sources = {
    dirs = ["./src"];
  };
  deps = [];
}
