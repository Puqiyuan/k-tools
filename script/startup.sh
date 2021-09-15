#!/bin/bash
export DISPLAY=:0
$HOME/kernel_debug_tools/script/grep_string_from_dmesg_and_send.sh 10.20.42.191 /home/pqy7172/debug_log "sending SIGSEGV to" pqy7172 1 >/dev/null 2>&1 &
/usr/bin/deepin-terminal
# Script to keep mouse pointer moving so that, for example, Suspend to RAM timeout does not occur.
# 
# The mouse pointer will move around its current position on the screen, i.e. around any position
# on the screen where you place the pointer. However, if you prefer it to move around the centre
# of the screen then change mousemove_relative to mousemove in the xdotool command below.
#
# Set LENGTH to 0 if you do not want the mouse pointer to actually move.
# Set LENGTH to 1 if you want the mouse pointer to move just a tiny fraction.
# Set LENGTH to e.g. 100 if you want to see more easily the mouse pointer move.
#/usr/bin/deepin-terminal
#LENGTH=5
#
# Set DELAY to the desired number of seconds between each move of the mouse pointer.
#DELAY=1
#
#while true
#do
#    for ANGLE in 0 90 180 270
#    do
        #xdotool mousemove_relative --polar $ANGLE $LENGTH
#		xdotool key t
#        sleep $DELAY
#    done
#done &
#/usr/bin/deepin-terminal
#/usr/bin/deepin-terminal -e /opt/ltp/testscripts/ltpstress.sh -n -t 24
#timeout 4h /home/loongson/genload_test_O2 >/dev/null 2>&1 &
#/usr/bin/deepin-terminal -e /opt/ltp/testscripts/ltpstress.sh -n -t 24
#/usr/bin/deepin-terminal -e /opt/ltp/testscripts/ltpstress.sh -n -t 24
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
