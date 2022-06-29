# Run like this:
#   nix-build /path/to/this/directory
# ... and the files are produced in ./result/bin/test

{ pkgs ? (import <nixpkgs> {})
, source ? ./.
, version ? "dev"
, supportOpenstack ? false
, sudo ? "/usr/bin/sudo"
}:

with pkgs;

stdenv.mkDerivation rec {
  name = "test-${version}";
  inherit version;
  src = lib.cleanSource source;

  buildInputs = [ makeWrapper ];

  patchPhase = ''
    patchShebangs .
    
  '' + lib.optionalString supportOpenstack ''
    # We need a way to pass $PATH to the scripts
    sed -i '2iexport PATH=${git}/bin:${mariadb}/bin:${which}/bin:${procps}/bin:${coreutils}/bin' src/program/snabbnfv/neutron_sync_master/neutron_sync_master.sh.inc
    sed -i '2iexport PATH=${git}/bin:${coreutils}/bin:${diffutils}/bin:${nettools}/bin' src/program/snabbnfv/neutron_sync_agent/neutron_sync_agent.sh.inc
  '';

  preBuild = ''
    make clean
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp bin/test $out/bin
    export PERF="perf stat -d"
    export -p > $out/env.sh
    echo ${sudo} -E taskset -c 23 $PERF $out/bin/test 
    ${sudo} -E taskset -c 23 $PERF $out/bin/test
  '';

  enableParallelBuilding = true;
}
