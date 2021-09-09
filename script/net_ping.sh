#!/bin/bash

echo $1 #remote machine info
cnt=1
while IFS= read -r line
do
        ip=`echo $line |awk '{print $2}'`
		ping -c 1 $ip
		echo $cnt
		cnt=$(($cnt+1))
done < "$1"
