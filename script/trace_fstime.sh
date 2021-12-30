#!/bin/bash

cnt=1
while [ $cnt -le 1 ]
do
    pids=`ps aux |grep fstime |grep 30 |grep -v sh |grep -v perl |grep -v grep |awk '{print $2}'`
    if [  -z "$pids" ]
    then
	continue
    else
	sleep 25
	for pid in $pids
	do
	    #mkdir $pid
	    #cd $pid
	    #trace-cmd record -P $pid -p function_graph &
	    #cd ..
	    echo $pid
	    cat /proc/$pid/sched
	    echo
	done
	((cnt++))
    fi
    pids=
done
