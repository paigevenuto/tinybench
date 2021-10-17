#!/bin/bash

runsKept=30

formatSpeed() {
    awk -F"," '/copied/{print $4}' | xargs
}

# cpu intensive stream operation
cpuSpeed=$( { cpuTestStream=$( dd if=/dev/zero bs=1M count=256 | md5sum ); } 2>&1 | formatSpeed)

# commits to a write cache buffer in RAM before writing to disk
memSpeed=$( dd bs=1M count=256 if=/dev/zero of=/tmp/memBenchmark |& formatSpeed)

# realistic write to disk
writeSpeed=$( dd if=/dev/zero of=/tmp/writeBench bs=1M count=256 conv=fdatasync |& formatSpeed)

# syncs read after write to disk
readSpeed=$( dd if=/dev/zero of=/tmp/test1.img bs=1M count=256 oflag=dsync |& formatSpeed)

currentResult=$( echo "$(date),$cpuSpeed,$memSpeed,$writeSpeed,$readSpeed")

lastRuns=$( awk -F"," '/\//{print $0}' tinybench.txt | tail -n $runsKept | sed 's/ *$//g')

printf "DATE,CPU,MEM,WRITE,READ\n$lastRuns\n$currentResult" | awk -F"," '{printf "%-30s %-10s %-10s %-10s %-10s \n", $1,$2,$3,$4,$5}' > tinybench.txt

cat tinybench.txt
