#!/bin/bash
#usage: ./compile_install_from_file_same_arch.sh file_of_remote_info
echo $1 #file that store remote machine info formate: username ip passwd
echo $2 #where is kernel source
echo $3 #kernel config
echo $4 #core numbers

cd $2
localversion_str=`git log |head -1 |awk '{print $2}' |head -c 10`

cd ~/kernel_debug_tools/script
input=$1
cnt=1
tot=`cat $1 |wc -l`
while IFS= read -r line
do
	username=`echo $line |awk '{print $1}'`
	ip=`echo $line |awk '{print $2}'`
	passwd=`echo $line |awk '{print $3}'`
	if [[ $cnt -ne 1 ]]; then
		./compile_install_same_arch_vmware_dracut.sh $username $ip $2 $3 $4 $passwd $cnt $tot $localversion_str
	else
		./compile_install_same_arch_vmware_dracut.sh $username $ip $2 $3 $4 $passwd $cnt $tot $localversion_str
	fi
	cnt=$(($cnt+1))
done < "$input"
date
