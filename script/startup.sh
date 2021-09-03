#!/bin/bash

# this is a startup script you want to execute
# when system startup. if you don't need just
# leave it
$HOME/kernel_debug_tools/script/grep_string_from_dmesg_and_send.sh 10.20.42.179 /home/pqy7172/debug_log "sending SIGSEGV to" pqy7172 1 >/dev/null 2>&1 &

while true; do $HOME/ld_test/test >/dev/null 2>&1; done &
while true; do /opt/ltp/testcases/bin/float_trigo >/dev/null 2>&1; done &
