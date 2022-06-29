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
    
    echo $PERF $out/bin/test 
    $PERF $out/bin/test
  '';

  enableParallelBuilding = true;
}
