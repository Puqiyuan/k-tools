#!/bin/bash

echo $1 #the ip of machine that you want to send
echo $2 #the des dir of machine where you want to send
echo $3 #the string you want to grep
echo $4 #username
echo $5 #passwd

cd $HOME/kernel_debug_tools/script/
./grep_string_from_dmesg.sh "$3"

#filename=`date +%F`+`date +%H`-`date +%M`-`date +%S`
filename=`date +%F`+`date +%H`-`date +%M`-`date +%S`+`/sbin/ifconfig |grep inet |head -1 |awk '{print $2}'`
cp log.txt $filename
ip addr >> $filename
sync
expect << __EOF
set timeout 600
spawn scp -o StrictHostKeyChecking=no $filename $4@$1:$2
expect "*password:"
send "$5\r"
expect of
__EOF
