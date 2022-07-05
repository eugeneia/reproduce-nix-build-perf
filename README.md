Seeing different performance of CPU bound workloads when run under nix-build as compared to when run manually.

```
Linux spare-NFG2 5.10.0-9-amd64 #1 SMP Debian 5.10.70-1 (2021-09-30) x86_64 GNU/Linux
AMD EPYC 7443P 24-Core Processor
iommu=off nosmt isolcpus=6-23

$ numactl -H
available: 1 nodes (0)
node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23
node 0 size: 128756 MB
node 0 free: 24645 MB
node distances:
node   0
  0:  10

max@spare-NFG2:~/test-nix$ cat /sys/devices/system/cpu/cpu23/cpufreq/scaling_governor
performance

max@spare-NFG2:~/test-nix$ nix --version
nix (Nix) 2.9.1

$ cat /etc/nix/nix.conf
build-users-group = nixbld

sandbox = false
allow-new-privileges = true
max-jobs = 1
```

To reproduce:

```
this derivation will be built:
  /nix/store/s1z1zba6frxqpcr5k0grpv4rirl3d4gd-test-dev.drv
building '/nix/store/s1z1zba6frxqpcr5k0grpv4rirl3d4gd-test-dev.drv'...
unpacking sources
unpacking source archive /nix/store/cd3xxs5xzsdsch74nikfyz0dh4050rk0-source
source root is source
patching sources
patching script interpreter paths in .
configuring
no configure script, doing nothing
building
build flags: -j24 -l24 SHELL=/nix/store/qhvvivdi9pkvfpv7130sa71kpslkjv6f-bash-5.1-p16/bin/bash
gcc -o bin/test src/test.c
installing
/usr/bin/perf_5.10 stat -d numactl -N 0 -m 0 taskset -c 23 /nix/store/g9vw7nyhc8lr71y0m4xpk7rzis5ck4lm-test-dev/bin/test
Received 1000000000 packets (fl.nfree=100000)

 Performance counter stats for 'numactl -N 0 -m 0 taskset -c 23 /nix/store/g9vw7nyhc8lr71y0m4xpk7rzis5ck4lm-test-dev/bin/test':

          13201.44 msec task-clock                #    1.000 CPUs utilized
                10      context-switches          #    0.001 K/sec
                 1      cpu-migrations            #    0.000 K/sec
            100371      page-faults               #    0.008 M/sec
       37572440311      cycles                    #    2.846 GHz                      (74.97%)
           6365381      stalled-cycles-frontend   #    0.02% frontend cycles idle     (74.97%)
          34128909      stalled-cycles-backend    #    0.09% backend cycles idle      (74.99%)
       50844206590      instructions              #    1.35  insn per cycle
                                                  #    0.00  stalled cycles per insn  (75.02%)
       12170473234      branches                  #  921.905 M/sec                    (75.03%)
          20391818      branch-misses             #    0.17% of all branches          (75.03%)
       18659831088      L1-dcache-loads           # 1413.470 M/sec                    (75.01%)
           9592496      L1-dcache-load-misses     #    0.05% of all L1-dcache accesses  (74.98%)
   <not supported>      LLC-loads
   <not supported>      LLC-load-misses

      13.201778077 seconds time elapsed

      13.093873000 seconds user
       0.108015000 seconds sys


post-installation fixup
shrinking RPATHs of ELF executables and libraries in /nix/store/g9vw7nyhc8lr71y0m4xpk7rzis5ck4lm-test-dev
shrinking /nix/store/g9vw7nyhc8lr71y0m4xpk7rzis5ck4lm-test-dev/bin/test
strip is /nix/store/0ldkj6mklr9r8fml6927akjdl3zih46m-gcc-wrapper-11.3.0/bin/strip
stripping (with command strip and flags -S) in /nix/store/g9vw7nyhc8lr71y0m4xpk7rzis5ck4lm-test-dev/bin
patching script interpreter paths in /nix/store/g9vw7nyhc8lr71y0m4xpk7rzis5ck4lm-test-dev
checking for references to /tmp/nix-build-test-dev.drv-0/ in /nix/store/g9vw7nyhc8lr71y0m4xpk7rzis5ck4lm-test-dev...
/nix/store/g9vw7nyhc8lr71y0m4xpk7rzis5ck4lm-test-dev


max@spare-NFG2:~/test-nix$ /usr/bin/perf_5.10 stat -d numactl -N 0 -m 0 taskset -c 23 /nix/store/g9vw7nyhc8lr71y0m4xpk7rzis5ck4lm-test-dev/bin/test
Received 1000000000 packets (fl.nfree=100000)

 Performance counter stats for 'numactl -N 0 -m 0 taskset -c 23 /nix/store/g9vw7nyhc8lr71y0m4xpk7rzis5ck4lm-test-dev/bin/test':

          8,791.20 msec task-clock                #    1.000 CPUs utilized
                 7      context-switches          #    0.001 K/sec
                 1      cpu-migrations            #    0.000 K/sec
           100,379      page-faults               #    0.011 M/sec
    25,021,009,956      cycles                    #    2.846 GHz                      (74.97%)
        26,505,012      stalled-cycles-frontend   #    0.11% frontend cycles idle     (74.97%)
        23,495,224      stalled-cycles-backend    #    0.09% backend cycles idle      (74.97%)
    50,791,659,395      instructions              #    2.03  insn per cycle
                                                  #    0.00  stalled cycles per insn  (74.98%)
    12,165,866,411      branches                  # 1383.868 M/sec                    (75.02%)
        22,094,280      branch-misses             #    0.18% of all branches          (75.07%)
    16,607,300,112      L1-dcache-loads           # 1889.082 M/sec                    (75.03%)
        10,273,281      L1-dcache-load-misses     #    0.06% of all L1-dcache accesses  (74.98%)
   <not supported>      LLC-loads
   <not supported>      LLC-load-misses

       8.791589560 seconds time elapsed

       8.711693000 seconds user
       0.079997000 seconds sys
```