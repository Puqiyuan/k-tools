#!/bin/bash
echo test config file: $1

cnt=1
while IFS= read -r line
do
    username=`echo $line |awk '{print $1}'`
    ip=`echo $line |awk '{print $2}'`
    passwd=`echo $line |awk '{print $3}'`
    testname=`echo $line |awk '{print $4}'`

	/usr/bin/mate-terminal --tab -e "./do_one_command $username $ip $passwd $HOME/kernel_debug_tools/script/test_unit/$testname" -t $cnt-$ip-$testname
	cnt=$((cnt + 1))
done < "$1"
