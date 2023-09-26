#!/bin/bash
#usage: ./compile_install_from_file_same_arch.sh file_of_remote_info
#example 1, uname -r: 4.18.0-147.5.1.el8_1.5es.14.x86_64
#        time ~/kernel_debug_tools/script/vmware-dracut.sh ~/kernel_debug_tools/script/machine_info/sandbox ~/work/escore_kernel_source pqy_147_el8_defconfig 16 -147.5.1.el8_1.5es.14.x86_64
#example 2, unamr -r: 4.18.0-pqy-4520d5da0a
#         time ~/kernel_debug_tools/script/vmware-dracut.sh ~/kernel_debug_tools/script/machine_info/sandbox ~/work/escore_kernel_source pqy_147_el8_defconfig 16 NULL
echo $1 #file that store remote machine info formate: username ip passwd
echo $2 #where is kernel source
echo $3 #kernel config
echo $4 #core numbers
echo $5 #kernel version

cd $2
cscope -Rb &
localversion_str=`git log |head -1 |awk '{print $2}' |head -c 10`

cd ~/k-tools/script
input=$1
cnt=1
tot=`cat $1 |wc -l`
while IFS= read -r line
do
	username=`echo $line |awk '{print $1}'`
	ip=`echo $line |awk '{print $2}'`
	passwd=`echo $line |awk '{print $3}'`
	if [[ $cnt -ne 1 ]]; then
		./compile_install_same_arch_vmware_dracut.sh $username $ip $2 $3 $4 $passwd $cnt $tot $localversion_str $5
	else
		./compile_install_same_arch_vmware_dracut.sh $username $ip $2 $3 $4 $passwd $cnt $tot $localversion_str $5
	fi
	cnt=$(($cnt+1))
done < "$input"
date
