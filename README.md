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
max@spare-NFG2:~/test-nix$ nix-build
this derivation will be built:
  /nix/store/jdgwibw2vm2sagb7admjab9k4ckdji9h-test-dev.drv
building '/nix/store/jdgwibw2vm2sagb7admjab9k4ckdji9h-test-dev.drv'...
unpacking sources
unpacking source archive /nix/store/j72l1yg9zxc9fphxa6sglh3q2bfzxkap-source
source root is source
patching sources
patching script interpreter paths in .
configuring
no configure script, doing nothing
building
build flags: -j24 -l24 SHELL=/nix/store/qhvvivdi9pkvfpv7130sa71kpslkjv6f-bash-5.1-p16/bin/bash
make: Nothing to be done for 'all'.
installing
/usr/bin/perf_5.10 stat -d numactl -N 1 -m 1 taskset -c 23 /nix/store/bpfpxzykmsyh6xifmh5sdw5h50ix1nwv-test-dev/bin/test

 Performance counter stats for 'numactl -N 1 -m 1 taskset -c 23 /nix/store/bpfpxzykmsyh6xifmh5sdw5h50ix1nwv-test-dev/bin/test':

           3197.22 msec task-clock                #    1.000 CPUs utilized
                 4      context-switches          #    0.001 K/sec
                 2      cpu-migrations            #    0.001 K/sec
               186      page-faults               #    0.058 K/sec
       12854618407      cycles                    #    4.021 GHz                      (62.47%)
           1490854      stalled-cycles-frontend   #    0.01% frontend cycles idle     (62.47%)
           1985007      stalled-cycles-backend    #    0.02% backend cycles idle      (62.47%)
       10959032621      instructions              #    0.85  insn per cycle
                                                  #    0.00  stalled cycles per insn  (62.47%)
        1212439369      branches                  #  379.217 M/sec                    (62.58%)
           2161160      branch-misses             #    0.18% of all branches          (62.55%)
        4831905182      L1-dcache-loads           # 1511.284 M/sec                    (62.55%)
             79458      L1-dcache-load-misses     #    0.00% of all L1-dcache accesses  (62.44%)
   <not supported>      LLC-loads
   <not supported>      LLC-load-misses

       3.197729858 seconds time elapsed

       3.197727000 seconds user
       0.000000000 seconds sys


post-installation fixup
shrinking RPATHs of ELF executables and libraries in /nix/store/bpfpxzykmsyh6xifmh5sdw5h50ix1nwv-test-dev
shrinking /nix/store/bpfpxzykmsyh6xifmh5sdw5h50ix1nwv-test-dev/bin/test
strip is /nix/store/0ldkj6mklr9r8fml6927akjdl3zih46m-gcc-wrapper-11.3.0/bin/strip
stripping (with command strip and flags -S) in /nix/store/bpfpxzykmsyh6xifmh5sdw5h50ix1nwv-test-dev/bin
patching script interpreter paths in /nix/store/bpfpxzykmsyh6xifmh5sdw5h50ix1nwv-test-dev
checking for references to /tmp/nix-build-test-dev.drv-0/ in /nix/store/bpfpxzykmsyh6xifmh5sdw5h50ix1nwv-test-dev...
/nix/store/bpfpxzykmsyh6xifmh5sdw5h50ix1nwv-test-dev


max@spare-NFG2:~/test-nix$ /usr/bin/perf_5.10 stat -d numactl -N 1 -m 1 taskset -c 23 /nix/store/bpfpxzykmsyh6xifmh5sdw5h50ix1nwv-test-dev/bin/test

 Performance counter stats for 'numactl -N 1 -m 1 taskset -c 23 /nix/store/bpfpxzykmsyh6xifmh5sdw5h50ix1nwv-test-dev/bin/test':

            988.02 msec task-clock                #    1.000 CPUs utilized
                 3      context-switches          #    0.003 K/sec
                 2      cpu-migrations            #    0.002 K/sec
               204      page-faults               #    0.206 K/sec
     3,971,337,598      cycles                    #    4.019 GHz                      (62.35%)
         8,384,869      stalled-cycles-frontend   #    0.21% frontend cycles idle     (62.35%)
           892,315      stalled-cycles-backend    #    0.02% backend cycles idle      (62.35%)
    10,948,864,071      instructions              #    2.76  insn per cycle
                                                  #    0.00  stalled cycles per insn  (62.42%)
     1,211,041,796      branches                  # 1225.721 M/sec                    (62.83%)
         2,437,029      branch-misses             #    0.20% of all branches          (62.75%)
     3,456,869,149      L1-dcache-loads           # 3498.771 M/sec                    (62.67%)
            25,870      L1-dcache-load-misses     #    0.00% of all L1-dcache accesses  (62.27%)
   <not supported>      LLC-loads
   <not supported>      LLC-load-misses

       0.988476052 seconds time elapsed

       0.988478000 seconds user
       0.000000000 seconds sys
```