#!/bin/bash
cnt=0

while true; do
    N=$((cnt % 9))

    date >  /var/log/pqy_hardirq${N}.txt
    cat /proc/interrupts >> /var/log/pqy_hardirq${N}.txt

    date > /var/log/pqy_softirq${N}.txt
    cat /proc/softirqs >> /var/log/pqy_softirq${N}.txt

    ((cnt++))

    sleep 2
done
