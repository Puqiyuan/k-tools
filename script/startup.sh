#!/bin/bash

# this is a startup script you want to execute
# when system startup. if you don't need just
# leave it
while true; do $HOME/kernel_debug_tools/script/grep_string_from_dmesg_and_send.sh 10.20.42.179 /home/pqy7172/debug_log "sending SIGSEGV to" pqy7172 1 >/dev/null 2>&1; done &

while true; do
	filename=`date +%F`+`date +%H`-`date +%M`-`date +%S-maps`
	$HOME/ld_test/test >$HOME/$filename 2>&1;
	ip addr >>$HOME/$filename
	res=`cat $HOME/$filename |grep -e content`
	if [[ ! -z "$res" ]]
	then
		cp $filename $filename-bak
		$HOME/kernel_debug_tools/script/scp_a_file_expect junk $HOME/$filename /home/pqy7172/debug_log pqy7172 10.20.42.179 1
	fi
	rm -rf $HOME/$filename
done &

while true; do /opt/ltp/testcases/bin/float_trigo >/dev/null 2>&1; done &
