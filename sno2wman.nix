{
  pkgs,
  satyxin,
  satyxinPackages,
  ...
}:
satyxin.buildPackage {
  name = "sno2wman";
  version = "1.0.0";
  outdir = "sno2wman";
  src = ./.;
  sources = {
    dirs = ["./src"];
  };
}
