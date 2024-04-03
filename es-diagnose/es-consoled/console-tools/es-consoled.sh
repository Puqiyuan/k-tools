#!/bin/bash

#root required
#usage:   ./es-consoled.sh ip username passwd >/dev/null 2>&1 &
#example: ./es-consoled.sh 10.100.0.203 Administrator Admin@9000 >/dev/null 2>&1 &

if [ "$EUID" -ne 0 ]; then
  exit 1
fi

trap '' SIGTTIN
trap '' SIGCHLD
trap '' SIGTSTP
trap '' SIGTTOU

arch=`lscpu |grep Archite |awk '{print $2}'`
if [ "$arch" = "x86_64" ];then
    ln -s ./es-ipmitool-x86 ./es-ipmitool
elif [ "$arch" = "aarch64" ]; then
    ln -s ./es-ipmitool-aarch64 ./es-ipmitool
else
    exit 2
fi

while true; do
    ./es-ipmitool -H $1 -U $2 -P $3 -I lanplus sol deactivate
    sleep 5
    ./es-ipmitool -H $1 -U $2 -P $3 -I lanplus sol activate >/dev/null 2>&1 &
    pid=$!
    wait $pid
done
