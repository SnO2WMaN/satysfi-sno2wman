{
  pkgs,
  satyxin,
  ...
}:
satyxin.buildPackage {
  pname = "satyxin-sno2wman";
  version = "1.0.0";

  outdir = "sno2wman";
  copyfrom = [
    ./src
  ];
}
