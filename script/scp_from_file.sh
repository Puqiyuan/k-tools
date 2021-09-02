#!/bin/bash

echo $1 #remote machine info
echo $2 #file that will be send

while IFS= read -r line
do
        username=`echo $line |awk '{print $1}'`
        ip=`echo $line |awk '{print $2}'`
        passwd=`echo $line |awk '{print $3}'`
		dir=/home/$username
		echo $dir
		./scp_a_file_expect $1 $2 $dir $username $ip $passwd
done < "$1"
