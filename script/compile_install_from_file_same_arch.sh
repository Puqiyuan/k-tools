#!/bin/bash
#usage: ./compile_install_from_file_same_arch.sh file_of_remote_info
echo $1 #file that store remote machine info formate: username ip passwd
echo $2 #where is kernel source
echo $3 #kernel config
echo $4 #core numbers

input=$1
cnt=1
tot=`cat $1 |wc -l`
while IFS= read -r line
do
	username=`echo $line |awk '{print $1}'`
	ip=`echo $line |awk '{print $2}'`
	passwd=`echo $line |awk '{print $3}'`
	./compile_install_same_arch.sh $username $ip $2 $3 $4 $passwd $cnt $tot &
	cnt=$(($cnt+1))
done < "$input"
