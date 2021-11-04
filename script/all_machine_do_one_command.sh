#!/bin/bash

echo $1 #remote machine info
echo $2 #the command string you want to execute

while IFS= read -r line
do
        username=`echo $line |awk '{print $1}'`
        ip=`echo $line |awk '{print $2}'`
        passwd=`echo $line |awk '{print $3}'`

		# it seems work for different passwd, but
		# for safe, do not concurrent. Maybe solve
		# one day.
		#./do_one_command $username $ip $passwd "$2" &
		./do_one_command $username $ip $passwd "$2"
done < "$1"
