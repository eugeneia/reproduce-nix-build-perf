# Run like this:
#   nix-build /path/to/this/directory
# ... and the files are produced in ./result/bin/test

{ pkgs ? (import <nixpkgs> {})
, source ? ./.
, version ? "dev"
}:

with pkgs;

stdenv.mkDerivation rec {
  name = "test-${version}";
  inherit version;
  src = lib.cleanSource source;

  buildInputs = [ makeWrapper ];

  patchPhase = ''
    patchShebangs .
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp bin/test $out/bin

    export PERF="/usr/bin/perf_5.10 stat -d"
    export CPU="numactl -N 0 -m 0 taskset -c 23"

    echo $PERF $CPU $out/bin/test 
    $PERF $CPU $out/bin/test
  '';

  enableParallelBuilding = true;
}
