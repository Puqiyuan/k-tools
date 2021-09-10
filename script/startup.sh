#!/bin/bash
export DISPLAY=:0
$HOME/kernel_debug_tools/script/grep_string_from_dmesg_and_send.sh 10.20.42.191 /home/pqy7172/debug_log "sending SIGSEGV to" pqy7172 1 >/dev/null 2>&1 &
/usr/bin/deepin-terminal -e /opt/ltp/testscripts/ltpstress.sh -n -t 24
#sudo su
#cd /opt/ltp/testscripts/
#/usr/bin/deepin-terminal -e ltpstress.sh -n -t 24
#exit
#/bin/bash ltpstress.sh -n -t 24 -S -p >/dev/null 2>&1 &
#/bin/bash ltpstress.sh -n -t 24 -S -p >/home/loongson/output.txt 2>&1 &
# this is a startup scri[]pt you want to execute
# when system startup. if you don't need just
# leave it
#while true; do $HOME/kernel_debug_tools/script/grep_string_from_dmesg_and_send.sh 10.20.42.191 /home/pqy7172/debug_log "sending SIGSEGV to" pqy7172 1 >/dev/null 2>&1; done &

#while true; do
#	filename=`date +%F`+`date +%H`-`date +%M`-`date +%S`+`/sbin/ifconfig |grep inet |head -1 |awk '{print $2}'`
	#$HOME/ld_test/test >$HOME/$filename 2>&1;
	#ip addr >>$HOME/$filename
#	res=`cat $HOME/$filename |grep -e content`
#	if [[ ! -z "$res" ]]
#	then
#		cp $filename $filename-bak
#		$HOME/kernel_debug_tools/script/scp_a_file_expect junk $HOME/$filename /home/pqy7172/debug_log pqy7172 10.20.42.179 1
#	fi
#	rm -rf $HOME/$filename
#done &

#while true; do /opt/ltp/testcases/bin/float_trigo >/dev/null 2>&1; done &
